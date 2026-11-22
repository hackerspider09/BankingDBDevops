# SQL Diagnostics & Verification

- **`create_linkserver.sql`**: Drops, recreates, configures, and tests `BankingDBServerLink` with MSOLEDBSQL19 and credentials.
- **`verify_reporting_and_linkserver.sql`**: Lists linked servers, tests direct table access, runs `usp_GenerateDailyReport`, and queries `DailyReports`.
- **`linkserver_related.sql`**: Quick check of `sys.servers`.
- **`get_report.sql`**: Aggregation query on `Transactions`.
