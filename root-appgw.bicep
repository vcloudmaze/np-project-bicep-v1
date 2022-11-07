param deploymentName string = 'appgw${utcNow()}'

module appGateway 'modules/t5-AppGW.bicep' = {
  name: deploymentName
  scope:resourceGroup()
  dependsOn:[
    aks
    vnet
  ]
  params: {
    location:location
    applicationGatewayName: 'AppGW${name}${uniqueSuffix}'
    sku: 'Standard_v2'
    tier: 'Standard_v2'
    zoneRedundant: true
    publicIpAddressName: 'AppGW${name}${uniqueSuffix}_pip'
    vNetResourceGroup: resourceGroup().name
    vNetName: vnet.name
    subnetName: vnet.outputs.appgwsubnet
    frontEndPorts: [
      {
        name: 'port_80'
        port: 80
      }
    ]
    httpListeners: [
      {
        name: 'HttpListener01'
        protocol: 'Http'        
        frontEndPort: 'port_80'
      }
    ]
    backendAddressPools: [
      {
        name: 'MyBackendPool'
        /*
        backendAddresses: [
          {
            ipAddress: '10.1.2.3'
          }
        ]
        */
      }
    ]
    backendHttpSettings: [
      {
        name: 'MyBackendHttpSetting'
        port: 80
        protocol: 'Http'
        cookieBasedAffinity: 'Enabled'
        affinityCookieName: 'MyCookieAffinityName'
        requestTimeout: 300
        connectionDraining: {
          drainTimeoutInSec: 60
          enabled: true
        }
      }
    ]
    rules: [
      {
        name: 'MyRuleName'
        ruleType: 'Basic'
        listener: 'MyHttpListener'
        backendPool: 'MyBackendPool'
        backendHttpSettings: 'MyBackendHttpSetting'
      }
    ]
    enableDeleteLock: true
    enableDiagnostics: true
    logAnalyticsWorkspaceId: aks.outputs.logAnalyticsWorkspaceResourceID
    diagnosticStorageAccountId: storage.outputs.storageId
  }
  
}
