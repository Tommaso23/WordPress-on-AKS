param applicationGatewayName string
param location string
param applicationGatewaySubnetId string
param appGatewayPublicIpAddressId string
param internalLoadBalancerIp string

resource applicationGateways_agw_aks_test_itn_name_resource 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: applicationGatewayName
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      family: 'Generation_1'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: applicationGatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        properties: {
          publicIPAddress: {
            id: appGatewayPublicIpAddressId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
    enableHttp2: true
    backendAddressPools: [
      {
        name: 'be-loadBalancerIp'
        properties: {
          backendAddresses: [
            {
              ipAddress: internalLoadBalancerIp
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'aks-ingress-bpool-http'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'listener-http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicFrontendIpIPv4')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    listeners: []
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'apw-routing-rule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-http')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'be-loadBalancerIp')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'aks-ingress-bpool-http')
          }
        }
      }
    ]
    probes: [
      {
        name: 'probe-aks-internal-lb'
        properties: {
          protocol: 'Http'
          path: '/healthz'
          host: '10.100.0.62'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {}
        }
      }
    ]
  }
}
