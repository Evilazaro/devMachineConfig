function update-dependencies {
    # Main script logic
    Write-Log -Message "Starting PowerShell installation or update process."

    $installedVersion = Get-InstalledPowerShellVersion
    Write-Log -Message "Installed PowerShell version: $installedVersion"

    # If PowerShell is not installed or needs to be updated
    if (-not $installedVersion -or $installedVersion -lt "7.0.0") {
        Write-Log -Message "Installing or updating to the latest version of PowerShell."
        InstallOrUpdatePowerShell
    } else {
        Write-Log -Message "PowerShell is already up-to-date."
    }

    Write-Log -Message "PowerShell installation or update process completed."

        # Main script logic
    Write-Log -Message "Starting Azure Developer CLI installation or update process."

    # Install or update Azure Developer CLI
    InstallOrUpdateAzureDevCLI

    Write-Log -Message "Azure Developer CLI installation or update process completed."

        # Main script logic
    Write-Log -Message "Starting GitHub CLI installation or update process."

    # Install or update GitHub CLI
    InstallOrUpdateGitHubCLI

    Write-Log -Message "GitHub CLI installation or update process completed."

        # Main script logic
    Write-Log -Message "Starting Dotnet workload update process."

    # Install or update .NET SDK and Runtime
    UpdateDotNetWorkloads

    Write-Log -Message "Dotnet workload update process completed."
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
    try {
        $psVersion = $null
        if (Get-Command pwsh -ErrorAction SilentlyContinue) {
            $psVersion = pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
        } elseif (Get-Command powershell -ErrorAction SilentlyContinue) {
            $psVersion = powershell -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
        }
        return $psVersion
    } catch {
        Write-Log -Message "Failed to get the installed PowerShell version: $_" -Level "ERROR"
        return $null
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
    } catch {
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
    } catch {
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
    } catch {
        Write-Log -Message "Failed to install or update GitHub CLI: $_" -Level "ERROR"
    }
}

# Function to install or update .NET SDK and runtime using winget
function UpdateDotNetWorkloads {
    try {

        Write-Log -Message "Updating Dotnet workloads..."
        dotnet workload update
        Write-Log -Message "Workloads have been completed successfully."

    } catch {
        Write-Log -Message "Failed to update Dotnet workloads: $_" -Level "ERROR"
    }
}

update-dependencies