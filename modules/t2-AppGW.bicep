
param location string = resourceGroup().location
param AppGWName string
@description('Generated from /subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01')
resource AppGW 'Microsoft.Network/applicationGateways@2022-05-01' = {
  name: AppGWName
  location: location
  tags: {
  }
  properties: {
    sku: {
      name: 'Standard_Medium'
      tier: 'Standard'
      capacity: 2
    }
    identity: {
      type: 'SystemAssigned'
      //userAssignedIdentities: {}
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: 
          }
        }
      }
    ]
    sslCertificates: []
    authenticationCertificates: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/frontendIPConfigurations/appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/publicIPAddresses/AppGW-01-pip'
          }
          httpListeners: [
            {
              id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/httpListeners/listener01'
            }
          ]
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/frontendPorts/port_80'
        properties: {
          port: 80
          httpListeners: [
            {
              id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/httpListeners/listener01'
            }
          ]
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bkppool01'
        id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/backendAddressPools/bkppool01'
        properties: {
          backendAddresses: []
          requestRoutingRules: [
            {
              id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/requestRoutingRules/rule01'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'bkpsettings01'
        id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/backendHttpSettingsCollection/bkpsettings01'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          requestRoutingRules: [
            {
              id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/requestRoutingRules/rule01'
            }
          ]
        }
      }
    ]
    httpListeners: [
      {
        name: 'listener01'
        id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/httpListeners/listener01'
        properties: {
          frontendIPConfiguration: {
            id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
          requestRoutingRules: [
            {
              id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/requestRoutingRules/rule01'
            }
          ]
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'rule01'
        id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/requestRoutingRules/rule01'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/httpListeners/listener01'
          }
          backendAddressPool: {
            id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/backendAddressPools/bkppool01'
          }
          backendHttpSettings: {
            id: '/subscriptions/d8e9edd6-0b2f-438b-b703-7f2c4d434434/resourceGroups/private-aks-rg/providers/Microsoft.Network/applicationGateways/AppGW01/backendHttpSettingsCollection/bkpsettings01'
          }
        }
      }
    ]
    probes: []
    rewriteRuleSets: []
    redirectConfigurations: []
    enableHttp2: false
  }
}
}
