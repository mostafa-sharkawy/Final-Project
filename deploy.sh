#!/bin/bash

# Function to prompt for continuation
prompt_continue() {
    read -p "Press Enter to continue or Ctrl+C to abort..."
    echo
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required commands
for cmd in terraform ansible-playbook; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is not installed or not in PATH"
        exit 1
    fi
done

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
    echo "The directory should contain Terraform/ and Ansible/ subdirectories."
    exit 1
fi

# Verify required directories exist
if [[ ! -d "$PROJECT_DIR/Terraform" || ! -d "$PROJECT_DIR/Ansible" ]]; then
    echo "Error: Required directories (Terraform/ and Ansible/) not found."
    echo "Please ensure you have the complete project structure."
    exit 1
fi

# Step 1: Terraform initialization
echo "============================================="
echo "STEP 1: Initializing Terraform"
echo "============================================="
cd "$PROJECT_DIR/Terraform" || exit
terraform init
echo
prompt_continue

# Step 2: Terraform apply
echo "============================================="
echo "STEP 2: Applying Terraform configuration"
echo "============================================="
terraform apply --auto-approve
echo
prompt_continue

# Step 3: Run Ansible playbook
echo "============================================="
echo "STEP 3: Running Ansible playbook"
echo "============================================="
cd "$PROJECT_DIR/Ansible" || exit
ansible-playbook -i hosts Install_Docker_Jenkins.yml
echo

echo "============================================="
echo "All steps completed successfully!"
echo "============================================="

# Display important information
echo "Jenkins URL: http://$(terraform -chdir="$PROJECT_DIR/Terraform" output -raw instance_public_ip):8080"
echo "Initial admin password was displayed in the Ansible output above."
