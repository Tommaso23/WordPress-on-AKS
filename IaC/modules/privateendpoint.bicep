param location string
param privateEndpointName string
param subnetPrivateEndpointId string
param linkedResourceId string
param serviceName string

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
}


resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.${serviceName}.azure.com'
        properties: {
          privateDnsZoneId: 'Microsoft.Network/privateDnsZones/privatelink.${serviceName}.azure.com'
        }
      }
  ]
}
}
