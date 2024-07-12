#!/bin/bash

function updateDependencies
{
    echo "Updating all packages to the latest versions..."
    # Run the update function
    update_packages

    echo "All packages have been updated to the latest versions."

    # Check if .NET SDK is already installed and update if necessary
    if command -v dotnet &> /dev/null; then
      echo ".NET SDK is already installed. Checking for updates..."
      install_or_update_dotnet
    else
      echo ".NET SDK is not installed. Installing the latest version..."
      install_or_update_dotnet
    fi

    echo ".NET SDK 8.0 installation or update is complete."

    installAzureCLI

    installGitHubCLI

    installVSCode
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
  dotnet workload update
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
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y

    sudo apt update
    sudo apt install gh

    echo "GitHub CLI has been installed sucssessfuly"
}

installVSCode
{
    echo "Installing Visual Studio Code..."
    sudo apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg

    sudo apt-get update -y
    sudo apt-get install -y wget apt-transport-https
    sudo apt install code
    echo "Visual Studio Code installation is complete."
}

updateDependencies



