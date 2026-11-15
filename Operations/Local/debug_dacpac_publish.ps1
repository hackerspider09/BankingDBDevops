
Write-Output "DB server: $env:dbServerName"

# build db project
dotnet build ../../Source/BankingDB
dotnet build ../../Source/ReportingDB /p:BankingDatabaseName=BankingDB





# publish banking db
# SqlPackage /Action:Publish `
#   /SourceFile:"../../Source/BankingDB/bin/Debug/BankingDB.dacpac" `
#   /Profile:"../../Source/BankingDB/BankingDB_Dev.publish.xml" `
#   /TargetServerName:"$env:dbServerName" `
#   /TargetUser:"$env:dbServerUsername" `
#   /TargetPassword:"$env:dbServerPassword" `
#   /TargetEncryptConnection:True `
#   /TargetTrustServerCertificate:True
  

  # publish Report db
  SqlPackage /Action:Publish `
  /SourceFile:"../../Source/ReportingDB/bin/Debug/ReportingDB.dacpac" `
  /Profile:"../../Source/ReportingDB/ReportingDB_Dev.publish.xml" `
  /TargetServerName:"$env:dbServerName" `
  /TargetUser:"$env:dbServerUsername" `
  /TargetPassword:"$env:dbServerPassword" `
  /TargetEncryptConnection:True `
  /TargetTrustServerCertificate:True `
  /v:BankingDB="BankingDB" `
  /v:BankingDBServer="BankingDBServerLink"

