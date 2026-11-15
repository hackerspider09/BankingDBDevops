$envFile = Join-Path $PSScriptRoot ".env"

if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        # Skip empty lines and comments
        if ($line -and -not $line.StartsWith("#")) {
            # Split at the first '=' only (preserves '=' inside values like base64 strings)
            $key, $value = $line -split '=', 2
            $key = $key.Trim()
            # Remove surrounding single or double quotes
            $value = $value.Trim().Trim('"').Trim("'")
            
            # Set as a process-level environment variable
            Set-Item -Path "Env:\$key" -Value $value
        }
    }
}

Write-Output "DB server: $env:dbServerName"

dotnet build ../../Source/ReportingDB /p:BankingDatabaseName=BankingDB

# SqlPackage /Action:Script `
#   /SourceFile:"../../Source/ReportingDB/bin/Debug/ReportingDB.dacpac" `
#   /Profile:"../../Source/ReportingDB/ReportingDB_Dev.publish.xml" `
#   /TargetServerName:"$env:dbServerName" `
#   /TargetUser:"$env:dbServerUsername" `
#   /TargetPassword:"$env:dbServerPassword" `
#   /TargetEncryptConnection:True `
#   /TargetTrustServerCertificate:True `
#   /v:BankingDB="BankingDB" `
#   /OutputPath:"./ReportingDB-deployment.sql"


SqlPackage /Action:DeployReport `
  /SourceFile:"../../Source/ReportingDB/bin/Debug/ReportingDB.dacpac" `
  /Profile:"../../Source/ReportingDB/ReportingDB_Dev.publish.xml" `
  /TargetServerName:"$env:dbServerName" `
  /TargetUser:"$env:dbServerUsername" `
  /TargetPassword:"$env:dbServerPassword" `
  /TargetEncryptConnection:True `
  /TargetTrustServerCertificate:True `
  /v:BankingDB="BankingDB" `
  /OutputPath:"./ReportingDB-deployment-report.xml"