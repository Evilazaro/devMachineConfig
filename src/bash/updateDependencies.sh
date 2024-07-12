#!/bin/bash

function updateDependencies
{
    echo "Updating all packages to the latest versions..."
    # Run the update function
    update_packages

    echo "All packages have been updated to the latest versions."

    echo "Installing or updating .NET SDK 8.0..."

    install_or_update_dotnet

    echo ".NET SDK 8.0 installation or update is complete."

    installAzureCLI

    installGitHubCLI
}

# Function to check the package manager and update packages
update_packages() {
  if command -v apt-get &> /dev/null; then
    echo "Updating packages using apt-get..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get dist-upgrade -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
  elif command -v yum &> /dev/null; then
    echo "Updating packages using yum..."
    sudo yum check-update -y
    sudo yum update -y
    sudo yum clean all
  else
    echo "Unsupported package manager. Please update manually."
    exit 1
  fi
}

# Function to install or update .NET SDK 8.0 on Ubuntu
install_or_update_dotnet() {
  echo "Using apt-get for package installation..."
  sudo apt-get update -y
  sudo apt-get install -y wget apt-transport-https

  # Remove any existing Microsoft package repository
  sudo rm -f /etc/apt/sources.list.d/microsoft-prod.list

  # Download and install the Microsoft package repository for Ubuntu
  wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  sudo apt-get update -y
  sudo apt-get install -y dotnet-sdk-8.0

  echo "Updating dotnet workloads..."
  sudo dotnet workload update
  echo "dotnet workloads have been updated."
}

installAzureCLI() {
  echo "Installing Azure CLI..."
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  curl -sL https://aka.ms/install-azd.sh | sudo bash
  echo "Azure CLI installation is complete."
}

installGitHubCLI
{
    echo "Installing GitHub CLI..."
    sudo apt-get update
    sudo apt-get install -y gh

    echo "GitHub CLI has been installed sucssessfuly"
}

updateDependencies



