@description('Location for all resources.')
param location string = resourceGroup().location


var privateEndpointName = 'myPrivateEndpoint'
var privateDnsZoneName = 'privatelink.mysql.database.azure.com'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'

resource mySqlServer 'Microsoft.DBforMySQL/flexibleServers@2024-02-01-preview' existing = {
  name: 'sql-bicepdeploy-itn'
}

resource mySqlDatabase 'Microsoft.DBforMySQL/flexibleServers/databases@2023-12-30' existing = {
  parent: mySqlServer
  name: 'db-bicepdeploy-itn'
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: 'vnet-aks-bicepdeploy-test-itn'

}

resource vnetName_subnet1 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = {
  parent: vnet
  name: 'snet-pep-aks'
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: vnetName_subnet1.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: mySqlServer.id
          groupIds: [
            'mysqlServer'
          ]
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    vnet
  ]
}

resource privateDnsZoneName_privateDnsZoneName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

