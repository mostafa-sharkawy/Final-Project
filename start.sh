#!/bin/bash

# Hardcoded Git repository URL
REPO_URL="https://github.com/mostafa-sharkawy/Final-Project.git"

# Ask for folder name
read -p "Enter folder name: " folder_name

# Create folder
mkdir -p "$folder_name" || { echo "❌ Error: Failed to create folder '$folder_name'"; exit 1; }

# Enter folder and clone repo
cd "$folder_name" || { echo "❌ Error: Failed to enter folder '$folder_name'"; exit 1; }
git clone "$REPO_URL" || { echo "❌ Error: Failed to clone repository"; exit 1; }

# Extract repo name from URL (for entering the correct subfolder)
repo_dir=$(basename "$REPO_URL" .git)
cd "$repo_dir" || { echo "❌ Error: Failed to enter repo directory '$repo_dir'"; exit 1; }

# Make deploy.sh executable and run it
if [[ -f "deploy.sh" ]]; then
    chmod +x deploy.sh
    echo "🚀 Running ./deploy.sh..."
    ./deploy.sh
else
    echo "⚠️ Warning: deploy.sh not found in the repository!"
fi


