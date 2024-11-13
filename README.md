# Audible Download and Conversion Script

This script automates the process of downloading Audible books and converting them from **AAX/AAXC** format to **MP3**. It utilizes **[audible-cli](https://github.com/mkb79/audible-cli)** for downloading and managing profiles and **[AAXtoMP3](https://github.com/josuebatista/AAXtoMP3)** for converting the files.

## Prerequisites

Before running the script, ensure you have the following installed and set up:

### 1. audible-cli
**audible-cli** is a command-line interface for managing your Audible account and downloading books.

- **Installation**:
  ```bash
  pip install audible-cli
  ```
- **Setup**: Log in to your Audible account using the following command:
  ```bash
  audible login
  ```
After logging in, you can manage profiles and retrieve activation bytes as needed.

For more details, visit the [audible-cli GitHub page](https://github.com/mkb79/audible-cli).

### 2. AAXtoMP3
**AAXtoMP3** is a tool for converting Audible **AAX/AAXC** files to **MP3** format.

- **Installation**: Clone the repository:
  ```bash
  git clone https://github.com/josuebatista/AAXtoMP3.git
  ```
- **Setup**: Ensure the `AAXtoMP3` executable is in the same directory as this script.

For more details, visit the [AAXtoMP3 GitHub page](https://github.com/josuebatista/AAXtoMP3).

### 3. Folder Structure
Make sure your directory is structured as follows:
```bash
/script-directory
  ├── audible.sh       # This script
  ├── AAXtoMP3         # AAXtoMP3 executable
  ├── download/        # Folder for storing downloaded Audible files
```
To create the `download` folder, run:
```bash
mkdir download
```
## Usage
### 1. Run the Script:
  ```bash
  ./audible.sh
  ```
### 2. Follow the prompts:
  * Select the Audible profile.
  * Choose a book from your library to download.
  * The script will download the book, convert it to chaptered MP3, and clean up the original files.

### Notes
* Ensure your Audible account is properly set up in **audible-cli**.
* Activation bytes are retrieved automatically for the selected profile.

### Credits
* josuebatista - [AAXtoMP3](https://github.com/josuebatista/AAXtoMP3)
* mkb79 - [audible-cli](https://github.com/mkb79/audible-cli)