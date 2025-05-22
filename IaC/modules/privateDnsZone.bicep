param dnsZoneName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.${dnsZoneName}.azure.com'
  location: 'global'
  properties: {}
}
