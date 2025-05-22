param location string
param privateEndpointName string
param subnetPrivateEndpointId string
param linkedResourceId string

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
            'sqlServer'
          ]
        }
      }
    ]
  }
}

