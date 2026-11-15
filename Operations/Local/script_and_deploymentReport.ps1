
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