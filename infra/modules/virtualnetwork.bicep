param vnetName string
param vnetAddrPrefix string
param location string
param subnets array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddrPrefix]
    }
    subnets: [for subnet in subnets: {
      name: subnet.subnetName
      properties: {
        addressPrefix: subnet.subnetAddrPrefix
        networkSecurityGroup: subnet.nsgId == '' ? null : {
          id: subnet.nsgId
        }
        routeTable: subnet.routeTableId == '' ? null : {
          id: subnet.routeTableId
        }
        delegations: subnet.delegation == '' ? [] : [{
          name: '${subnet.subnetName}-delegation'
          properties: {
            serviceName: subnet.delegation
          }
        }]
      }
    }]
  } 
}

output vnetId string = virtualNetwork.id
output subnets array = virtualNetwork.properties.subnets
output aksSubnetId string = virtualNetwork.properties.subnets[0].id
output appGatewaySubnetId string = virtualNetwork.properties.subnets[1].id
output privateLinkSubnetId string = virtualNetwork.properties.subnets[2].id
output netappSubnetId string = virtualNetwork.properties.subnets[3].id

