#!/bin/bash

# Function to prompt for confirmation
confirm_destroy() {
    read -p "Are you sure you want to DESTROY all resources? (yes/no): " answer
    case ${answer:0:1} in
        y|Y )
            echo "Proceeding with destruction..."
            ;;
        * )
            echo "Aborting destruction."
            exit 0
            ;;
    esac
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Secure file removal with verification
secure_remove() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        echo "Removing: $file_path"
        rm -f "$file_path"
        if [ -f "$file_path" ]; then
            echo "Warning: Failed to remove $file_path"
            return 1
        fi
    fi
}

# Check for required commands
if ! command_exists terraform; then
    echo "Error: terraform is not installed or not in PATH"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if we're in the Final-Project directory or its subdirectories
if [[ -d "$SCRIPT_DIR/Terraform" && -d "$SCRIPT_DIR/Ansible" ]]; then
    PROJECT_DIR="$SCRIPT_DIR"
elif [[ -d "$SCRIPT_DIR/../Terraform" && -d "$SCRIPT_DIR/../Ansible" ]]; then
    PROJECT_DIR="$SCRIPT_DIR/.."
else
    echo "Error: Could not find Final-Project directory structure."
    echo "Please run this script from the Final-Project directory or its subdirectories."
    exit 1
fi

# Verify required directories exist
if [[ ! -d "$PROJECT_DIR/Terraform" ]]; then
    echo "Error: Required Terraform directory not found."
    exit 1
fi

# Display warning and get confirmation
echo "============================================="
echo "WARNING: THIS WILL DESTROY ALL RESOURCES"
echo "============================================="
echo "This will:"
echo "1. Run 'terraform destroy' on: $PROJECT_DIR/Terraform"
echo "2. Remove sensitive files including:"
echo "   - Terraform state files"
echo "   - SSH keys (mykey.pem)"
echo "   - Ansible inventory/vars files"
echo "============================================="
confirm_destroy

# Step 1: Terraform destroy
echo "============================================="
echo "STEP 1: Destroying Terraform resources"
echo "============================================="
cd "$PROJECT_DIR/Terraform" || exit
terraform destroy --auto-approve

# Step 2: Clean up sensitive files
echo "============================================="
echo "STEP 2: Cleaning up sensitive files"
echo "============================================="

# Remove Terraform files
secure_remove "$PROJECT_DIR/Terraform/terraform.tfstate"
secure_remove "$PROJECT_DIR/Terraform/terraform.tfstate.backup"

# Remove Ansible files
secure_remove "$PROJECT_DIR/Ansible/inventory.ini"
secure_remove "$PROJECT_DIR/Ansible/vars.yml"

# Remove SSH keys from all possible locations
secure_remove "$PROJECT_DIR/mykey.pem"
secure_remove "$PROJECT_DIR/Terraform/mykey.pem"
secure_remove "$PROJECT_DIR/Ansible/mykey.pem"
secure_remove "$HOME/.ssh/mykey.pem"

# Additional verification
echo "============================================="
echo "Verification:"
echo "Checking for remaining sensitive files..."
find "$PROJECT_DIR" -name "mykey.pem" -o -name "terraform.tfstate*" -o -name "inventory.ini" -o -name "vars.yml"

echo "============================================="
echo "Cleanup complete. Resources destroyed and files removed."
echo "============================================="
