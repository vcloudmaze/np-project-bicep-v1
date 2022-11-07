// Execute this main file to configure Azure Machine Learning end-to-end in a moderately secure set up
// set the target scope to subscription
//targetScope = 'subscription'
//az deployment sub create -f ./private-aks.bicep -l eastus
//az deployment group create --resource-group private-aks-rg --template-file ./main.bicep
// Parameters
@minLength(2)
@maxLength(10)
@description('Prefix for all resource names.')
param prefix string = 'kvaks'

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Virtual network address prefix')
param vnetAddressPrefix string = '192.168.0.0/16'

@description('Training subnet address prefix')
param trainingSubnetPrefix string = '192.168.0.0/24'

@description('Scoring subnet address prefix')
param scoringSubnetPrefix string = '192.168.1.0/24'

@description('Bastion subnet address prefix')
param azureBastionSubnetPrefix string = '192.168.250.0/27'

@description('Deploy a Bastion jumphost to access the network-isolated environment?')
param deployJumphost bool = true

@description('Jumphost virtual machine username')
param dsvmJumpboxUsername string = 'vcmazeadmin'

@secure()
@minLength(8)
@description('Jumphost virtual machine password')
param dsvmJumpboxPassword string

//@description('Enable public IP for Azure Machine Learning compute nodes')
//param amlComputePublicIp bool = true

@description('VM size for the default compute cluster')
param amlComputeDefaultVmSize string = 'Standard_B2s'   //'Standard_DS2_v2' //'Standard_DS3_v2'

// Variables
var name = toLower('${prefix}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// Virtual network and network security group
module nsg './modules/nsg.bicep' = { 
  name: 'nsg-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    tags: tags 
    nsgName: 'nsg-${name}-${uniqueSuffix}'
  }
}

module vnet './modules/vnet.bicep' = { 
  name: 'vnet-${name}-${uniqueSuffix}'
  params: {
    location: location
    virtualNetworkName: 'vnet-${name}-${uniqueSuffix}'
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup
    vnetAddressPrefix: vnetAddressPrefix
    trainingSubnetPrefix: trainingSubnetPrefix
    scoringSubnetPrefix: scoringSubnetPrefix
    tags: tags
  }
}

// Dependent resources for the Azure Machine Learning workspace
module keyvault './modules/keyvault.bicep' = {
  name: 'kv-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    keyvaultName: 'kv-${name}-${uniqueSuffix}'
    keyvaultPleName: 'ple-${name}-${uniqueSuffix}-kv'
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    virtualNetworkId: vnet.outputs.id
    tags: tags
  }
}

module storage './modules/storage.bicep' = {
  name: 'st${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    storageName: 'st${name}${uniqueSuffix}'
    storagePleBlobName: 'ple-${name}-${uniqueSuffix}-st-blob'
    storagePleFileName: 'ple-${name}-${uniqueSuffix}-st-file'
    storageSkuName: 'Standard_LRS'
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    virtualNetworkId: vnet.outputs.id
    tags: tags
  }
}

module containerRegistry './modules/containerregistry.bicep' = {
  name: 'cr${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    containerRegistryName: 'cr${name}${uniqueSuffix}'
    containerRegistryPleName: 'ple-${name}-${uniqueSuffix}-cr'
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    virtualNetworkId: vnet.outputs.id
    tags: tags
  }
}

module applicationInsights './modules/applicationinsights.bicep' = {
  name: 'appi-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    applicationInsightsName: 'appi-${name}-${uniqueSuffix}'
    tags: tags
  }
}


/*
module azuremlWorkspace 'modules/machinelearning.bicep' = {
  name: 'mlw-${name}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    machineLearningName: 'mlw-${name}-${uniqueSuffix}'
    machineLearningFriendlyName: 'Private link endpoint sample workspace'
    machineLearningDescription: 'This is an example workspace having a private link endpoint.'
    location: location
    prefix: name
    tags: tags

    // dependent resources
    applicationInsightsId: applicationInsights.outputs.applicationInsightsId
    containerRegistryId: containerRegistry.outputs.containerRegistryId
    keyVaultId: keyvault.outputs.keyvaultId
    storageAccountId: storage.outputs.storageId

    // networking
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    computeSubnetId: '${vnet.outputs.id}/subnets/snet-training'
    aksSubnetId: '${vnet.outputs.id}/subnets/snet-scoring'
    virtualNetworkId: vnet.outputs.id
    machineLearningPleName: 'ple-${name}-${uniqueSuffix}-mlw'

    // compute
    amlComputePublicIp: amlComputePublicIp
    mlAksName: 'aks-${name}-${uniqueSuffix}'
    vmSizeParam: amlComputeDefaultVmSize
  }
  dependsOn: [
    keyvault
    containerRegistry
    applicationInsights
    storage
  ]
}
*/
// Optional VM and Bastion jumphost to help access the network isolated environment
module dsvm './modules/dsvmjumpbox.bicep' = if (deployJumphost) {
  name: 'vm-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    virtualMachineName: 'vm-${name}-${uniqueSuffix}'
    subnetId: '${vnet.outputs.id}/subnets/snet-training'
    adminUsername: dsvmJumpboxUsername
    adminPassword: dsvmJumpboxPassword
    networkSecurityGroupId: nsg.outputs.networkSecurityGroup
    vmSizeParameter: amlComputeDefaultVmSize
  }
}

module bastion './modules/bastion.bicep' = if (deployJumphost) {
  name: 'bas-${name}-${uniqueSuffix}-deployment'
  params: {
    bastionHostName: 'bas-${name}-${uniqueSuffix}'
    location: location
    vnetName: vnet.outputs.name
    addressPrefix: azureBastionSubnetPrefix
  }
  dependsOn: [
    vnet
  ]
}

module aks './modules/privateaks.bicep' = {
  name: 'aks-${name}-${uniqueSuffix}'
  params:{
    aksClusterName:'aks-${name}-${uniqueSuffix}'
    location: location
    vmSizeParam:amlComputeDefaultVmSize
     aksSubnetId:'${vnet.outputs.id}/subnets/snet-training'
      tags:tags
      
     
  }
}

var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aks.name, acrPullRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    principalId: aks.outputs.aksmanagedIdentity
    roleDefinitionId: acrPullRoleDefinitionId
    principalType: 'ServicePrincipal'
  }
}

param uamidlocation string = location
module uamid 'modules/UAManagedIdentity.bicep'={
  scope:  resourceGroup()
  name: '${prefix}-uami-${uniqueString (uamidlocation)}'
  params: {
    uaminame: '${prefix}-uami-${uniqueString (uamidlocation)}'
  location: uamidlocation
  }

}
/*
module AppGW './modules/t-AppGW.bicep' = {
  name:'AppGW-${name}-${uniqueSuffix}'
  scope:resourceGroup()
  
params:{
  //appgwsubnetid: vnet.outputs.appgwsubnet
  applicationGatewayName: 'AppGW-${name}-${uniqueSuffix}'
  location:location
  //vnet:vnet.outputs.name
  AppGWSubnet:vnet.outputs.appgwsubnet
}
 dependsOn:[
  vnet
 ]
  }
  
*/

/*
  module appgw 'modules/t4-AppGW.bicep' = {
name:'AppGW${name}${uniqueSuffix}'
scope:resourceGroup()
dependsOn:[
  vnet
]

params:{
  location: location
  sku: 'Standard_v2'
  applicationGatewayName: 'AppGW${name}${uniqueSuffix}'
  autoScaleMaxCapacity: 3
  capacity: 3
  cookieBasedAffinity: 'Disable'
  //firewallPolicyId
  http2Enabled: true
  //keyVaultSecretid: 
  //managedIdentityName: 'umidAppGW${name}${uniqueSuffix}'
  managedIdentityName:uamid.name
  pickHostNameFromBackendAddress: false
  port: 80
  privateIPAllocationMethod: 'Dynamic'
  protocol: 'Http'
  publicIPAllocationMethod: 'Static'
  publicIpAddressName: 'AppGW${name}${uniqueSuffix}_pip'
  publicIpSku: 'Standard'
  requestRoutingRuleType: 'Basic'
  requestTimeout: 20
  requireServerNameIndication:false
  resourceGroup: resourceGroup().name
  //sslCertificateName: 
  subnetName: vnet.outputs.appgwsubnet
  subscriptionId: subscription().id
  tier: 'Standard_v2'
  vNetName: vnet.name
  //webAppFqdn: 
}

  }
*/
module AppGW 'modules/t6-AppGW.bicep' = {
  name: '${prefix}AppGW${name}${uniqueSuffix}'
dependsOn:[
  vnet
]
  params: {
    location:location
    AppGWpublicIpAddressName: '${prefix}AppGW${name}${uniqueSuffix}-pip'
    applicationGatewayName: '${prefix}AppGW${name}${uniqueSuffix}'
    virtualNetwork: vnet.name
  }
}

