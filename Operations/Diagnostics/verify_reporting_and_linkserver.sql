USE [ReportingDB];
GO

-- ============================================================================
-- 1. Verify Linked Server Configuration
-- ============================================================================
SELECT
    server_id,
    name,
    product,
    provider,
    data_source,
    is_linked
FROM sys.servers
WHERE name = 'BankingDBServerLink';
GO

-- ============================================================================
-- 2. Inspect What Databases Actually Exist on the Remote Server (54.81.28.107)
-- ============================================================================
-- If BankingDB does not appear in this list, the database has not been created yet!
SELECT name AS RemoteDatabaseName, state_desc, create_date
FROM [BankingDBServerLink].[master].[sys].[databases];
GO

-- ============================================================================
-- 3. Inspect What Tables Exist in BankingDB on the Remote Server
-- ============================================================================
-- If this returns 0 rows, the DACPAC / tables have not been deployed yet.
SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
FROM [BankingDBServerLink].[BankingDB].[INFORMATION_SCHEMA].[TABLES];
GO

-- ============================================================================
-- 4. Test Query on Transactions Table
-- ============================================================================
SELECT TOP 5
    TransactionID,
    AccountID,
    Amount,
    TransactionType,
    TransactionDate
FROM [BankingDBServerLink].[BankingDB].[dbo].[Transactions];
GO

-- ============================================================================
-- 5. Execute Stored Procedure (ReportingDB)
-- ============================================================================
-- Uses unambiguous ISO format YYYY-MM-DD
EXEC dbo.usp_GenerateDailyReport @ReportDate = '2026-11-22';
GO

-- ============================================================================
-- 6. Check Generated Report in DailyReports Table
-- ============================================================================
SELECT TOP 10
    ReportID,
    ReportDate,
    TotalDeposits,
    TotalWithdrawals,
    TotalTransactions,
    GeneratedAt
FROM dbo.DailyReports
ORDER BY ReportDate DESC;
GO
