CREATE PROCEDURE [dbo].[usp_Deposit]
  @AccountId int,
  @Amount DECIMAL(18,2),
  @Description VARCHAR(250) = ''
AS
BEGIN
  SET NOCOUNT ON; -- prevent rows affected message
  SET XACT_ABORT ON; -- handles automatic roll back

  IF @Amount <=0 OR @Amount is NULL
  BEGIN
    THROW 50001, 'Transaction Amount should not be 0 or negative',1;
  END

  IF NOT EXISTS ( SELECT 1 from [dbo].[Accounts] where AccountId = @AccountId)
  BEGIN
    THROW 50002, 'Account does not exist', 1;
  END

  BEGIN TRY
    BEGIN TRANSACTION
      
      UPDATE [dbo].[Accounts] set Balance = Balance + @Amount WHERE AccountId = @AccountId;

      -- if before transaction begin and after account check if account deleted this will prevent that transaction
      IF @@ROWCOUNT = 0
        THROW 50002, 'Account does not exist', 2;

      INSERT INTO [dbo].[Transactions] (AccountId,TransactionType,Amount,Description) VALUES (@AccountId,'Deposit',@Amount,@Description)

    COMMIT TRANSACTION
    SELECT 'Deposit successful' AS Message;

  END TRY
  BEGIN CATCH
  -- returns status code for last transaction like 1 0 -1
    IF XACT_STATE() <> 0
      ROLLBACK TRANSACTION

    THROW ;
  END CATCH

END;


-- Accepts an AccountId.
-- Accepts an Amount.
-- Checks whether the account exists.
-- Rejects zero or negative amounts.
-- Increases the account balance.
-- Inserts a corresponding record into Transactions.
-- Generates a transaction reference.
-- Returns a success message or an appropriate error.