targetScope = 'subscription'
param location string = deployment().location

param workloadName string
param locationAlias string
param resourceGroupName string = 'rg-aks-${workloadName}-${locationAlias}'

param virtualNetworkName string = 'vnet-aks-${workloadName}-${locationAlias}'
param vnetAddrPrefix string = '10.100.0.0/24'

param aksSubnetName string = 'snet-clusternodes-aks'
param aksSubnetAddrPrefix string = '10.100.0.0/26'
param appgatewaySubnetName string = 'snet-agw-aks'
param appgatewaySubnetAddrPrefix string = '10.100.0.64/26'
param privateLinkSubnetName string = 'snet-pep-aks'
param privateLinkSubnetAddrPrefix string = '10.100.0.128/28'
param netappSubnetName string = 'snet-netapp-aks'
param netappSubnetAddrPrefix string = '10.100.0.144/28'

param mysqlPrivateEndpointName string = 'pe-mysql-${workloadName}-${locationAlias}'
var mySqlDnsZoneName = 'privatelink.mysql.database.azure.com'

param sqlServerName string = 'sql-${workloadName}-${locationAlias}'
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param databaseName string = 'db-${workloadName}-${locationAlias}'
param sqlVersion string = '8.0.21'
param sqlServerSKU string = 'Standard_B1ms'

// AKS Cluster //
param aksClusterName string = 'aks-${workloadName}-${locationAlias}'
param kubernetesVersion string = '1.31.7'
param agentPoolSize string = 'Standard_D4as_v5'
param userPoolSize string = 'Standard_D4as_v5'
param clusterAuthorizedIPRanges array = []

// NetApp Files //
param netappAccountName string = 'netapp-${workloadName}-${locationAlias}'
param capacityPoolName string = 'pool-${workloadName}-${locationAlias}'
param volumeName string = 'vol-${workloadName}-${locationAlias}'
param serviceLevel string = 'Premium'
param numberOfTB int = 1
param qosType string = 'Auto'
param numberOf50GB int = 1

// Key Vault //
param keyVaultPrivateEndpointName string = 'pe-kv-${workloadName}-${locationAlias}'
var keyVaultDnsZoneName = 'privatelink.vaultcore.azure.net'
param keyVaultName string = 'kv-${workloadName}-${uniqueString(subscription().id)}-${locationAlias}'


param applicationGatewayPublicIpAddressName string = 'agw-pip-${workloadName}-${locationAlias}'
param applicationGatewayName string = 'agw-${workloadName}-${locationAlias}'
param internalLoadBalancerIp string = '10.100.0.62'
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

module mySqlPrivateDnsZone './modules/privatednszone.bicep' = {
  name: 'mySqlPrivateDnsZone'
  scope: resourceGroup(resourceGroupName)
  params: {
    dnsZoneName: mySqlDnsZoneName
    virtualNetworkName: virtualNetworkName
    virtualNetworkId: aksVirtualnetwork.outputs.vnetId
  }
  dependsOn: [
    aksResourceGroup
  ]
}

module mySQLPrivateEndpoint './modules/privateendpoint.bicep' = {
  name: 'mySQLPrivateEndpoint'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    privateEndpointName: mysqlPrivateEndpointName
    subnetPrivateEndpointId: aksVirtualnetwork.outputs.privateLinkSubnetId
    linkedResourceId: mysql.outputs.sqlServerId
    serviceName: 'mysqlServer'
    privateDnsZoneId: mySqlPrivateDnsZone.outputs.dnsZoneId
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
    clusterName: aksClusterName
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

module applicationGateway './modules/applicationgateway.bicep' = {
  name: 'applicationGateway'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    applicationGatewayName: applicationGatewayName
    applicationGatewaySubnetId: aksVirtualnetwork.outputs.appGatewaySubnetId
    appGatewayPublicIpAddressId: appGatewayPublicIpAddress.outputs.publicIpAddressId
    internalLoadBalancerIp: internalLoadBalancerIp
  }
  dependsOn: [
    aksResourceGroup
  ]
}
module aksClusterNetworkContributorRoleAssignment './modules/rbacassignments.bicep' = {
  name: 'aksClusterNetworkContributorRoleAssignment'
  scope: resourceGroup(resourceGroupName)
  params: {
    principalId: aksCluster.outputs.aksClusterPrincipalId
    roleDefinitionId: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  } 
  dependsOn: [
    aksResourceGroup
  ]
}

module keyVaultPrivateEndpoint './modules/privateendpoint.bicep' = {
  name: 'keyVaultPrivateEndpoint'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    privateEndpointName: keyVaultPrivateEndpointName
    subnetPrivateEndpointId: aksVirtualnetwork.outputs.privateLinkSubnetId
    linkedResourceId: keyVault.outputs.keyVaultId
    serviceName: 'vault'
    privateDnsZoneId: keyVaultPrivateDnsZone.outputs.dnsZoneId
    virtualNetworkName: virtualNetworkName
  }
  dependsOn: [
    aksResourceGroup
  ]
}

module keyVaultPrivateDnsZone './modules/privatednszone.bicep' = {
  name: 'KeyVaultPrivateDnsZone'
  scope: resourceGroup(resourceGroupName)
  params: {
    dnsZoneName: keyVaultDnsZoneName
    virtualNetworkName: virtualNetworkName
    virtualNetworkId: aksVirtualnetwork.outputs.vnetId
  }
  dependsOn: [
    aksResourceGroup
  ]
}

module keyVault './modules/keyvault.bicep' = {
  name: 'keyVault'
  scope: resourceGroup(resourceGroupName)
  params: {
    keyVaultName: keyVaultName
    location: location
    mySqlConnectionString: mysql.outputs.connectionString
    mySqlUser: sqlAdministratorLogin
    mySqlPassword: sqlAdministratorLoginPassword
    mySqlDBName: databaseName
  }
  dependsOn: [
    aksResourceGroup
    keyVaultPrivateDnsZone
  ]
}


//TODO: existing Managed Identity .... assegna RBAC permission to read secrets from Key Vault "Key Vault Secret User"
