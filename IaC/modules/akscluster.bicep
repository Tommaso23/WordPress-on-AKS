param clusterName string
param location string 
param kubernetesVersion string
param agentPoolSize string
param subnetId string
param userPoolSize string
param userAssignedIdentitiesId string
param userAssignedIdentitiesClientId string
param userAssignedIdentitiesObjectId string
param clusterAuthorizedIPRanges array
param privateDnsZones_private_tombuca_com_externalid string = '/subscriptions/c22222e4-89fd-49ec-9ba0-3b33436cfd42/resourceGroups/rg-aks-test-itn/providers/Microsoft.Network/privateDnsZones/private.tombuca.com'

resource managedClusters_aks_test_itn_001_name_resource 'Microsoft.ContainerService/managedClusters@2025-02-01' = {
  name: clusterName
  location: location
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 2
        vmSize: agentPoolSize
        osDiskSizeGB: 80
        osDiskType: 'Managed'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        minCount: 2
        maxCount: 4
        kubeletDiskType: 'OS'
        vnetSubnetID: subnetId
        enableAutoScaling: true
        enableFIPS: false
        enableEncryptionAtHost: false
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        scaleSetPriority: 'Regular'
        scaleSetEvictionPolicy: 'Delete'
        orchestratorVersion: kubernetesVersion  
        enableNodePublicIP: false
        maxPods: 50
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        upgradeSettings: {
          maxSurge: '33%'
        }
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
      {
        name: 'userpool'
        count: 2
        vmSize: userPoolSize
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        kubeletDiskType: 'OS'
        minCount: 2
        maxCount: 4
        vnetSubnetID: subnetId
        enableAutoScaling: true
        enableFIPS: false
        enableEncryptionAtHost: false
        type: 'VirtualMachineScaleSets'
        mode: 'User'
        scaleSetPriority: 'Regular'
        scaleSetEvictionPolicy: 'Delete'
        orchestratorVersion: kubernetesVersion
        enableNodePublicIP: false
        maxPods: 30
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        upgradeSettings: {
          maxSurge: '33%'
        }
      }
    ]
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: false
      }
      azurepolicy: {
        enabled: true
      }
    }
    nodeResourceGroup: 'MC_rg-aks-test-itn_${clusterName}_italynorth'
    enableRBAC: true
    enablePodSecurityPolicy: false
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      podCidr: '192.168.0.0/16'
      networkPolicy: 'none'
      loadBalancerSku: 'Standard'
      loadBalancerProfile: null
      serviceCidr: '172.16.0.0/16'
      dnsServiceIP: '172.16.0.10'
      outboundType: 'loadBalancer'
    }
    identityProfile: {
      kubeletidentity: {
        resourceId: userAssignedIdentitiesId
        clientId: userAssignedIdentitiesClientId
        objectId: userAssignedIdentitiesObjectId
      }
    }
    autoScalerProfile: {
      'balance-similar-node-groups': 'false'
      expander: 'random'
      'max-empty-bulk-delete': '10'
      'max-graceful-termination-sec': '600'
      'max-node-provision-time': '15m'
      'max-total-unready-percentage': '45'
      'new-pod-scale-up-delay': '0s'
      'ok-total-unready-count': '3'
      'scale-down-delay-after-add': '10m'
      'scale-down-delay-after-delete': '10s'
      'scale-down-delay-after-failure': '3m'
      'scale-down-unneeded-time': '10m'
      'scale-down-unready-time': '20m'
      'scale-down-utilization-threshold': '0.5'
      'scan-interval': '10s'
      'skip-nodes-with-local-storage': 'false'
      'skip-nodes-with-system-pods': 'true'
    }
    apiServerAccessProfile: {
      authorizedIPRanges: clusterAuthorizedIPRanges
      enablePrivateCluster: false
    }
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
      nodeOSUpgradeChannel: 'NodeImage'
    }





    disableLocalAccounts: false
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      imageCleaner: {
        enabled: true
        intervalHours: 168
      }

    }
    storageProfile: {
      diskCSIDriver: {
        enabled: false
      }
      fileCSIDriver: {
        enabled: false
      }
      snapshotController: {
        enabled: false
      }
    }
    oidcIssuerProfile: {
      enabled: true
    }
    ingressProfile: {
      webAppRouting: {
        enabled: true
        dnsZoneResourceIds: [
          privateDnsZones_private_tombuca_com_externalid
        ]
        nginx: {
          defaultIngressControllerType: 'AnnotationControlled'
        }
      }
    }
    workloadAutoScalerProfile: {}
    azureMonitorProfile: {
      metrics: {
        enabled: true
        kubeStateMetrics: {}
      }
    }
    metricsProfile: {
      costAnalysis: {
        enabled: false
      }
    }
    bootstrapProfile: {
      artifactSource: 'Direct'
    }
  }
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource managedClusters_aks_test_itn_001_name_agentpool 'Microsoft.ContainerService/managedClusters/agentPools@2025-02-01' = {
  parent: managedClusters_aks_test_itn_001_name_resource
  name: 'agentpool'
  properties: {
    count: 2
    vmSize: 'Standard_D4as_v5'
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    vnetSubnetID: '${virtualNetworks_vnet_spoke_aks_test_itn_externalid}/subnets/snet-clusternodes-aks'
    maxPods: 110
    type: 'VirtualMachineScaleSets'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    maxCount: 5
    minCount: 2
    enableAutoScaling: true
    scaleDownMode: 'Delete'
    powerState: {
      code: 'Running'
    }
    orchestratorVersion: '1.31.7'
    enableNodePublicIP: false
    nodeTaints: [
      'CriticalAddonsOnly=true:NoSchedule'
    ]
    mode: 'System'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    upgradeSettings: {
      maxSurge: '10%'
    }
    enableFIPS: false
    securityProfile: {
      enableVTPM: false
      enableSecureBoot: false
    }
  }
}

resource managedClusters_aks_test_itn_001_name_userpool 'Microsoft.ContainerService/managedClusters/agentPools@2025-02-01' = {
  parent: managedClusters_aks_test_itn_001_name_resource
  name: 'userpool'
  properties: {
    count: 2
    vmSize: 'Standard_D4as_v5'
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    kubeletDiskType: 'OS'
    vnetSubnetID: '${virtualNetworks_vnet_spoke_aks_test_itn_externalid}/subnets/snet-clusternodes-aks'
    maxPods: 30
    type: 'VirtualMachineScaleSets'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    maxCount: 6
    minCount: 1
    enableAutoScaling: true
    scaleDownMode: 'Delete'
    powerState: {
      code: 'Running'
    }
    orchestratorVersion: '1.31.7'
    enableNodePublicIP: false
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
    upgradeSettings: {}
    enableFIPS: false
    securityProfile: {
      enableVTPM: false
      enableSecureBoot: false
    }
  }
}

