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
      }
    }]
  } 
}

output vnetId string = virtualNetwork.id
output subnets array = virtualNetwork.properties.subnets
output subnetsId array = [for subnet in subnets: {
  id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnet.subnetName)
}]


