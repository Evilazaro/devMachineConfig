#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to log messages
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to update all packages
update_packages() {
  log_message "Updating all packages to the latest versions..."
  sudo apt-get update && sudo apt-get upgrade -y
  log_message "All packages have been updated to the latest versions."
}

# Function to install or update .NET SDK 8.0
install_or_update_dotnet() {
  log_message "Installing or updating .NET SDK 8.0..."
  sudo apt-get update -y
  sudo apt-get install -y --allow-remove-essential wget 
  sudo apt-get install -y --allow-remove-essential apt-transport-https

  # Remove any existing Microsoft package repository
  sudo rm -f /etc/apt/sources.list.d/microsoft-prod.list

  # Download and install the Microsoft package repository for Ubuntu
  wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  sudo apt-get update -y
  echo "Unholding packages"
  sudo apt-get install -y dotnet-sdk-8.0
  log_message ".NET SDK 8.0 installation or update is complete."

  log_message "Updating .NET workloads..."
  sudo dotnet workload update
  log_message ".NET workloads have been updated."
}

# Function to install Azure CLI
install_azure_cli() {
  log_message "Installing Azure CLI..."
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  sudo apt-get install gh -y
  log_message "Azure CLI installation is complete."
}

# Main function to coordinate the update process
main() {
  update_packages
  install_or_update_dotnet
  install_azure_cli
  install_vscode_extensions
}

# Execute the main function
main

# Main function to coordinate the update process
main() {
  clear
  update_packages
  install_or_update_dotnet
  install_azure_cli
}

# Execute the main function
main