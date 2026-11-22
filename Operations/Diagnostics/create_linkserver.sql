USE [master];
GO

-- BankingDBServerLink => this is name to link server
-- dotn forget to change user and password

-- 1. Enable AllowInProcess and DynamicParameters for MSOLEDBSQL
EXEC master.dbo.sp_MSset_oledb_prop N'MSOLEDBSQL', N'AllowInProcess', 1;
EXEC master.dbo.sp_MSset_oledb_prop N'MSOLEDBSQL', N'DynamicParameters', 1;
GO

-- 2. Drop existing linked server if it exists
IF EXISTS ( SELECT 1 FROM [master].[sys].[servers] WHERE [name] = N'BankingDBServerLink' )
    EXEC [master].[sys].[sp_dropserver] 
        @server = N'BankingDBServerLink',
        @droplogins = 'droplogins';
GO

-- 3. Create linked server
-- datasrc is ip or hostname of server on which other db exsits here it would be banking db server
EXEC [master].[sys].[sp_addlinkedserver] 
    @server = N'BankingDBServerLink',
    @srvproduct = N'',
    @provider = N'MSOLEDBSQL',
    @datasrc = N'ip_or_hostname',
    @provstr = N'Encrypt=Yes;TrustServerCertificate=Yes;';
GO
    
-- 4. Map login
EXEC [master].[dbo].[sp_addlinkedsrvlogin]
    @rmtsrvname = N'BankingDBServerLink',
    @locallogin = NULL,
    @useself = N'False',
    @rmtuser     = N'user', 
    @rmtpassword = N'password';
GO

-- 5. Test linked server
EXEC sp_testlinkedserver @servername = N'BankingDBServerLink';
SELECT 'Ping on linked server succeeded' AS Message;
GO

-- 6. Verify linked servers in sys.servers
SELECT
    name,
    product,
    provider,
    data_source
FROM sys.servers;
GO
