function Update-WingetPackages()
{
    # Update winget packages
    winget upgrade --all
}

function Update-DotNetWorkloads()
{
    dotnet workload
    # Update .NET workloads
    dotnet workload update
}

Update-WingetPackages
Update-DotNetWorkloads