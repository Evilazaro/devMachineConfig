param (
    [Parameter(Mandatory = $true)]
    [Int16]$step
)

Set-ExecutionPolicy Bypass -Scope Process -Force; 

function InstallWinGet {

    $PsInstallScope = "CurrentUser"
    Write-Host "Installing powershell modules in scope: $PsInstallScope"

    # ensure NuGet provider is installed
    if (!(Get-PackageProvider | Where-Object { $_.Name -eq "NuGet" -and $_.Version -gt "2.8.5.201" })) {
        Write-Host "Installing NuGet provider"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope $PsInstallScope
        Write-Host "Done Installing NuGet provider"
    }
    else {
        Write-Host "NuGet provider is already installed"
    }

    # Set PSGallery installation policy to trusted
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    pwsh.exe -MTA -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"

    # check if the Microsoft.Winget.Client module is installed
    if (!(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
        Write-Host "Installing Microsoft.Winget.Client"
        Install-Module Microsoft.WinGet.Client -Scope $PsInstallScope
        pwsh.exe -MTA -Command "Install-Module Microsoft.WinGet.Client -Scope $PsInstallScope"
        Write-Host "Done Installing Microsoft.Winget.Client"
    }
    else {
        Write-Host "Microsoft.Winget.Client is already installed"
    }

    # check if the Microsoft.WinGet.Configuration module is installed
    if (!(Get-Module -ListAvailable -Name Microsoft.WinGet.Configuration)) {
        Write-Host "Installing Microsoft.WinGet.Configuration"
        pwsh.exe -MTA -Command "Install-Module Microsoft.WinGet.Configuration -AllowPrerelease -Scope $PsInstallScope"
        Write-Host "Done Installing Microsoft.WinGet.Configuration"
    }
    else {
        Write-Host "Microsoft.WinGet.Configuration is already installed"
    }

    Write-Host "Updating WinGet"
    try {
        Write-Host "Attempting to repair WinGet Package Manager"
        Repair-WinGetPackageManager -Latest -Force
        Write-Host "Done Reparing WinGet Package Manager"
    }
    catch {
        Write-Host "Failed to repair WinGet Package Manager"
        Write-Error $_
    }

    if ($PsInstallScope -eq "CurrentUser") {
        $msUiXamlPackage = Get-AppxPackage -Name "Microsoft.UI.Xaml.2.8" | Where-Object { $_.Version -ge "8.2310.30001.0" }
        if (!($msUiXamlPackage)) {
            # instal Microsoft.UI.Xaml
            try {
                Write-Host "Installing Microsoft.UI.Xaml"
                $architecture = "x64"
                if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
                    $architecture = "arm64"
                }
                $MsUiXaml = "$env:TEMP\$([System.IO.Path]::GetRandomFileName())-Microsoft.UI.Xaml.2.8.6"
                $MsUiXamlZip = "$($MsUiXaml).zip"
                Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6" -OutFile $MsUiXamlZip
                Expand-Archive $MsUiXamlZip -DestinationPath $MsUiXaml
                Add-AppxPackage -Path "$($MsUiXaml)\tools\AppX\$($architecture)\Release\Microsoft.UI.Xaml.2.8.appx" -ForceApplicationShutdown
                Write-Host "Done Installing Microsoft.UI.Xaml"
            }
            catch {
                Write-Host "Failed to install Microsoft.UI.Xaml"
                Write-Error $_
            }
        }

        $desktopAppInstallerPackage = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller"
        if (!($desktopAppInstallerPackage) -or ($desktopAppInstallerPackage.Version -lt "1.22.0.0")) {
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

        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Host "WinGet version: $(winget -v)"
    }

    # Revert PSGallery installation policy to untrusted
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Untrusted
    pwsh.exe -MTA -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted"

}


function installWSL {
    runWinGet -id "Microsoft.WSL" -message "Installing WSL"
    runWinGet -id "9PDXGNCFSCZV" -message "Installing Ubuntu"
}


function installAllToolsAndApps {
    winget import -i .\configDevMachine.json --accept-package-agreements --accept-source-agreements
}

function runWinGet {
    param (
        [Parameter(Mandatory = $true)]
        [string]$id,
        [Parameter(Mandatory = $true)]
        [string]$message,
        [string]$source = "winget"
    )

    Write-Host $message
    winget install -e --id $id --source $source --accept-package-agreements --accept-source-agreements 

}

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
        Write-Host "VSCode extensions have been installed successfully."
    }
    catch {
        Write-Host "Failed to install VSCode extensions: $_" -Level "ERROR"
    }
}

function installWindowsupdates {
    Write-Host "Installing Windows updates..."
    try {
        # Install the PSWindowsUpdate module
        Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
    
        # Import the module
        Import-Module PSWindowsUpdate
    
        # Check for updates
        $updates = Get-WindowsUpdate
    
        # Install all available updates
        if ($updates) {
            Install-WindowsUpdate -AcceptAll -AutoReboot -Verbose | Out-File "$($env:TEMP)\WindowsUpdateLog.txt"
            Write-Host "Updates installed successfully. System will reboot if required."
        }
        else {
            Write-Host "No updates available."
        }
    }
    catch {
        Write-Error "An error occurred: $_"
    }
    
    Write-Host "Windows updates have been installed successfully."

}

function installWSL {
    Write-Host "Installing WSL..."
    # Enable WSL
    wsl --install -d Ubuntu
    Write-Host "WSL has been installed successfully."
}

function WithRetry {
    Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Position = 1, Mandatory = $false)]
        [int]$Maximum = 5,

        [Parameter(Position = 2, Mandatory = $false)]
        [int]$Delay = 100
    )

    $iterationCount = 0
    $lastException = $null
    do {
        $iterationCount++
        try {
            Invoke-Command -Command $ScriptBlock
            return
        }
        catch {
            $lastException = $_
            Write-Error $_

            # Sleep for a random amount of time with exponential backoff
            $randomDouble = Get-Random -Minimum 0.0 -Maximum 1.0
            $k = $randomDouble * ([Math]::Pow(2.0, $iterationCount) - 1.0)
            Start-Sleep -Milliseconds ($k * $Delay)
        }
    } while ($iterationCount -lt $Maximum)

    throw $lastException
}


function InstallPS7 {
    if (!(Get-Command pwsh -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PowerShell 7"
        $code = Invoke-RestMethod -Uri https://aka.ms/install-powershell.ps1
        $null = New-Item -Path function:Install-PowerShell -Value $code
        WithRetry -ScriptBlock {
            if ("$($PsInstallScope)" -eq "CurrentUser") {
                Install-PowerShell -UseMSI
            }
            else {
                # The -Quiet flag requires admin permissions
                Install-PowerShell -UseMSI -Quiet
            }
        } -Maximum 5 -Delay 100
        # Need to update the path post install
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Host "Done Installing PowerShell 7"
    }
    else {
        Write-Host "PowerShell 7 is already installed"
    }
}

function Step1 {
    try {
        Clear-Host
        Write-Host "Step 1: Installing PowerShell 7, WinGet and WSL"
        InstallPS7
        InstallWinGet
        installWSL
        write-host "Restarting computer..."
        Start-Sleep 5
        Restart-Computer
    }
    catch {
        Write-Error $_
    }
}

function Step2 {
    try {
        Clear-Host
        Write-Host "Step 2: SDKs, IDEs, Tools and applications"
        installAllToolsAndApps
        Start-Sleep 5
        Restart-Computer
    }
    catch {
        Write-Error $_
    }
}

function step3 {
    try {
        Clear-Host
        Write-Host "Step 3: Installing VSCode extensions and updating DotNet workloads"
        InstallVSCodeExtensions
        UpdateDotNetWorkloads
    }
    catch {
        write-Error $_
    }
}

function configureDevMachine {

    switch ($step) {
        1 { Step1 }
        2 { Step2 }
        3 { Step3 }
        default { Write-Host "Invalid step number" }
    }
}

configureDevMachine