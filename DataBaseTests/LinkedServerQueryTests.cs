using Microsoft.Data.SqlClient;
using Xunit;

[Collection("SqlServerCollection")]
public class LinkedServerQueryTests
{
    private readonly string _reportingConnStr;
    private readonly string _linkServerName;

    public LinkedServerQueryTests(DatabaseFixture fixture)
    {
        _reportingConnStr = fixture.ReportingConnectionString;
        _linkServerName   = fixture.BankingLinkServerName;
    }

    // ── Test 1: ping the linked server ──────────────────────────────────────
    [Fact]
    public async Task LinkedServer_PingCheck_Succeeds()
    {
        // sp_testlinkedserver does a quick connectivity check.
        // It throws a SqlException if the linked server is unreachable or misconfigured.
        // Note: linked server name goes into the SQL text directly because SQL Server
        //       does not allow parameterizing server names in sp_testlinkedserver.
        var sql = $"EXEC sys.sp_testlinkedserver @servername = N'{_linkServerName}';";

        await using var conn = new SqlConnection(_reportingConnStr);
        await conn.OpenAsync();
        await using var cmd = new SqlCommand(sql, conn);

        var exception = await Record.ExceptionAsync(() => cmd.ExecuteNonQueryAsync());

        Assert.Null(exception);
    }

    // ── Test 2: actually read data through the linked server ─────────────────
    [Fact]
    public async Task LinkedServer_CanReadAccountsFromBankingDb()
    {
        // 4-part name: [LinkedServerName].[Database].[Schema].[Table]
        // This proves the login mapping, network routing, and permissions all work.
        // Note: SQL Server does not allow parameterizing the linked server name in
        //       a 4-part identifier, so we build the query string from config.
        var sql = $"SELECT TOP 1 AccountId FROM [{_linkServerName}].[BankingDB].[dbo].[Accounts];";

        await using var conn = new SqlConnection(_reportingConnStr);
        await conn.OpenAsync();
        await using var cmd = new SqlCommand(sql, conn);

        // ExecuteScalarAsync returns null when the table is empty (no rows) — that is still OK.
        // It only throws when the linked server itself fails.
        var exception = await Record.ExceptionAsync(() => cmd.ExecuteScalarAsync());

        Assert.Null(exception);
    }
}
