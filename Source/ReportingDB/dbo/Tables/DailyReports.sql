CREATE TABLE [dbo].[DailyReports]
(
  [ReportId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [ReportDate] DATE NOT NULL UNIQUE,
  [TotalDeposits] DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (TotalDeposits >=0),
  [TotalWithdrawals] DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (TotalWithdrawals >=0),
  [TotalTransactions] INT NOT NULL DEFAULT 0 CHECK (TotalTransactions >=0),
  [GeneratedAt] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
)
