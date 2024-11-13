# Audible Download and Conversion Script

This script automates the process of downloading Audible books and converting them from **AAX/AAXC** format to **MP3**. It utilizes **[audible-cli](https://github.com/mkb79/audible-cli)** for downloading and managing profiles and **[AAXtoMP3](https://github.com/josuebatista/AAXtoMP3)** for converting the files.

## Prerequisites

Before running the script, ensure you have the following installed and set up:

### 1. audible-cli
**audible-cli** is a command-line interface for managing your Audible account and downloading books.

- **Installation**:
  ```bash
  pip install audible-cli

- **Setup**: Log in to your Audible account using the following command:
  ```bash
  audible login

After logging in, you can manage profiles and retrieve activation bytes as needed.

For more details, visit the [audible-cli GitHub page](https://github.com/mkb79/audible-cli).
