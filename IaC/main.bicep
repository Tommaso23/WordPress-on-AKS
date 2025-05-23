targetScope = 'subscription'
param location string = deployment().location

param workloadName string
param locationalias string
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

var serviceName = 'sqlServer'
var dnsZoneName = 'privatelink.mysql.database.azure.com'

param sqlServerName string = 'sql-${workloadName}-${locationalias}'
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param databaseName string
param sqlVersion string = '8.0.21'
param sqlServerSKU string = 'Standard_B1ms'


// AKS Cluster //
param kubernetesVersion string = '1.31.7'
param agentPoolSize string = 'Standard_D4as_v5'
param userPoolSize string = 'Standard_D4as_v5'

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

module mysql './modules/mysql.bicep' = {
  name: 'mysql'
  scope: resourceGroup(resourceGroupName)
  params: {
    sqlServerName: 'sql-${workloadName}-${locationalias}'
    location: location
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    sqlVersion: sqlVersion
    databaseName: 'db-${workloadName}-${locationalias}'
    sqlServerSKU: sqlServerSKU
  }
  dependsOn: [
    aksResourceGroup
  ]
}

module aksPrivateDnsZone './modules/privatednszone.bicep' = {
  name: 'aksPrivateDnsZone'
  scope: resourceGroup(resourceGroupName)
  params: {
    dnsZoneName: dnsZoneName
    virtualNetworkName: virtualNetworkName
    virtualNetworkId: aksVirtualnetwork.outputs.vnetId
  }
  dependsOn: [
    aksResourceGroup
  ]
}

module privateEndpoint './modules/privateendpoint.bicep' = {
  name: 'privateEndpoint'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    privateEndpointName: 'pe-${workloadName}-${locationalias}'
    subnetPrivateEndpointId: aksVirtualnetwork.outputs.subnetsId[2]
    linkedResourceId: mysql.outputs.sqlServerId
    serviceName: serviceName
    privateDnsZoneId: aksPrivateDnsZone.outputs.dnsZoneId
  }
  dependsOn: [
    aksResourceGroup
  ]
}

