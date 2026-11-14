CREATE PROCEDURE [dbo].[usp_Withdraw]
  @AccountId int,
  @Amount DECIMAL(18,2),
  @Description VARCHAR(250) = ''
AS
BEGIN
  SET NOCOUNT ON; -- prevent rows affected message
  SET XACT_ABORT ON; -- handles automatic roll back


  IF @Amount<=0 or @Amount IS NULL
    THROW 50001, 'Transaction Amount should not be 0 or negative',1;

  IF NOT EXISTS ( SELECT 1 from [dbo].[Accounts] where AccountId = @AccountId)
    THROW 50002, 'Account does not exist', 1;

  BEGIN TRY
    BEGIN TRANSACTION
      -- lock row to perform update
      UPDATE [dbo].[Accounts] set Balance = Balance - @Amount WHERE AccountId = @AccountId AND Balance>=@Amount;

      -- if before transaction begin and after account check if account deleted this will prevent that transaction
      IF @@ROWCOUNT = 0
        THROW 50003, 'Either Account does not exist or Balance is insufficient', 1;

      INSERT INTO [dbo].[Transactions] (AccountId,TransactionType,Amount,Description) VALUES (@AccountId,'Withdrawal',@Amount,@Description)

    COMMIT TRANSACTION;
    SELECT 'Withdrawal  successful' AS Message;
  END TRY
  BEGIN CATCH
    -- returns status code for last transaction like 1 0 -1
    IF XACT_STATE() <> 0
      ROLLBACK TRANSACTION;
    THROW;
  END CATCH

END
