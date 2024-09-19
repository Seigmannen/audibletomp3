#!/bin/bash

# Hent Audible Activation Bytes automatisk
ACTIVATION_BYTES=$(audible activate | grep -oP '(?<=Activation Bytes: )\w+')

if [[ -z "$ACTIVATION_BYTES" ]]; then
    echo "Kunne ikke hente Activation Bytes. Sørg for at du er logget inn i Audible."
    exit 1
fi

echo "Aktiveringskoden ble hentet: $ACTIVATION_BYTES"

# Hent liste over alle tilgjengelige bøker
echo "Henter Audible bibliotek..."
audible library list > library.txt

# Skriv ut hva library.txt inneholder for feilsøking
echo "Innholdet i Audible-biblioteket:"
cat library.txt

# Hent titler og ASIN fra listen
declare -a titles
declare -a asins

while IFS= read -r line; do
    # Ekstraher ASIN og tittel fra linjen
    asin=$(echo "$line" | cut -d':' -f1)  # ASIN er første element
    title=$(echo "$line" | cut -d':' -f3- | sed 's/^ //g')  # Tittel etter 3. kolon, trim start-space

    if [[ -n $asin && -n $title ]]; then
        titles+=("$title")
        asins+=("$asin")
    fi
done < library.txt

# Slett midlertidig bibliotek-fil
rm library.txt

# Sjekk om det finnes bøker i listen
if [[ ${#titles[@]} -eq 0 ]]; then
    echo "Fant ingen bøker i biblioteket ditt."
    exit 1
fi

# Vis meny for å velge en tittel
echo "Velg en tittel å laste ned:"
for i in "${!titles[@]}"; do
    printf "%d) %s\n" "$((i+1))" "${titles[$i]}"
done

# Be brukeren velge en gjenstand
read -p "Skriv inn nummeret til tittelen du vil laste ned: " selection

# Valider brukerens valg
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#titles[@]} ]]; then
    echo "Ugyldig valg. Avslutter."
    exit 1
fi

# Juster valg (brukerens valg er 1-basert, mens arrayen er 0-basert)
index=$((selection-1))

selected_asin=${asins[$index]}
selected_title=${titles[$index]}

echo "Du har valgt å laste ned: $selected_title (ASIN: $selected_asin)"

# Lagre filen i download/
output_dir=download/
audible download --output-dir "$output_dir" --asin "$selected_asin" --aax-fallback -q best --cover --cover-size 1215 --chapter --chapter-type Flat

# Finn nedlastet fil (vi antar at filen har .aax eller .aaxc filending)
aax_file=$(find "$output_dir" -name "*.aax" -o -name "*.aaxc" | head -n 1)

if [[ -z "$aax_file" ]]; then
    echo "Kunne ikke finne AAX/AAXC-filen. Nedlasting feilet?"
    exit 1
fi

# Konverter AAX/AAXC til MP3 med AAXtoMP3
echo "Konverterer $aax_file til MP3..."
./AAXtoMP3 -A "$ACTIVATION_BYTES" -e:mp3 -c --use-audible-cli-data "$aax_file"

# Slett de originale filene
rm -f "$output_dir"/*.*

if [[ $? -eq 0 ]]; then
    echo "Originalfilene ble slettet."
else
    echo "Kunne ikke slette en eller flere filer."
fi
