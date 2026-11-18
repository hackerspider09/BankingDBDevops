using Microsoft.Extensions.Configuration;
using Xunit;

public class DatabaseFixture
{
    public string BankingConnectionString { get; }
    public string ReportingConnectionString { get; }
    public string BankingLinkServerName { get; }

    public DatabaseFixture()
    {
        var config = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: true)
            .AddEnvironmentVariables()
            .Build();

        BankingConnectionString = config.GetConnectionString("BankingDB")
            ?? config["BankingDB"]
            ?? throw new InvalidOperationException("BankingDb connection string is missing.");

        ReportingConnectionString = config.GetConnectionString("ReportingDB")
            ?? config["ReportingDB"]
            ?? throw new InvalidOperationException("ReportingDb connection string is missing.");

        BankingLinkServerName = config["LinkedServers:BankingDB_LinkServerName"]
            ?? config["BankingDB_LinkServerName"]
            ?? throw new InvalidOperationException("LinkedServers:BankingDB_LinkServerName is missing from appsettings.");
    }
}

[CollectionDefinition("SqlServerCollection")]
public class DatabaseCollection : ICollectionFixture<DatabaseFixture>
{
}
