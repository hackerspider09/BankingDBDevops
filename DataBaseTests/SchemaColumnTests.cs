using Microsoft.Data.SqlClient;
using Xunit;

[Collection("SqlServerCollection")]
public class SchemaColumnTests
{
    private readonly DatabaseFixture _fixture;

    public SchemaColumnTests(DatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task BankingDb_AccountsTable_HasAllExpectedColumns()
    {
        var expectedColumns = new[] { "AccountId", "CustomerId", "AccountNumber", "AccountType", "Balance", "CreatedAt" };
        var actualColumns = await GetTableColumnsAsync(_fixture.BankingConnectionString, "dbo", "Accounts");

        foreach (var col in expectedColumns)
        {
            Assert.Contains(col, actualColumns, StringComparer.OrdinalIgnoreCase);
        }
    }

    [Fact]
    public async Task ReportingDb_DailyReportsTable_HasAllExpectedColumns()
    {
        // Actual table is DailyReports — not DailySummary
        var expectedColumns = new[] { "ReportId", "ReportDate", "TotalDeposits", "TotalWithdrawals", "TotalTransactions", "GeneratedAt" };
        var actualColumns = await GetTableColumnsAsync(_fixture.ReportingConnectionString, "dbo", "DailyReports");

        foreach (var col in expectedColumns)
        {
            Assert.Contains(col, actualColumns, StringComparer.OrdinalIgnoreCase);
        }
    }

    private static async Task<List<string>> GetTableColumnsAsync(string connStr, string schema, string tableName)
    {
        var columns = new List<string>();
        const string sql = """
            SELECT COLUMN_NAME 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @Schema AND TABLE_NAME = @TableName
            """;

        await using var conn = new SqlConnection(connStr);
        await conn.OpenAsync();
        await using var cmd = new SqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("@Schema", schema);
        cmd.Parameters.AddWithValue("@TableName", tableName);

        await using var reader = await cmd.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            columns.Add(reader.GetString(0));
        }

        return columns;
    }
}
