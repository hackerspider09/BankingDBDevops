# https://learn.microsoft.com/en-us/powershell/module/sqlserver/invoke-sqlcmd?view=sqlserver-ps
# https://learn.microsoft.com/en-us/sql/relational-databases/linked-servers/create-linked-servers-sql-server-database-engine?view=sql-server-ver17
# addlinkserver: https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-addlinkedserver-transact-sql?view=sql-server-ver17


# this should be run from server where link server needs to create (here its on reportingDB)
$LocalInstance = "localhost" # local server hostname or ip (ReportingDB)
$LinkedServerName = "BankingDBServerLink"
$RemoteDataSource = "localhost"  # remote server hostname or ip (BankingDB)
$RemoteUser       = "username"
$RemotePassword   = "password"


Write-Host "--Link server setup--"

$T_SQL = @"
    USE [master];
    GO

    if exists ( select 1 from [master].[sys].[servers] where [name] = N'$LinkedServerName' )
        EXEC [master].[sys].[sp_dropserver] 
            @server = N'$LinkedServerName',
            @droplogins = 'droplogins';
    
    EXEC [master].[sys].[sp_addlinkedserver] 
        @server = N'$LinkedServerName',
        @srvproduct = N'',
        @provider = N'MSOLEDBSQL19',
        @datasrc = N'$RemoteDataSource',
        @provstr = N'Encrypt=Optional;';
        
    EXEC [master].[dbo].[sp_addlinkedsrvlogin]
        @rmtsrvname = N'$LinkedServerName',
        @locallogin = NULL,
        @useself = N'False',
        @rmtuser     = N'$RemoteUser', 
        @rmtpassword = N'$RemotePassword';
    
    begin try
        EXEC sp_testlinkedserver N'$LinkedServerName';
        SELECT 'Ping on linked server succeeded' AS Message;
    end try
    begin catch
        select 'Ping on linkserver failed' as Message;
        throw;
    end catch;
"@

Invoke-SqlCmd -ServerInstance $Local_DataSource `
              -Username $LocalDbUser `
              -Password $LocalDbPassword `
              -Query $T_SQL