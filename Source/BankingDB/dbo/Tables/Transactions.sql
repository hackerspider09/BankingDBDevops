CREATE TABLE [dbo].[Transactions]
(
  [TransactionId] BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  [AccountId] INT NOT NULL,
  [TransactionReference] UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Transactions_Reference DEFAULT NEWID(),
  [TransactionType] VARCHAR(20) NOT NULL,
  [Amount] DECIMAL(18,2) NOT NULL check (Amount >0),
  [TransactionDate] DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
  [Description] VARCHAR(250),

  CONSTRAINT FK_Transactions_Accounts FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Accounts]([AccountId]),
  CONSTRAINT CK_Transactions_TransactionType CHECK ( [TransactionType] in ('Deposit','Withdrawal','TransferDebit','TransferCredit'))
)
