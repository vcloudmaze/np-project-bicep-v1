param applicationGatewayName string
param location string = resourceGroup().location
//param appgwsubnetid string
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)


//param vnet string 
param AppGWSubnet string


var publicIPAddress_name = 'AppGW01-pip-${uniqueSuffix}'



resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: publicIPAddress_name
  location: location
  
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'dvapgwpip${uniqueSuffix}'
    }
  }
}

output appgwpip string = publicIPAddress.id

resource applicationGateway 'Microsoft.Network/applicationGateways@2020-06-01' = {
  name: applicationGatewayName
  location: location
  
  properties: {
    enableHttp2: true
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: applicationGatewayName
        properties: {
          subnet: {
            //id: resourceId(resourceGroup().name,'Microsoft.Network/virtualNetworks/subnets', vnet, 'ApplicationGatewaySubnet')
            id: AppGWSubnet
          }
        }
      }
    ]
    sslCertificates: []
    authenticationCertificates: []
    frontendIPConfigurations: [
      {
        name: publicIPAddress.name
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            //id: resourceId(resourceGroup().name,'Microsoft.Network/publicIPAddresses', publicIPAddress.name)
            id: publicIPAddress.id
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
    
    backendAddressPools: [
      {
        name: 'bkppool1'
        properties: {}
      }
      
    ]
    /*
    probes: [
      {
        name: 'probe'
        properties: {
          protocol: 'Http'
          pickHostNameFromBackendHttpSettings: true
          path: '/'
          interval: 30
          timeout: 30
          port: 80
          match: {
            statusCodes: [
              '200'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: [
      {
        name: 'add-forwarded-host-header'
        properties: {
          rewriteRules: [
            {
              ruleSequence: 100
              name: 'add-forwarded-host-header'
              actionSet: {
                requestHeaderConfigurations: [
                  {
                    headerName: 'X-Forwarded-Host'
                    headerValue: '{var_host}'
                  }
                ]
              }
            }
          ]
        }
      }
    ]
    */
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          probeEnabled: false
          /*
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'probe')
          }
          */
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener-http'
        properties: {
          frontendIPConfiguration: {
            //id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGatewayFrontendIP')
            id: resourceId(resourceGroup().name,'Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, publicIPAddress.name)
          }
          frontendPort: {
            id: resourceId(resourceGroup().name,'Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
        }
      }
      
    ]
    /*
    redirectConfigurations: [
      {
        name: 'to-http'
        properties: {
          //redirectType: 'Permanent'
          includePath: false
          includeQueryString: false
          targetListener: {
            id: resourceId(resourceGroup().name,'Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'appGatewayHttpListener-http')
          }
        }
      }
    ]
    */
    requestRoutingRules: [
      {
        name: 'https-rule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId(resourceGroup().name,'Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'appGatewayHttpListener-http')
          }
          redirectConfiguration: {
            id: resourceId(resourceGroup().name,'Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'to-http')
          }
        }
      }
      
    ]
    
  }
  
}

output appgwname string = applicationGateway.name
