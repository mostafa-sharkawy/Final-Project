#!/bin/bash

# Hardcoded Git repository URL
REPO_URL="https://github.com/mostafa-sharkawy/Final-Project.git"

# Find the highest-numbered folder (e.g., 1, 2, 3...)
last_folder=$(find . -maxdepth 1 -type d -name '[0-9]*' | sort -V | tail -n 1)

# If no numbered folders exist, start with '1', else increment
if [[ -z "$last_folder" ]]; then
    new_folder="1"
else
    last_num=${last_folder#./}  # Remove './' prefix
    new_folder=$((last_num + 1))
fi

# Create the new folder
mkdir "$new_folder" || { echo "❌ Error: Failed to create folder '$new_folder'"; exit 1; }


# Enter folder and clone repo
cd "$new_folder" || { echo "❌ Error: Failed to enter folder '$new_folder'"; exit 1; }
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



