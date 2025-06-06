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

resource database 'Microsoft.DBforMySQL/flexibleServers/databases@2023-12-30' = {
  parent: sqlServer
  name: databaseName
  properties: {
    collation: 'utf8mb3_general_ci'
  }
}

resource firewallRules 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-12-30' = {
  parent: sqlServer
  name: 'AllowAzureIPs'
  dependsOn: [
    database
  ]
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource requireSecureTransportParam 'Microsoft.DBforMySQL/flexibleServers/configurations@2023-06-30' = {
  name: 'require_secure_transport'
  parent: sqlServer
  properties: {
    value: 'OFF'
    source: 'user-override'
  }
}

output sqlServerId string = sqlServer.id
output connectionString string = sqlServer.properties.fullyQualifiedDomainName

