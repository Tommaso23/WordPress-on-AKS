resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: 'vnet-aks-bicepdeploy-test-itn'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: virtualNetwork
  name: 'snet-pep-aks'
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.mysql.database.azure.com'
  location: 'global'
  properties: {}
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: privateDnsZone
  name: 'vlink-vnet-aks-bicepdeploy-test-itn'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pe-bicepdeploy-itn'
  location: 'italynorth'
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-bicepdeploy-itn'
        properties: {
          privateLinkServiceId: '/subscriptions/5ea8bbe6-5774-4e6a-b000-d482190468d6/resourceGroups/rg-aks-bicepdeploy-test-itn/providers/Microsoft.DBforMySQL/flexibleServers/sql-bicepdeploy-itn'
          groupIds: [
            'mysqlServer'
          ]
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork 
  ]
}


resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.mysql.database.azure.com'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}


