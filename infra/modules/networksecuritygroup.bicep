param networkSecurityGroupName string
param location string
param securityRules array


resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: securityRules
  }
}

output networkSecurityGroupId string = networkSecurityGroup.id
