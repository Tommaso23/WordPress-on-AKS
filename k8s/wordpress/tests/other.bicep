/*
resource sqlAppDatabaseNameSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'sql-app-database-name'
  properties: {
    value: sqlAppDatabaseName
  }
}

resource AzureSqlEndpointSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'azure-sql-endpoint'
  properties: {
    value: sqlServer.properties.fullyQualifiedDomainName
  }
}
*/
