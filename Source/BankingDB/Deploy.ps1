<#
.SYNOPSIS
    Octopus Deploy script for BankingDB.
    Called by Octopus after the NuGet package is extracted.

.DESCRIPTION
    Uses variables injected by Octopus Deploy following the convention:
      DB_<DBName>_Server       - SQL Server hostname/IP
      DB_<DBName>_Name         - Target database name
      DB_<DBName>_Username     - SQL login username
      DB_<DBName>_Password     - SQL login password (sensitive)

    For BankingDB the variables are:
      DB_BankingDB_Server
      DB_BankingDB_Name
      DB_BankingDB_Username
      DB_BankingDB_Password
#>

[CmdletBinding()]
param ()

$ErrorActionPreference = "Stop"

# --- Read Octopus variables (injected as environment variables by Octopus) ---
$dbServer   = $OctopusParameters["DB_BankingDB_Server"]
$dbName     = $OctopusParameters["DB_BankingDB_Name"]
$dbUser     = $OctopusParameters["DB_BankingDB_Username"]
$dbPassword = $OctopusParameters["DB_BankingDB_Password"]

# Resolve path to the dacpac inside the extracted package
$packageRoot = $PSScriptRoot
$dacpacPath  = Join-Path $packageRoot "content\BankingDB.dacpac"

if (-not (Test-Path $dacpacPath)) {
    throw "DACPAC not found at: $dacpacPath"
}

Write-Host "=== Deploying BankingDB ==="
Write-Host "  Server   : $dbServer"
Write-Host "  Database : $dbName"
Write-Host "  DACPAC   : $dacpacPath"

$sqlPackageArgs = @(
    "/Action:Publish",
    "/SourceFile:$dacpacPath",
    "/TargetDatabaseName:$dbName",
    "/TargetServerName:$dbServer",
    "/TargetUser:$dbUser",
    "/TargetPassword:$dbPassword",
    "/TargetEncryptConnection:True",
    "/TargetTrustServerCertificate:True",
    "/p:AllowIncompatiblePlatform=True",
    "/p:BlockOnPossibleDataLoss=False"
)

Write-Host "Running SqlPackage..."
SqlPackage @sqlPackageArgs

Write-Host "=== BankingDB deployment complete ==="
