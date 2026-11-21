<#
.SYNOPSIS
    Packs a SQL project's DACPAC into a NuGet package using dotnet pack.
    Package metadata (id, authors, description) lives in the .sqlproj PropertyGroup.

.EXAMPLE
    ./Build/Pack-DatabaseNuGet.ps1 -ProjectName "BankingDB"  -Version "1.2.3"
    ./Build/Pack-DatabaseNuGet.ps1 -ProjectName "ReportingDB" -Version "1.2.3"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ProjectName,

    [Parameter(Mandatory)]
    [string]$Version,

    [Parameter()]
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [Parameter()]
    # Defaults to <repo-root>/artifacts — anchored to script location so it's
    # consistent whether called from repo root, Build/, or CI runner
    [string]$OutputDir = (Join-Path $PSScriptRoot "..\artifacts")
)

$ErrorActionPreference = "Stop"

$projectPath = Join-Path $PSScriptRoot "..\Source\$ProjectName\$ProjectName.sqlproj"

Write-Host "=== Packing NuGet for $ProjectName v$Version ==="
Write-Host "  Project : $projectPath"
Write-Host "  Config  : $Configuration"
Write-Host "  Output  : $OutputDir"

if (-not (Test-Path $projectPath)) {
    throw "Project not found: $projectPath"
}

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

dotnet pack $projectPath `
    --configuration $Configuration `
    /p:Version=$Version `
    --output $OutputDir `
    --no-build

if ($LASTEXITCODE -ne 0) {
    throw "dotnet pack failed for $ProjectName (exit code $LASTEXITCODE)"
}

Write-Host "=== Pack complete for $ProjectName ==="
