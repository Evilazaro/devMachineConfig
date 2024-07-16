param (
    [Parameter(Mandatory = $true)]
    [Int16]$step
)

Set-ExecutionPolicy Bypass -Scope Process -Force

# Function to install WinGet
function InstallWinGet {
    $PsInstallScope = "CurrentUser"
    Write-Host "Installing PowerShell modules in scope: $PsInstallScope"

    # Ensure NuGet provider is installed
    if (-not (Get-PackageProvider | Where-Object { $_.Name -eq "NuGet" -and $_.Version -gt "2.8.5.201" })) {
        Write-Host "Installing NuGet provider"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope $PsInstallScope
        Write-Host "NuGet provider installation complete"
    } else {
        Write-Host "NuGet provider is already installed"
    }

    # Set PSGallery installation policy to trusted
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

    # Install Microsoft.Winget.Client module if not already installed
    if (-not (Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
        Write-Host "Installing Microsoft.Winget.Client"
        Install-Module Microsoft.WinGet.Client -Scope $PsInstallScope
        Write-Host "Microsoft.Winget.Client installation complete"
    } else {
        Write-Host "Microsoft.Winget.Client is already installed"
    }

    # Install Microsoft.WinGet.Configuration module if not already installed
    if (-not (Get-Module -ListAvailable -Name Microsoft.WinGet.Configuration)) {
        Write-Host "Installing Microsoft.WinGet.Configuration"
        Install-Module Microsoft.WinGet.Configuration -AllowPrerelease -Scope $PsInstallScope
        Write-Host "Microsoft.WinGet.Configuration installation complete"
    } else {
        Write-Host "Microsoft.WinGet.Configuration is already installed"
    }

    # Update WinGet
    Write-Host "Updating WinGet"
    try {
        Write-Host "Attempting to repair WinGet Package Manager"
        Repair-WinGetPackageManager -Latest -Force
        Write-Host "WinGet Package Manager repair complete"
    } catch {
        Write-Error "Failed to repair WinGet Package Manager: $_"
    }

    if ($PsInstallScope -eq "CurrentUser") {
        $msUiXamlPackage = Get-AppxPackage -Name "Microsoft.UI.Xaml.2.8" | Where-Object { $_.Version -ge "8.2310.30001.0" }
        if (-not $msUiXamlPackage) {
            # Install Microsoft.UI.Xaml
            try {
                Write-Host "Installing Microsoft.UI.Xaml"
                $architecture = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
                $MsUiXaml = "$env:TEMP\$([System.IO.Path]::GetRandomFileName())-Microsoft.UI.Xaml.2.8.6"
                $MsUiXamlZip = "$MsUiXaml.zip"
                Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6" -OutFile $MsUiXamlZip
                Expand-Archive $MsUiXamlZip -DestinationPath $MsUiXaml
                Add-AppxPackage -Path "$MsUiXaml\tools\AppX\$architecture\Release\Microsoft.UI.Xaml.2.8.appx" -ForceApplicationShutdown
                Write-Host "Microsoft.UI.Xaml installation complete"
            } catch {
                Write-Error "Failed to install Microsoft.UI.Xaml: $_"
            }
        }

        $desktopAppInstallerPackage = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller"
        if (-not $desktopAppInstallerPackage -or $desktopAppInstallerPackage.Version -lt "1.22.0.0") {
            # Install Microsoft.DesktopAppInstaller
            try {
                Write-Host "Installing Microsoft.DesktopAppInstaller"
                $DesktopAppInstallerAppx = "$env:TEMP\$([System.IO.Path]::GetRandomFileName())-DesktopAppInstaller.appx"
                Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $DesktopAppInstallerAppx
                Add-AppxPackage -Path $DesktopAppInstallerAppx -ForceApplicationShutdown
                Write-Host "Microsoft.DesktopAppInstaller installation complete"
            } catch {
                Write-Error "Failed to install DesktopAppInstaller appx package: $_"
            }
        }

        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Host "WinGet version: $(winget -v)"
    }

    # Revert PSGallery installation policy to untrusted
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
}

# Function to install WSL
function InstallWSL {
    Write-Host "Installing WSL..."
    try {
        wsl --install -d Ubuntu
        Write-Host "WSL has been installed successfully."
    } catch {
        Write-Error "Failed to install WSL: $_"
    }
}

# Function to install all tools and apps
function InstallAllToolsAndApps {
    Write-Host "Installing all tools and apps..."
    try {
        winget import -i .\configDevMachine.json --accept-package-agreements --accept-source-agreements
        Write-Host "All tools and apps installed successfully."
    } catch {
        Write-Error "Failed to install tools and apps: $_"
    }
}

# Function to run WinGet with retry mechanism
function RunWinGet {
    param (
        [Parameter(Mandatory = $true)]
        [string]$id,
        [Parameter(Mandatory = $true)]
        [string]$message,
        [string]$source = "winget"
    )

    Write-Host $message
    try {
        winget install -e --id $id --source $source --accept-package-agreements --accept-source-agreements
        Write-Host "$message completed successfully."
    } catch {
        Write-Error "Failed to run WinGet for $id: $_"
    }
}

# Function to update .NET workloads
function UpdateDotNetWorkloads {
    Write-Host "Updating .NET workloads..."
    try {
        dotnet workload update
        Write-Host "Workloads updated successfully."
    } catch {
        Write-Error "Failed to update .NET workloads: $_"
    }
}

# Function to install VSCode extensions
function InstallVSCodeExtensions {
    Write-Host "Installing VSCode extensions..."
    try {
        $extensions = @(
            'ms-vscode-remote.remote-wsl',
            'ms-vscode.PowerShell',
            'ms-vscode.vscode-node-azure-pack',
            'GitHub.copilot',
            'GitHub.vscode-pull-request-github',
            'GitHub.copilot-chat',
            'GitHub.remotehub',
            'GitHub.vscode-github-actions',
            'eamodio.gitlens-insiders',
            'ms-vscode.azure-repos',
            'ms-azure-devops.azure-pipelines',
            'ms-azuretools.vscode-docker',
            'ms-kubernetes-tools.vscode-kubernetes-tools',
            'ms-kubernetes-tools.vscode-aks-tools',
            'ms-azuretools.vscode-azurecontainerapps',
            'ms-azuretools.vscode-azurefunctions',
            'ms-azuretools.vscode-apimanagement'
        )

        foreach ($extension in $extensions) {
            code --install-extension $extension --force
        }
        Write-Host "VSCode extensions installed successfully."
    } catch {
        Write-Error "Failed to install VSCode extensions: $_"
    }
}

# Function to install Windows updates
function InstallWindowsUpdates {
    Write-Host "Installing Windows updates..."
    try {
        Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
        Import-Module PSWindowsUpdate
        $updates = Get-WindowsUpdate
        if ($updates) {
            Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose | Out-File "$env:TEMP\WindowsUpdateLog.txt"
            Write-Host "Updates installed successfully. System will reboot if required."
        } else {
            Write-Host "No updates available."
        }
    } catch {
        Write-Error "Failed to install Windows updates: $_"
    }
}

# Function to retry a script block
function WithRetry {
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        [Parameter(Mandatory = $false)]
        [int]$Maximum = 5,
        [Parameter(Mandatory = $false)]
        [int]$Delay = 100
    )

    $iterationCount = 0
    $lastException = $null
    do {
        $iterationCount++
        try {
            Invoke-Command -ScriptBlock $ScriptBlock
            return
        } catch {
            $lastException = $_
            Write-Error $_
            $randomDouble = Get-Random -Minimum 0.0 -Maximum 1.0
            $k = $randomDouble * ([Math]::Pow(2.0, $iterationCount) - 1.0)
            Start-Sleep -Milliseconds ($k * $Delay)
        }
    } while ($iterationCount -lt $Maximum)

    throw $lastException
}

# Function to install PowerShell 7
function InstallPS7 {
    if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PowerShell 7"
        $code = Invoke-RestMethod -Uri https://aka.ms/install-powershell.ps1
        $null = New-Item -Path function:Install-PowerShell -Value $code
        WithRetry -ScriptBlock {
            if ($PsInstallScope -eq "CurrentUser") {
                Install-PowerShell -UseMSI
            } else {
                Install-PowerShell -UseMSI -Quiet
            }
        } -Maximum 5 -Delay 100
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Host "PowerShell 7 installation complete"
    } else {
        Write-Host "PowerShell 7 is already installed"
    }
}

# Function to install Visual Studio workloads
function InstallVSWorkloads {
    Write-Host "Installing Visual Studio workloads..."
    try {
        $workloads = "--add Microsoft.VisualStudio.Workload.CoreEditor --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Azure"
        winget install -e --id "Microsoft.VisualStudio.2022.Enterprise" --source "winget" --accept-package-agreements --accept-source-agreements --silent --force --override $workloads
        Write-Host "Visual Studio workloads installed successfully."
    } catch {
        Write-Error "Failed to install Visual Studio workloads: $_"
    }
}

# Function to handle step 1
function Step1 {
    InstallPS7
    InstallWinGet
    InstallWSL
    Restart-Computer
}

# Function to handle step 2
function Step2 {
    InstallAllToolsAndApps
    Restart-Computer
}

# Function to handle step 3
function Step3 {
    InstallVSWorkloads
    InstallVSCodeExtensions
    UpdateDotNetWorkloads
}

# Function to configure the development machine based on step parameter
function ConfigureDevMachine {
    switch ($step) {
        1 { Step1 }
        2 { Step2 }
        3 { Step3 }
        default { Write-Host "Invalid step number" }
    }
}

# Start configuration based on step parameter
ConfigureDevMachine
