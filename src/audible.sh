#!/bin/bash

# Show available profiles
echo "Available Audible profiles:"
audible manage profile list

# Prompt the user to select a profile
echo "Select a profile by entering the profile name:"
read profile_name

# Check if a profile is selected
if [[ -z "$profile_name" ]]; then
    echo "No profile selected. Exiting."
    exit 1
fi

# Automatically retrieve Audible Activation Bytes
echo "Retrieving Activation Bytes..."

ACTIVATION_BYTES=$(audible -P "$profile_name" activation-bytes | grep -o '[A-Fa-f0-9]\{8\}')

if [[ -z "$ACTIVATION_BYTES" ]]; then
    echo "Could not retrieve Activation Bytes. Make sure you are logged into Audible."
    exit 1
fi

echo "Activation code retrieved: $ACTIVATION_BYTES"

# Retrieve a list of all available books
echo "Retrieving Audible library..."
audible -P "$profile_name" library list > library.txt

# Print the content of library.txt for debugging
echo "Content of the Audible library:"
cat library.txt

# Extract titles and ASIN from the list
declare -a titles
declare -a asins

while IFS= read -r line; do
    # Extract ASIN and title from the line
    asin=$(echo "$line" | cut -d':' -f1)  # ASIN is the first element
    title=$(echo "$line" | cut -d':' -f3- | sed 's/^ //g')  # Title after the 3rd colon, trim leading space

    if [[ -n $asin && -n $title ]]; then
        titles+=("$title")
        asins+=("$asin")
    fi
done < library.txt

# Delete temporary library file
rm library.txt

# Check if there are any books in the list
if [[ ${#titles[@]} -eq 0 ]]; then
    echo "No books found in your library."
    exit 1
fi

# Display menu to select a title
echo "Select a title to download:"
for i in "${!titles[@]}"; do
    printf "%d) %s\n" "$((i+1))" "${titles[$i]}"
done

# Prompt the user to select an item
read -p "Enter the number of the title you want to download: " selection

# Validate the user's choice
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#titles[@]} ]]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

# Adjust selection (user's choice is 1-based, while arrays are 0-based)
index=$((selection-1))

selected_asin=${asins[$index]}
selected_title=${titles[$index]}

echo "You have chosen to download: $selected_title (ASIN: $selected_asin)"

# Save the file in download/
output_dir=download/
audible -P "$profile_name" download --output-dir "$output_dir" --asin "$selected_asin" --aax-fallback -q best --cover --cover-size 1215 --chapter --chapter-type Flat

# Find the downloaded file (assuming it has .aax or .aaxc extension)
aax_file=$(find "$output_dir" -name "*.aax" -o -name "*.aaxc" | head -n 1)

if [[ -z "$aax_file" ]]; then
    echo "Could not find the AAX/AAXC file. Download failed."
    exit 1
fi

# Convert AAX/AAXC to MP3 using AAXtoMP3
echo "Converting $aax_file to MP3..."
./AAXtoMP3 -A "$ACTIVATION_BYTES" -e:mp3 -c --use-audible-cli-data "$aax_file"

# Delete the original files
rm -f "$output_dir"/*.*
   
if [[ $? -eq 0 ]]; then
    echo "Original files have been deleted."
else
    echo "Could not delete one or more files."
fi
