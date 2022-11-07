// Creates an Azure Kubernetes Services and attaches it to the Azure Machine Learning workspace
@description('Name of the Azure Kubernetes Service cluster')
param aksClusterName string

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Resource ID for the Azure Kubernetes Service subnet')
param aksSubnetId string

//@description('Name of the Azure Machine Learning workspace')
//param workspaceName string

//@description('Name of the Azure Machine Learning attached compute')
//param computeName string

@description('Size of the virtual machine')
param vmSizeParam string // = 'Standard_DS2_v2'

//param logAnalyticsWorkspaceResourceID string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-04-01' = {
  name: aksClusterName
  location: location
  //tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.23.12'
    dnsPrefix: '${aksClusterName}-dns'
    agentPoolProfiles: [
      {
        name: toLower('agentpool')
        count: 2
        vmSize: vmSizeParam
        osDiskSizeGB: 128
        vnetSubnetID: aksSubnetId
        maxPods: 110
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]
    //Added RBAC Enabled, If not works delete this slot
    enableRBAC: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
      
    }
    //Delete this slot if not working
    
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalytics.id
          
        }
      }
      /*
      //Add this code when you have AppGw and use it as Ingress controller, Delete if not successfull
      //****************************************
      ingressApplicationGateway: {
        enabled: true
        config: {
            applicationGatewayName: AppGWName
            subnetId: vnet.outputs.appgwsubnet //(Uncomment this and provide AppGW subnet ID param/var here)
            // subnetCIDR: '10.10.1.0/24'
          
        }
      }
      //*****************************************
      */
    }
    
    //Delete if this slot not working
    //**************************
    podIdentityProfile: {
      enabled: true
    }
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
    }
    //***************************
    
    networkProfile: {
      //networkPlugin: 'kubenet'
      networkPlugin: 'azure'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      dockerBridgeCidr: '172.17.0.1/16'
      loadBalancerSku: 'standard'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
    }
  }
}

output aksResourceId string = aksCluster.id
output aksmanagedIdentity string = aksCluster.identity.principalId
/*
resource workspaceName_computeName 'Microsoft.MachineLearningServices/workspaces/computes@2022-05-01' = {
  name: '${workspaceName}/${computeName}'
  location: location
  properties: {
    computeType: 'AKS'
    resourceId: aksCluster.id
    properties: {
      aksNetworkingConfiguration:  {
        subnetId: aksSubnetId
      }
    }
  }
}
*/

//Remove if not working
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: 'aks-workspace-${uniqueString(resourceGroup().id)}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}


output logAnalyticsWorkspaceResourceID string = logAnalytics.id

