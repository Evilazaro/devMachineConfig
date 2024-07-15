function InstallWinGet {

    # Set PSGallery installation policy to trusted
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    pwsh.exe -MTA -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
    
    # check if the Microsoft.Winget.Client module is installed
    if (!(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
        Write-Host "Installing Microsoft.Winget.Client"
        Install-Module Microsoft.WinGet.Client -Scope "AllUsers" 
        pwsh.exe -MTA -Command "Install-Module Microsoft.WinGet.Client -Scope AllUsers"
        Write-Host "Done Installing Microsoft.Winget.Client"
    }
    else {
        Write-Host "Microsoft.Winget.Client is already installed"
    }
    
    # check if the Microsoft.WinGet.Configuration module is installed
    if (!(Get-Module -ListAvailable -Name Microsoft.WinGet.Configuration)) {
        Write-Host "Installing Microsoft.WinGet.Configuration"
        pwsh.exe -MTA -Command "Install-Module Microsoft.WinGet.Configuration -AllowPrerelease -Scope AllUsers"
        Write-Host "Done Installing Microsoft.WinGet.Configuration"
    }
    else {
        Write-Host "Microsoft.WinGet.Configuration is already installed"
    }


    $desktopAppInstallerPackage = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller"

    if (!($desktopAppInstallerPackage)) {
        # install Microsoft.DesktopAppInstaller
        try {
            Write-Host "Installing Microsoft.DesktopAppInstaller"
            $DesktopAppInstallerAppx = "$env:TEMP\$([System.IO.Path]::GetRandomFileName())-DesktopAppInstaller.appx"
            Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $DesktopAppInstallerAppx
            Add-AppxPackage -Path $DesktopAppInstallerAppx -ForceApplicationShutdown
            Write-Host "Done Installing Microsoft.DesktopAppInstaller"
        }
        catch {
            Write-Host "Failed to install DesktopAppInstaller appx package"
            Write-Error $_
        }
    }

    Write-Host "WinGet version: $(winget -v)"

}

function installAllToolsAndApps {
    runWinGet -id "Microsoft.PowerToys" -message "Installing PowerToys"
    runWinGet -id "Microsoft.DotNet.SDK.8" -message "Installing .NET 8 SDK"
    runWinGet -id "Microsoft.DotNet.Runtime.8" -message "Installing .NET 8 Runtime"
    runWinGet -id "Microsoft.WindowsTerminal" -message "Installing Windows Terminal"
    runWinGet -id "9MZ1SNWT0N5D" -message "Installing PowerShell" -source "msstore"
    runWinGet -id "Microsoft.AzureCLI" -message "Installing Azure CLI"
    runWinGet -id "Microsoft.Azd" -message "Installing Azure DevOps CLI"
    runWinGet -id "OpenJS.NodeJS" -message "Installing NodeJS"
    runWinGet -id "Microsoft.Azure.FunctionsCoreTools" -message "Installing Azure Functions Core Tools"
    runWinGet -id "Git.Git" -message "Installing Git"
    runWinGet -id "GitHub.cli" -message "Installing GitHub CLI"
    runWinGet -id "GitHub.GitHubDesktop" -message "Installing GitHub Desktop"
    runWinGet -id "Microsoft.VisualStudioCode" -message "Installing Visual Studio Code"
    runWinGet -id "Microsoft.VisualStudio.2022.Enterprise" -message "Installing Visual Studio 2022 Enterprise"
    runWinGet -id "Postman.Postman" -message "Installing Postman"
    runwinget -id "Docker.DockerDesktop" -message "Installing Docker Desktop"
}

function runWinGet{
    param (
        [Parameter(Mandatory=$true)]
        [string]$id,
        [Parameter(Mandatory=$true)]
        [string]$message,
        [string]$source = "winget"
    )

    Write-Host $message
    winget isntall -e --id $id --source $source --accept-package-agreements --accept-source-agreements --silent

}

function configureDevMachine{

    InstallWinGet
    installAllToolsAndApps
}

