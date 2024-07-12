#!/bin/bash

function updateDependencies
{
    echo "Updating all packages to the latest versions..."
    # Run the update function
    update_packages

    echo "All packages have been updated to the latest versions."
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


