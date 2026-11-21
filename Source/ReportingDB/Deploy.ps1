<#
.SYNOPSIS
    Octopus Deploy script for ReportingDB.
    Called by Octopus after the NuGet package is extracted.

.DESCRIPTION
    Uses variables injected by Octopus Deploy following the convention:
      DB_<DBName>_Server       - SQL Server hostname/IP
      DB_<DBName>_Name         - Target database name
      DB_<DBName>_Username     - SQL login username
      DB_<DBName>_Password     - SQL login password (sensitive)

    For ReportingDB the variables are:
      DB_ReportingDB_Server
      DB_ReportingDB_Name
      DB_ReportingDB_Username
      DB_ReportingDB_Password

    ReportingDB also needs the BankingDB cross-database reference resolved via SQLCMD variables:
      DB_BankingDB_Name        - The BankingDB database name (re-used from BankingDB convention)
      DB_BankingDB_LinkServer  - The linked server name pointing to the BankingDB SQL Server
#>

[CmdletBinding()]
param ()

$ErrorActionPreference = "Stop"

# --- Read Octopus variables ---
$dbServer      = $OctopusParameters["DB_ReportingDB_Server"]
$dbName        = $OctopusParameters["DB_ReportingDB_Name"]
$dbUser        = $OctopusParameters["DB_ReportingDB_Username"]
$dbPassword    = $OctopusParameters["DB_ReportingDB_Password"]

# Cross-DB reference variables (SQLCMD vars passed to sqlpackage)
$bankingDbName       = $OctopusParameters["DB_BankingDB_Name"]
$bankingDbLinkServer = $OctopusParameters["DB_BankingDB_LinkServer"]

# Resolve dacpac path
$packageRoot = $PSScriptRoot
$dacpacPath  = Join-Path $packageRoot "tools\ReportingDB.dacpac"

if (-not (Test-Path $dacpacPath)) {
    throw "DACPAC not found at: $dacpacPath"
}

Write-Host "=== Deploying ReportingDB ==="
Write-Host "  Server          : $dbServer"
Write-Host "  Database        : $dbName"
Write-Host "  DACPAC          : $dacpacPath"
Write-Host "  BankingDB Name  : $bankingDbName"
Write-Host "  BankingDB Link  : $bankingDbLinkServer"

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
    "/p:BlockOnPossibleDataLoss=False",
    "/v:BankingDB=$bankingDbName",
    "/v:BankingDBServer=$bankingDbLinkServer"
)

Write-Host "Running SqlPackage..."
SqlPackage @sqlPackageArgs

Write-Host "=== ReportingDB deployment complete ==="
