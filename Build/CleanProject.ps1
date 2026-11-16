# .\CleanProject.ps1 -ProjectName ReportingDB -Configuration Release

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $ProjectName,

    [Parameter()]
    [string]
    $Configuration = "Debug"
)


$ProjectWholePath = Join-Path -Path $PSScriptRoot -ChildPath "../Source/$ProjectName"

Write-Host "Project path: $ProjectWholePath"

Write-Host "Cleaning started..."
dotnet clean $ProjectWholePath -c $Configuration 


$DacpacPath = Join-Path -Path $ProjectWholePath -ChildPath "/bin/$Configuration/$ProjectName.dacpac"

if (Test-Path -Path $DacpacPath -PathType Leaf) {
    Write-Host "Dacpac for $ProjectName is still present."
} else {
    Write-Host "Dacpac for $ProjectName is removed."
}
