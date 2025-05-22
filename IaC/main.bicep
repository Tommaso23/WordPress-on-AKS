targetScope = 'subscription'
param location string = deployment().location

param workloadName string
param locationalias string = 'itn'
param resourceGroupName string = 'rg-aks-${workloadName}-test-${locationalias}'

param virtualNetworkName string = 'vnet-aks-${workloadName}-test-${locationalias}'
param vnetAddrPrefix string = '10.100.0.0/24'

param aksSubnetName string = 'snet-clusternodes-aks'
param aksSubnetAddrPrefix string = '10.100.0.0/26'
param appgatewaySubnetName string = 'snet-agw-aks'
param appgatewaySubnetAddrPrefix string = '10.100.0.64/26'
param privateLinkSubnetName string = 'snet-pep-aks'
param privateLinkSubnetAddrPrefix string = '10.100.0.128/28'
param netappSubnetName string = 'snet-netapp-aks'
param netappSubnetAddrPrefix string = '10.100.0.144/28'


var subnets = [
  {
    subnetAddrPrefix: aksSubnetName
    subnetName: aksSubnetAddrPrefix
    vnetName: virtualNetworkName
    nsgId: ''
    routeTableId: ''
  }
  {
    subnetAddrPrefix: appgatewaySubnetName
    subnetName: appgatewaySubnetAddrPrefix
    vnetName: virtualNetworkName
    nsgId: ''
    routeTableId: ''
  }
  {
    subnetAddrPrefix: privateLinkSubnetName
    subnetName: privateLinkSubnetAddrPrefix
    vnetName: virtualNetworkName
    nsgId: ''
    routeTableId: ''
  }
  {
    subnetAddrPrefix: netappSubnetName
    subnetName: netappSubnetAddrPrefix
    vnetName: virtualNetworkName
    nsgId: ''
    routeTableId: ''
  }
]

module aksResourceGroup './modules/resourcegroup.bicep' = {
  name: 'aksResourceGroup'
  params: {
    location: location
    rgName: resourceGroupName
  }
}

module aksVirtualnetwork 'modules/virtualnetwork.bicep' = {
  name: 'aksVirtualnetwork'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    vnetName: virtualNetworkName
    vnetAddrPrefix: vnetAddrPrefix
    subnets: subnets
  }
  dependsOn: [
    aksResourceGroup
  ]
}

