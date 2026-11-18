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

# Escape any single quotes in passwords or names to prevent T-SQL syntax errors
$EscapedRemotePassword = $RemotePassword -replace "'", "''"
$EscapedRemoteUser = $RemoteUser -replace "'", "''"

$T_SQL = @"
    USE [master];
    GO

    -- 1. Enable AllowInProcess and DynamicParameters for MSOLEDBSQL
    EXEC master.dbo.sp_MSset_oledb_prop N'MSOLEDBSQL', N'AllowInProcess', 1;
    EXEC master.dbo.sp_MSset_oledb_prop N'MSOLEDBSQL', N'DynamicParameters', 1;
    GO

    -- 2. Drop existing linked server if it exists
    IF EXISTS ( SELECT 1 FROM [master].[sys].[servers] WHERE [name] = N'$LinkedServerName' )
        EXEC [master].[sys].[sp_dropserver] 
            @server = N'$LinkedServerName',
            @droplogins = 'droplogins';
    GO
    
    -- 3. Create linked server
    EXEC [master].[sys].[sp_addlinkedserver] 
        @server = N'$LinkedServerName',
        @srvproduct = N'',
        @provider = N'MSOLEDBSQL',
        @datasrc = N'$RemoteDataSource',
        @provstr = N'Encrypt=Yes;TrustServerCertificate=Yes;';
    GO
        
    -- 4. Map login
    EXEC [master].[dbo].[sp_addlinkedsrvlogin]
        @rmtsrvname = N'$LinkedServerName',
        @locallogin = NULL,
        @useself = N'False',
        @rmtuser     = N'$EscapedRemoteUser', 
        @rmtpassword = N'$EscapedRemotePassword';
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
