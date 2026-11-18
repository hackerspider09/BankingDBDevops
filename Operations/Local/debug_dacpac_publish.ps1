
Write-Output "DB server: $env:dbServerName"

# build db project
dotnet build ../../Source/BankingDB
dotnet build ../../Source/ReportingDB /p:BankingDatabaseName=BankingDB





# publish banking db
# SqlPackage /Action:Publish `
#   /SourceFile:"../../Source/BankingDB/bin/Debug/BankingDB.dacpac" `
#   /TargetDatabaseName:"BankingDB" `
#   /TargetServerName:"$env:dbServerName" `
#   /TargetUser:"$env:dbServerUsername" `
#   /TargetPassword:"$env:dbServerPassword" `
#   /TargetEncryptConnection:True `
#   /TargetTrustServerCertificate:True `
  # /p:AllowIncompatiblePlatform=True
  

  # publish Report db
  SqlPackage /Action:Publish `
  /SourceFile:"../../Source/ReportingDB/bin/Debug/ReportingDB.dacpac" `
  /TargetDatabaseName:"ReportingDB" `
  /TargetServerName:"$env:dbServerName" `
  /TargetUser:"$env:dbServerUsername" `
  /TargetPassword:"$env:dbServerPassword" `
  /TargetEncryptConnection:True `
  /TargetTrustServerCertificate:True `
  /p:AllowIncompatiblePlatform=True `
  /v:BankingDB="BankingDB" `
  /v:BankingDBServer="BankingDBServerLink"

