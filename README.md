# gsecret.sh

`gsecret.sh` is a shell script that allows you to interact with Google Cloud Secret Manager from the command line. It provides functionality to list secrets, retrieve secrets, apply secrets to the current shell, and save secrets to a .env file.

## Features

- List all available secrets in a Google Cloud project.
- Retrieve a secret value by its ID.
- Apply a secret value to the current shell environment.
- Save a secret value to a .env file.

## Prerequisites

- [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install) installed and configured.

## Usage

### Download and Install

To download and install `gsecret.sh`, follow these steps:

1. Download the script to your home directory:

   ```bash
   curl -o ~/gsecret.sh https://raw.githubusercontent.com/your-repo/gsecret.sh/main/gsecret.sh
   ```

2. Make the script executable:

   ```bash
   chmod +x ~/gsecret.sh
   ```

3. Add the following line to your shell configuration file (e.g., ~/.zshrc) to make it accessible from anywhere:

   ```bash
   export PATH=$PATH:~/gsecret.sh
   ```

4. Source your shell configuration file to apply the changes:

   ```bash
   source ~/.zshrc
   ```

### Usage Examples

```bash
# List all available secrets in a Google Cloud project
gsecret.sh --project YOUR_PROJECT_ID --list

# Retrieve a secret value by its ID
gsecret.sh --project YOUR_PROJECT_ID YOUR_SECRET_ID

# Apply a secret value to the current shell environment
gsecret.sh --project YOUR_PROJECT_ID --apply YOUR_SECRET_ID

# Save a secret value to a .env file
gsecret.sh --project YOUR_PROJECT_ID --save YOUR_SECRET_ID
```

Replace `YOUR_PROJECT_ID` with your actual Google Cloud project ID and `YOUR_SECRET_ID` with the ID of the secret you want to interact with.

---

Feel free to customize this README according to your needs and add any additional information you think would be helpful!
