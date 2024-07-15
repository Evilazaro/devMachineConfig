function update-dependencies {
   
    Get-InstalledPowerShellVersion
    InstallWinGet 
    InstallOrUpdateAzureDevCLI
    InstallOrUpdateGitHubCLI
    UpdateDotNetWorkloads
    InstallVSCodeExtensions
}

# Function to display messages with different severity levels
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

# Function to check the installed version of PowerShell
function Get-InstalledPowerShellVersion {
    # Main script logic
    Write-Log -Message "Starting PowerShell installation or update process."
    try {
        $psVersion = $null
        if (Get-Command pwsh -ErrorAction SilentlyContinue) {
            $psVersion = pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
        }
        elseif (Get-Command powershell -ErrorAction SilentlyContinue) {
            $psVersion = powershell -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
        }
        Write-Log -Message "Installed PowerShell version: $psVersion"
    }
    catch {
        Write-Log -Message "Failed to get the installed PowerShell version: $_" -Level "ERROR"
    }
}

# Function to install or update PowerShell
function InstallOrUpdatePowerShell {
    try {
        # Download the PowerShell installer script
        $installerUrl = "https://aka.ms/install-powershell.ps1"
        $installerScript = "$env:TEMP\install-powershell.ps1"

        Invoke-WebRequest -Uri $installerUrl -OutFile $installerScript -ErrorAction Stop
        Write-Log -Message "Downloaded the PowerShell installer script."

        # Execute the installer script
        & $installerScript -UseMSI -Quiet -AddToPath
        Write-Log -Message "PowerShell installation or update completed successfully."
    }
    catch {
        Write-Log -Message "Failed to install or update PowerShell: $_" -Level "ERROR"
    }
}

# Function to install or update Azure Developer CLI using winget
function InstallOrUpdateAzureDevCLI {
    try {
        Write-Log -Message "Checking if winget is installed..."
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Log -Message "winget is not installed. Please install winget first." -Level "ERROR"
            return
        }

        Write-Log -Message "Installing or updating Azure Developer CLI using winget..."
        winget install Microsoft.Azd -s winget --silent --accept-package-agreements --accept-source-agreements
        Write-Log -Message "Azure Developer CLI installation or update completed successfully."
    }
    catch {
        Write-Log -Message "Failed to install or update Azure Developer CLI: $_" -Level "ERROR"
    }
}

# Function to install or update GitHub CLI using winget
function InstallOrUpdateGitHubCLI {
    try {
        Write-Log -Message "Checking if winget is installed..."
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Log -Message "winget is not installed. Please install winget first." -Level "ERROR"
            return
        }

        Write-Log -Message "Installing or updating GitHub CLI using winget..."
        winget install GitHub.cli -s winget --silent --accept-package-agreements --accept-source-agreements
        Write-Log -Message "GitHub CLI installation or update completed successfully."
    }
    catch {
        Write-Log -Message "Failed to install or update GitHub CLI: $_" -Level "ERROR"
    }
}

# Function to install or update .NET SDK and runtime using winget
function UpdateDotNetWorkloads {
    try {

        Write-Log -Message "Updating Dotnet workloads..."
        dotnet workload update
        Write-Log -Message "Workloads have been completed successfully."

    }
    catch {
        Write-Log -Message "Failed to update Dotnet workloads: $_" -Level "ERROR"
    }
}

function InstallVSCodeExtensions {
    try {
        Write-Log -Message "Installing VSCode extensions..."
        code --install-extension ms-vscode-remote.remote-wsl --force
        code --install-extension ms-vscode.PowerShell --force
        code --install-extension ms-vscode.vscode-node-azure-pack --force
        code --install-extension GitHub.copilot --force
        code --install-extension GitHub.vscode-pull-request-github --force
        code --install-extension GitHub.copilot-chat --force
        code --install-extension GitHub.remotehub --force
        code --install-extension GitHub.vscode-github-actions --force
        code --install-extension eamodio.gitlens-insiders --force	
        code --install-extension ms-vscode.azure-repos --force
        code --install-extension ms-azure-devops.azure-pipelines --force
        code --install-extension ms-azuretools.vscode-docker --force	
        code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools --force
        code --install-extension ms-kubernetes-tools.vscode-aks-tools --force
        code --install-extension ms-azuretools.vscode-azurecontainerapps --force
        code --install-extension ms-azuretools.vscode-azurefunctions --force
        code --install-extension ms-azuretools.vscode-apimanagement	--force
        Write-Log -Message "VSCode extensions have been installed successfully."
    }
    catch {
        Write-Log -Message "Failed to install VSCode extensions: $_" -Level "ERROR"
    }
}

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

update-dependencies