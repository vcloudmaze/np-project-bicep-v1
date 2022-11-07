targetScope = 'resourceGroup'
param uaminame string = 'uami-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: uaminame
  location: location
  
}

//output managedIdentityId object = managedIdentity.name
//output managedIdentityServicePrincipalId object = managedIdentity.properties.principalId
//output managedIdentityServicePrincipalpwd object = managedIdentity.properties.tenantId
output uamiClientId string = managedIdentity.properties.clientId
output uamiPrincipleId string = managedIdentity.properties.principalId
output uamiTanentId string = managedIdentity.properties.tenantId
