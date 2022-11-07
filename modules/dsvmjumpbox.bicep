// Creates a Data Science Virtual Machine jumpbox.
@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('Resource ID of the subnet')
param subnetId string

@description('Network Security Group Resource ID')
param networkSecurityGroupId string

@description('Virtual machine name')
param virtualMachineName string

@description('Virtual machine size')
param vmSizeParameter string

@description('Virtual machine admin username')
param adminUsername string

@secure()
@minLength(8)
@description('Virtual machine admin password')
param adminPassword string

var aadLoginExtensionName = 'AADLoginForWindows'

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${virtualMachineName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroupId
    }
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSizeParameter
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        //publisher: 'microsoft-dsvm'
        //offer: 'dsvm-win-2019'
        //sku: 'server-2019'
        publisher: 'MicrosoftWindowsDesktop' //'MicrosoftWindowsServer'
        offer: 'Windows-10'//'WindowsServer'
        sku: '21h1-ent-g2'  //'2016-datacenter-gensecond'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'AutomaticByOS'
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource virtualMachineName_aadLoginExtensionName 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${virtualMachine.name}/${aadLoginExtensionName}'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: aadLoginExtensionName
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

param virtualMachineExtensionCustomScriptUri string = 'https://raw.githubusercontent.com/sathishphcl/MyChocoTools/main/install.ps1'
// Virtual Machine Extensions - Custom Script
var virtualMachineExtensionCustomScript = {
  name: '${virtualMachineName}/config-app'
  location: location
  fileUris: [
    virtualMachineExtensionCustomScriptUri
  ]
  commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ./${last(split(virtualMachineExtensionCustomScriptUri, '/'))}'
}
resource windowsVMExtensions 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: virtualMachine
  name: 'chocolaty'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: virtualMachineExtensionCustomScript.fileUris
      commandToExecute: virtualMachineExtensionCustomScript.commandToExecute
    }
    //protectedSettings: {commandToExecute: virtualMachineExtensionCustomScript.commandToExecute}
  }
}


output dsvmId string = virtualMachine.id
