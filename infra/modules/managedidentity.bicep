param userAssignedIdentitiesName string
param location string

resource userAssignedIdentities 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentitiesName
  location: location
}

output userAssignedIdentitiesId string = userAssignedIdentities.id
output userAssignedIdentitiesClientId string = userAssignedIdentities.properties.clientId
output userAssignedIdentitiesObjectId string = userAssignedIdentities.properties.principalId

