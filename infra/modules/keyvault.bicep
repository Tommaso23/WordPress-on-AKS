param keyVaultName string
param location string

param mySqlConnectionString string
param mySqlUser string
@secure()
param mySqlPassword string
param mySqlDBName string

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

output keyVaultId string = keyVault.id
