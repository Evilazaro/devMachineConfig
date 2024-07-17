Set-ExecutionPolicy Bypass -Scope Process -Force; 

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

function installVSWorkloads {
    # Check if winget is installed
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget is installed. Proceeding with Visual Studio Enterprise installation..."

        # Install Visual Studio Enterprise with specific workloads
        $workloads = @"
        --add Microsoft.VisualStudio.Workload.CoreEditor

"@

        winget install Microsoft.VisualStudio.2022.Enterprise --override $workloads
    
        Write-Host "Visual Studio Enterprise installation initiated."
    }
    else {
        Write-Error "winget is not installed. Please install it from the Microsoft Store."
    }

}

installVSWorkloads
InstallVSCodeExtensions
UpdateDotNetWorkloads