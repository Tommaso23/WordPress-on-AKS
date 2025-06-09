param keyVaultName string
param location string

param mySqlConnectionString string
param mySqlUser string
@secure()
param mySqlPassword string
param mySqlDBName string
param aksClusterName string
param nodeResourceGroupName string
param roleDefinitionId string = '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User

resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    accessPolicies: [] // Azure RBAC is used instead
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    networkAcls: {
      bypass: 'None' 
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    createMode: 'default'
    publicNetworkAccess: 'Disabled'
  }
}

resource mySqlDatabaseHost 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'mysql-database-host' //key
  properties: {
    value: mySqlConnectionString // secret value
  }
}

resource mySqlDatabaseUser 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'mysql-database-user' //key
  properties: {
    value: mySqlUser // secret value
  }
}

resource mySqlDatabasePassword 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'mysql-database-password' //key
  properties: {
    value: mySqlPassword // secret value
  }
}

resource mySqlDatabaseName 'Microsoft.KeyVault/vaults/secrets@2024-12-01-preview' = {
  parent: keyVault
  name: 'mysql-database-name' //key
  properties: {
    value: mySqlDBName // secret value
  }
}

resource keyVaultManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' existing = {
  name: 'azurekeyvaultsecretsprovider-${aksClusterName}'
  scope: resourceGroup(nodeResourceGroupName)
}

resource keyVaultManagedIdentitySecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault // Replace with the actual scope if needed
  name: guid(roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: keyVaultManagedIdentity.properties.principalId
  }
}

output keyVaultId string = keyVault.id
