param keyVaultPrivateEndpointName string = 'pe-kv-${workloadName}-${locationalias}'
var keyVaultDnsZoneName = 'privatelink.vaultcore.azure.net'
param keyVaultName string = 'kv-${workloadName}-${locationalias}'


module keyVaultPrivateEndpoint '../modules/privateendpoint.bicep' = {
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

module keyVaultPrivateDnsZone '../modules/privatednszone.bicep' = {
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

module keyVault '../modules/keyvault.bicep' = {
  name: 'keyVault'
  scope: resourceGroup(resourceGroupName)
  params: {
    keyVaultName: keyVaultName
    location: location
  }
  dependsOn: [
    aksResourceGroup
    keyVaultPrivateDnsZone
  ]
}
