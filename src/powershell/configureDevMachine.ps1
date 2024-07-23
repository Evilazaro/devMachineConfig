param(
    [int]$step = 2
)

Set-ExecutionPolicy Bypass -Scope Process -Force; 
# Parameter help description


function UpdateDotNetWorkloads {
    try {

        Write-Host "Updating Dotnet workloads..."
        dotnet workload update
        Write-Host "Workloads have been completed successfully."

    }
    catch {
        Write-Host "Failed to update Dotnet workloads: $_"  -Level "ERROR"
    }
}

function InstallVSCodeExtensions {
    try {
        Write-Host "Installing VSCode extensions..."

        $extensions = @(
            "ms-vscode-remote.remote-wsl",
            "ms-vscode.PowerShell",
            "ms-vscode.vscode-node-azure-pack",
            "GitHub.copilot",
            "GitHub.vscode-pull-request-github",
            "GitHub.copilot-chat",
            "GitHub.remotehub",
            "GitHub.vscode-github-actions",
            "eamodio.gitlens-insiders",
            "ms-vscode.azure-repos",
            "ms-azure-devops.azure-pipelines",
            "ms-azuretools.vscode-docker",
            "ms-kubernetes-tools.vscode-kubernetes-tools",
            "ms-kubernetes-tools.vscode-aks-tools",
            "ms-azuretools.vscode-azurecontainerapps",
            "ms-azuretools.vscode-azurefunctions",
            "ms-azuretools.vscode-apimanagement"
        )

        foreach ($extension in $extensions) {
            code --install-extension $extension --force
        }

        Write-Host "VSCode extensions have been installed successfully."
    }
    catch {
        Write-Host "Failed to install VSCode extensions: $_" -Level "ERROR"
    }
}

function installUbuntu{
    # Check if winget is installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget is installed. Proceeding with Ubuntu installation..."

        # Install Ubuntu
        wsl --install -d Ubuntu

        Write-Host "Ubuntu installation initiated."
    }
    else {
        Write-Error "winget is not installed. Please install it from the Microsoft Store."
    }

}

function updateWingetPackages {
    try {
        Write-Host "Updating winget packages..."
        winget upgrade --all
        Write-Host "Packages have been updated successfully."
    }
    catch {
        Write-Host "Failed to update winget packages: $_"  -Level "ERROR"
    }
}

function importWingetPackages {
    try {
        Write-Host "Importing winget packages... Please have a sit and relax."
        winget import -i .\configDevMachine.json
        Write-Host "Packages have been imported successfully."
    }
    catch {
        Write-Host "Failed to import winget packages: $_"  -Level "ERROR"
    }
}

function restartComputer{
    Write-Host "Restarting the computer in 10 seconds..."
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}

switch ($step) {
    1 {
        installUbuntu
        restartComputer
    }
    2 {
        importWingetPackages
        restartComputer
    }
    3 {
        InstallVSCodeExtensions
        UpdateDotNetWorkloads
        updateWingetPackages
    }
    default {
        Write-Host "Invalid step number. Please provide a valid step number." -Level "ERROR"
    }
}


