using Microsoft.Data.SqlClient;
using Xunit;

[Collection("SqlServerCollection")]
public class LinkedServerSetupTests
{
    private readonly string _reportingConnStr;
    private readonly string _linkServerName;

    public LinkedServerSetupTests(DatabaseFixture fixture)
    {
        _reportingConnStr = fixture.ReportingConnectionString;
        _linkServerName   = fixture.BankingLinkServerName;
    }

    [Fact]
    public async Task LinkedServer_IsConfiguredCorrectly_InSysServers()
    {
        const string sql = """
            SELECT name, product, provider, data_source
            FROM sys.servers
            WHERE name = @ServerName AND is_linked = 1
            """;

        await using var conn = new SqlConnection(_reportingConnStr);
        await conn.OpenAsync();
        await using var cmd = new SqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("@ServerName", _linkServerName);

        await using var reader = await cmd.ExecuteReaderAsync();

        // Fails if the linked server row does not exist
        Assert.True(await reader.ReadAsync(), $"Linked server '{_linkServerName}' was not found in sys.servers.");

        Assert.Equal(_linkServerName,  reader["name"].ToString());
        Assert.Equal("",               reader["product"].ToString());   
        Assert.StartsWith("MSOLEDBSQL", reader["provider"].ToString());   
        Assert.False(string.IsNullOrWhiteSpace(reader["data_source"].ToString()));
    }
}
