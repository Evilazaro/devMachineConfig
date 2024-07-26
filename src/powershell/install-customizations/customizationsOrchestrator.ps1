param(
    [Parameter(Mandatory=$true, HelpMessage="Please provide the installation step number between 1 and 3.")]
    [int]$step = 1
)

function executePowerShellScript {
    param(
        [Parameter(Mandatory=$true, HelpMessage="Please provide the script content.")]
        [string]$url
    )
    
    $scriptContent = Invoke-WebRequest -Uri $url -UseBasicParsing
    
    # Execute the script
    Invoke-Expression $scriptContent.Content
}

Set-ExecutionPolicy Bypass -Scope Process -Force; 

switch ($step) {
    1 {
        .\\install-winget\installWinget.ps1
        .\\install-wsl\installWSL.ps1     
    }
    2 {
        .\\install-ubuntu\installUbuntu.ps1
        .\\install-winget-packages\installWingetPackages.ps1        
    }
    3 {
        .\\install-vs-extensions\installVSCodeExtensions.ps1
        .\\update-dotnet-workloads\updateDotNetWorkloads.ps1
        .\\update-winget-packages\updateWingetPackages.ps1
    }
    default {
        Write-Host "Invalid step number. Please provide a valid step number." -Level "ERROR"
    }
}