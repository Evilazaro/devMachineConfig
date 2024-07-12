function updateDependencies
{

}

function updatePackages
{
    # Update the package list
    sudo apt-get update

    # Upgrade the packages
    sudo apt-get upgrade -y
}