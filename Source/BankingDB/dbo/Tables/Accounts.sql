CREATE TABLE [dbo].[Accounts]
(
  [AccountId] INT IDENTITY(1,1) NOT NULL,
  [CustomerId] INT NOT NULL,
  [AccountNumber] VARCHAR(20) NOT NULL,
  [AccountType] VARCHAR(20) NOT NULL,

  -- way 1 : inline constraints 
  [Balance] DECIMAL(18,2) NOT NULL CONSTRAINT DF_Accounts_Balance DEFAULT 0,
  [CreatedAt] DATETIME2 NOT NULL CONSTRAINT DF_Accounts_CreatedAt DEFAULT SYSUTCDATETIME(),

  -- way 2 table level constraints 
  CONSTRAINT PK_Accounts PRIMARY KEY ([AccountId]),
  CONSTRAINT FK_Accounts_Customers FOREIGN KEY (CustomerId) REFERENCES [dbo].[Customers]([CustomerId]),
  CONSTRAINT UQ_Accounts_AccountNumber UNIQUE ([AccountNumber]),
  CONSTRAINT CK_Accounts_AccountType CHECK ([AccountType] IN ('Savings','Current')), 
  CONSTRAINT CK_Accounts_Balance CHECK ([Balance] >=0)
)
