#  ./BuildProjects.ps1 -ProjectName "ReportingDB" -Configuration "Release" -BuildProperties "/p:BankingDatabaseName=BankingDB"

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $ProjectName,

    [Parameter()]
    [string]
    $Configuration = "Debug",

    [Parameter()]
    [string[]]
    $BuildProperties
)


$ProjectWholePath = Join-Path -Path $PSScriptRoot -ChildPath "../Source/$ProjectName"

Write-Host "Project path: $ProjectWholePath"

Write-Host "Building started..."
dotnet build $ProjectWholePath -c $Configuration $BuildProperties


$DacpacPath = Join-Path -Path $ProjectWholePath -ChildPath "/bin/$Configuration/$ProjectName.dacpac"

if (Test-Path -Path $DacpacPath -PathType Leaf) {
    Write-Host "Dacpac for $ProjectName is present."
} else {
    Write-Host "Dacpac for $ProjectName is not present."
}
