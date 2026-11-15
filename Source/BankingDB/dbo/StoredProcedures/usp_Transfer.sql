-- account 1 => from account
-- account 2 => to account

CREATE PROCEDURE [dbo].[usp_Transfer]
  @FromAccountId int,
  @ToAccountId int,
  @Amount DECIMAL(18,2),
  @Description VARCHAR(250) = ''
AS
BEGIN

  SET NOCOUNT ON; -- prevent rows affected message
  SET XACT_ABORT ON; -- handles automatic roll back


  IF @Amount<=0 or @Amount IS NULL
    THROW 50001, 'Transaction Amount should not be 0 or negative',1;

  IF @FromAccountId = @ToAccountId
    THROW 50002, 'Both accounts should not be same',1;

  DECLARE @TrxGUID UNIQUEIDENTIFIER = NEWID();
  DECLARE @Account1 int;
  DECLARE @Account2 int;

  -- what if both user started transaction to each other
  IF @FromAccountId < @ToAccountId
    BEGIN
      set @Account1 = @FromAccountId
      set @Account2 = @ToAccountId
    END
  ELSE
    BEGIN
      set @Account1 = @ToAccountId
      set @Account2 = @FromAccountId
    END


  BEGIN TRY
    BEGIN TRANSACTION
      -- get lock and check account existance
      IF not EXISTS (SELECT 1 FROM [dbo].[Accounts] WITH (UPDLOCK, ROWLOCK) WHERE AccountId = @Account1)
        THROW 50002, 'Account1 does not exist', 2;
      IF not EXISTS (SELECT 1 FROM [dbo].[Accounts] WITH (UPDLOCK, ROWLOCK) WHERE AccountId = @Account2)
        THROW 50002, 'Account2 does not exist', 3;

      -- debit amount from account 1
      UPDATE [dbo].[Accounts] SET Balance = Balance - @Amount WHERE AccountId = @FromAccountId and Balance >= @Amount;
      IF @@ROWCOUNT = 0
        THROW 50003, 'Insufficeint balance in account1',1;

      -- credit amount to account 2
      UPDATE [dbo].[Accounts] SET Balance = Balance + @Amount WHERE AccountId = @ToAccountId;
      IF @@ROWCOUNT = 0
        THROW 50003, 'Balance doesnt updated in account2',1;

      -- create transaction history
      -- for account1
      INSERT INTO [dbo].[Transactions] (AccountId,TransactionReference,TransactionType,Amount,Description) VALUES (@FromAccountId,@TrxGUID,'TransferDebit',@Amount,@Description)
      INSERT INTO [dbo].[Transactions] (AccountId,TransactionReference,TransactionType,Amount,Description) VALUES (@ToAccountId,@TrxGUID,'TransferCredit',@Amount,@Description)


    COMMIT TRANSACTION;
    SELECT 'Transaction successful' AS Message;
  END TRY
  BEGIN CATCH
    -- if there is any error perform rollback and remove all locks
    IF XACT_STATE() <> 0
      ROLLBACK TRANSACTION;
    THROW;
  END CATCH

END