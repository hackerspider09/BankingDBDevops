[CmdletBinding()]
param (
    [Parameter()]
    [string]$Local_DataSource = "localhost",

    [Parameter()]
    [string]$LocalDbUser = "sa",

    [Parameter(Mandatory)]
    [string]$LocalDbPassword,

    [Parameter(Mandatory)]
    [string]$LinkedServerName,

    [Parameter()]
    [string]$RemoteDataSource = "localhost",

    [Parameter()]
    [string]$RemoteUser = "sa",

    [Parameter(Mandatory)]
    [string]$RemotePassword
)


Write-Host "--Link server setup--"

$T_SQL = @"
    USE [master];
    GO

    -- 1. Enable AllowInProcess and DynamicParameters for MSOLEDBSQL19
    EXEC master.dbo.sp_MSset_oledb_prop N'MSOLEDBSQL19', N'AllowInProcess', 1;
    EXEC master.dbo.sp_MSset_oledb_prop N'MSOLEDBSQL19', N'DynamicParameters', 1;
    GO

    -- 2. Drop existing linked server if it exists
    if exists ( select 1 from [master].[sys].[servers] where [name] = N'$LinkedServerName' )
        EXEC [master].[sys].[sp_dropserver] 
            @server = N'$LinkedServerName',
            @droplogins = 'droplogins';
    GO
    
    -- 3. Create linked server
    EXEC [master].[sys].[sp_addlinkedserver] 
        @server = N'$LinkedServerName',
        @srvproduct = N'',
        @provider = N'MSOLEDBSQL19',
        @datasrc = N'$RemoteDataSource',
        @provstr = N'Encrypt=Optional;TrustServerCertificate=yes;';
    GO
        
    -- 4. Map login
    EXEC [master].[dbo].[sp_addlinkedsrvlogin]
        @rmtsrvname = N'$LinkedServerName',
        @locallogin = NULL,
        @useself = N'False',
        @rmtuser     = N'$RemoteUser', 
        @rmtpassword = N'$RemotePassword';
    GO
    
    -- 5. Test linked server
    EXEC sp_testlinkedserver @servername = N'$LinkedServerName';
    SELECT 'Ping on linked server succeeded' AS Message;
    GO
"@

$tempSqlFile = [System.IO.Path]::GetTempFileName() + ".sql"
try {
    Set-Content -Path $tempSqlFile -Value $T_SQL -Encoding UTF8
    sqlcmd -S $Local_DataSource -U $LocalDbUser -P $LocalDbPassword -C -i $tempSqlFile -b
    if ($LASTEXITCODE -ne 0) {
        throw "sqlcmd failed to configure linked server with exit code $LASTEXITCODE."
    }
}
finally {
    if (Test-Path $tempSqlFile) {
        Remove-Item -Path $tempSqlFile -Force -ErrorAction SilentlyContinue
    }
}