CREATE PROCEDURE [dbo].[usp_GenerateDailyReport]
  @ReportDate DATE
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @TotalDeposits DECIMAL(18,2) = 0;
  DECLARE @TotalWithdrawals DECIMAL(18,2) = 0;
  DECLARE @TotalTransactions INT = 0;

  SELECT 
  @TotalDeposits = COALESCE(sum(case when TransactionType ='Deposit' then Amount else 0 end),0),
  @TotalWithdrawals = COALESCE(sum(case when TransactionType ='Withdrawal' then Amount else 0 end),0),
  @TotalTransactions = count(*) 
  FROM [$(BankingDBServer)].[$(BankingDB)].[dbo].[Transactions]
  WHERE TransactionDate >= @ReportDate AND TransactionDate < DATEADD(DAY,1,@ReportDate)

  IF EXISTS ( SELECT 1 from [dbo].[DailyReports] WHERE ReportDate =@ReportDate )
    BEGIN
      UPDATE [dbo].[DailyReports] SET 
      [TotalWithdrawals] = @TotalWithdrawals, 
      [TotalDeposits] = @TotalDeposits, 
      [TotalTransactions] = @TotalTransactions,
      [GeneratedAt] = SYSUTCDATETIME()
      WHERE [ReportDate]=@ReportDate
    END
  ELSE
    BEGIN
      INSERT INTO [dbo].[DailyReports] (ReportDate,TotalDeposits,TotalWithdrawals,TotalTransactions)
      VALUES (@ReportDate,@TotalDeposits,@TotalWithdrawals,@TotalTransactions)
    END
END