param location string
param privateEndpointName string
param subnetPrivateEndpointId string
param linkedResourceId string
param serviceName string
param privateDnsZoneId string
param virtualNetworkName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: virtualNetworkName
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetPrivateEndpointId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: linkedResourceId
          groupIds: [
            serviceName
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
        name: 'privatelink.${serviceName}.azure.com'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}



