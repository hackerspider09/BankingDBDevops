select 
CAST (TransactionDate AS DATE) AS 'date',
sum(case when TransactionType='Deposit' then Amount else 0 end) as TotalDeposits,
sum(case when TransactionType='Withdrawal' then Amount else 0 end) as TotalWithdrawals,
count(*) as TotalTransactions
from BankingDB.dbo.Transactions 
group by CAST (TransactionDate AS DATE)