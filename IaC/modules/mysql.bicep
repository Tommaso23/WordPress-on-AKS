param sqlServerName string
param location string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param databaseName string
param sqlVersion string
param sqlServerSKU string


resource sqlServer 'Microsoft.DBforMySQL/flexibleServers@2023-12-30' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: sqlVersion
    network: {
      publicNetworkAccess: 'Disabled'
    }
    storage: {
      storageSizeGB: 20
      iops: 360
    }
   }
    sku: {
      name: sqlServerSKU
      tier: 'Burstable'
    }
}

resource database 'Microsoft.Sql/servers/databases@2023-08-01' = {
  name: databaseName
  location: location
  properties: {
    collation: 'utf8mb3_general_ci'
  }
  dependsOn: [
    sqlServer
  ]
}

output sqlServerId string = sqlServer.id
