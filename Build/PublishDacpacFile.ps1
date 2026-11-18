#  ./PublishDacpacFile.ps1 -ProjectName "ReportingDB" -Configuration "Release" -DbName "ReportingDB" -DbServerName "localhost" -DbuserName "sa" -DbUserPassword "root" -ServerVariables "/v:BankingDB='BankingDB'"

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
    $BuildProperties,

    [Parameter(Mandatory)]
    [string]
    $DbName,
    
    [Parameter(Mandatory)]
    [string]
    $DbServerName,
    
    [Parameter(Mandatory)]
    [string]
    $DbServerUsername,

    [Parameter(Mandatory)]
    [securestring]
    $DbServerPassword,

    [Parameter()]
    [string]
    $ServerVariables

)


$ProjectWholePath = Join-Path -Path $PSScriptRoot -ChildPath "../Source/$ProjectName"

Write-Host "Project path: $ProjectWholePath"

Write-Host "Publish started..."

$DacpacPath = Join-Path -Path $ProjectWholePath -ChildPath "/bin/$Configuration/$ProjectName.dacpac"


# Convert SecureString to plain text for SqlPackage
$PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($DbServerPassword)
)

$sqlPackageArgs = @(
    "/Action:Publish",
    "/SourceFile:$DacpacPath",
    "/TargetDatabaseName:$DbName",
    "/TargetServerName:$DbServerName",
    "/TargetUser:$DbServerUsername",
    "/TargetPassword:$PlainPassword",
    "/TargetEncryptConnection:True",
    "/TargetTrustServerCertificate:True",
    "/p:AllowIncompatiblePlatform=True"
)

if ($ServerVariables) {
    foreach ($var in $ServerVariables) {
        if (-not [string]::IsNullOrWhiteSpace($var)) {
            # Split multiple /v: variables if passed in a single string
            $tokens = [regex]::Split($var.Trim(), '(?=\s+/v:)') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
            $sqlPackageArgs += $tokens
        }
    }
}

SqlPackage @sqlPackageArgs

