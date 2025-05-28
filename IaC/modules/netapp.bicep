param netappAccountName string
param location string
param capacityPoolName string
param serviceLevel string
param numberOfTB int
var capacityPoolSize = 1099511627776 * numberOfTB
param qosType string
param volumeName string
param netappSubnetId string
param numberOf50GB int
var volumeSize = 53687091200 * numberOf50GB// 50 GiB

resource netAppAccount 'Microsoft.NetApp/netAppAccounts@2025-01-01' = {
  name: netappAccountName
  location: location
  properties: {
    encryption: {
      keySource: 'Microsoft.NetApp'
    }
  }
}

resource netAppCapacityPool 'Microsoft.NetApp/netAppAccounts/capacityPools@2025-01-01' = {
  parent: netAppAccount
  name: capacityPoolName
  location: location
  properties: {
    serviceLevel: serviceLevel
    size: capacityPoolSize
    qosType: qosType
    encryptionType: 'Single'
    coolAccess: false
  }
}

resource netAppVolume 'Microsoft.NetApp/netAppAccounts/capacityPools/volumes@2025-01-01' = {
  parent: netAppCapacityPool
  name: volumeName
  location: location
  zones: [
    '1'
  ]
  properties: {
    serviceLevel: serviceLevel
    creationToken: 'vol-aks-test'
    usageThreshold: volumeSize
    exportPolicy: {
      rules: [
        {
          ruleIndex: 1
          unixReadOnly: false
          unixReadWrite: true
          cifs: false
          nfsv3: true
          nfsv41: false
          allowedClients: '0.0.0.0/0'
          kerberos5ReadOnly: false
          kerberos5ReadWrite: false
          kerberos5iReadOnly: false
          kerberos5iReadWrite: false
          kerberos5pReadOnly: false
          kerberos5pReadWrite: false
          hasRootAccess: true
          chownMode: 'Unrestricted'
        }
      ]
    }
    protocolTypes: [
      'NFSv3'
    ]
    subnetId: netappSubnetId
    networkFeatures: 'Standard'
    snapshotDirectoryVisible: true
    kerberosEnabled: false
    securityStyle: 'Unix'
    smbEncryption: false
    smbContinuouslyAvailable: false
    encryptionKeySource: 'Microsoft.NetApp'
    ldapEnabled: false
    unixPermissions: '0777'
    coolAccess: false
    avsDataStore: 'Disabled'
    isDefaultQuotaEnabled: false
    defaultUserQuotaInKiBs: 0
    defaultGroupQuotaInKiBs: 0
    enableSubvolumes: 'Disabled'
    smbNonBrowsable: 'Disabled'
    smbAccessBasedEnumeration: 'Disabled'
    deleteBaseSnapshot: false
    isLargeVolume: false
  }
}
