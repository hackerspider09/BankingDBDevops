
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$SqlProjectName,

    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug",

    # Switch parameter: acts as a true/false flag (no value needed when called)
    [switch]$Force
)

$ProjectWholePath = Join-Path -Path $PSScriptRoot -ChildPath "../../Source/$SqlProjectName"

Write-Output "Project path $ProjectWholePath"


Write-Output "Ziping Dacpac $ProjectWholePath"
Compress-Archive -Path "C:\path\file1.txt", "C:\path\file2.jpg" -DestinationPath "C:\path\to\archive.zip"
