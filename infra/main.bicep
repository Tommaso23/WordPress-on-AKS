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

var serviceName = 'mysqlServer'
var dnsZoneName = 'privatelink.mysql.database.azure.com'

param sqlServerName string = 'sql-${workloadName}-${locationalias}'
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param databaseName string = 'db-${workloadName}-${locationalias}'
param sqlVersion string = '8.0.21'
param sqlServerSKU string = 'Standard_B1ms'

// AKS Cluster //
param kubernetesVersion string = '1.31.7'
param agentPoolSize string = 'Standard_D4as_v5'
param userPoolSize string = 'Standard_D4as_v5'
param clusterAuthorizedIPRanges array = []

// NETAPP Files //
param netappAccountName string = 'netapp-${workloadName}-${locationalias}'
param capacityPoolName string = 'pool-${workloadName}-${locationalias}'
param volumeName string = 'vol-${workloadName}-${locationalias}'
param serviceLevel string = 'Premium'
param numberOfTB int = 1
param qosType string = 'Auto'
param numberOf50GB int = 1

param applicationGatewayPublicIpAddressName string = 'agw-pip-${workloadName}-${locationalias}'
param applicationGatewayName string = 'agw-${workloadName}-${locationalias}'

var subnets = [
  {
    subnetAddrPrefix: aksSubnetAddrPrefix

    subnetName: aksSubnetName
    vnetName: virtualNetworkName
    nsgId: ''
    routeTableId: ''
    delegation: ''
  }
  {
    subnetAddrPrefix: appgatewaySubnetAddrPrefix
    subnetName: appgatewaySubnetName
    vnetName: virtualNetworkName
    nsgId: ''
    routeTableId: ''
    delegation: ''
  }
  {
    subnetAddrPrefix: privateLinkSubnetAddrPrefix
    subnetName: privateLinkSubnetName
    vnetName: virtualNetworkName
    nsgId: ''
    routeTableId: ''
    delegation: ''
  }
  {
    subnetAddrPrefix: netappSubnetAddrPrefix
    subnetName: netappSubnetName
    vnetName: virtualNetworkName
    nsgId: ''
    routeTableId: ''
    delegation: 'Microsoft.NetApp/volumes'
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
    sqlServerName: sqlServerName
    location: location
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    sqlVersion: sqlVersion
    databaseName: databaseName
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
    subnetPrivateEndpointId: aksVirtualnetwork.outputs.privateLinkSubnetId
    linkedResourceId: mysql.outputs.sqlServerId
    serviceName: serviceName
    privateDnsZoneId: aksPrivateDnsZone.outputs.dnsZoneId
    virtualNetworkName: virtualNetworkName
  }
  dependsOn: [
    aksResourceGroup
  ]
}

module aksCluster './modules/akscluster.bicep' = {
  name: 'aksCluster'
  scope: resourceGroup(resourceGroupName)
  params: {
    clusterName: 'aks-${workloadName}-${locationalias}'
    location: location
    kubernetesVersion: kubernetesVersion
    agentPoolSize: agentPoolSize
    userPoolSize: userPoolSize
    subnetId: aksVirtualnetwork.outputs.aksSubnetId
    clusterAuthorizedIPRanges: clusterAuthorizedIPRanges
  }
}

module netapp './modules/netapp.bicep' = {
  name: 'netapp'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    netappAccountName: netappAccountName
    capacityPoolName: capacityPoolName
    volumeName: volumeName
    serviceLevel: serviceLevel
    numberOfTB: numberOfTB
    qosType: qosType
    numberOf50GB: numberOf50GB
    netappSubnetId: aksVirtualnetwork.outputs.netappSubnetId
    aksSubnetAddrPrefix: aksSubnetAddrPrefix
  }
  dependsOn: [
    aksResourceGroup
  ]
}

module appGatewayPublicIpAddress './modules/publicipaddress.bicep' = {
  name: 'appGatewayPublicIpAddress'
  scope: resourceGroup(resourceGroupName)
  params: {
    publicIpAddressName: applicationGatewayPublicIpAddressName
    location: location
  }
  dependsOn: [
    aksResourceGroup
  ]
}

module applicationGateway './modules/Applicationgateway.bicep' = {
  name: 'applicationGateway'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    applicationGatewayName: applicationGatewayName
    applicationGatewaySubnetId: aksVirtualnetwork.outputs.appGatewaySubnetId
    appGatewayPublicIpAddressId: appGatewayPublicIpAddress.outputs.publicIpAddressId
    internalLoadBalancerIp: '10.100.0.7'
  }
  dependsOn: [
    aksResourceGroup
  ]
}

