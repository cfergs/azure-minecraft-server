// like creating a lambda but more complicated
// microsoft, why is this so much harder than aws ???

param containerGroupName string
param logAnalyticsWorkspaceId string
param uniquePrefix string

var appServiceName = 'appservice-${uniquePrefix}'
var functionAppName = 'functionapp-${uniquePrefix}'
var storageAccountName = 'function${uniquePrefix}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'applicationinsight-${uniquePrefix}'
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

resource appService 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServiceName
  location: resourceGroup().location
  kind: 'functionapp,linux'
  properties: {
    reserved: true // must enable otherwise will deploy as windows OS
  }
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: resourceGroup().location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appService.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'MINECRAFT_CONTAINER_GROUP'
          value: containerGroupName
        }
        {
          name: 'MINECRAFT_RESOURCE_GROUP'
          value: resourceGroup().name
        }
        {
          name: 'MINECRAFT_SUBSCRIPTION_ID'
          value: subscription().subscriptionId
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
      ]
      linuxFxVersion: 'Python|3.11'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource functionAppBinding 'Microsoft.Web/sites/hostNameBindings@2023-12-01' = {
  parent: functionApp
  name: '${functionApp.name}.azurewebsites.net'
  properties: {
    siteName: functionApp.name
    hostNameType: 'Verified'
  }
}

// Assign the function managed identity permissions to the container group
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' existing = {
  name: containerGroupName
}

resource containerIdentityAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerGroupName, functionApp.name)
  scope: containerGroup
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '5d977122-f97e-4b4d-a52f-6b43003ddb4d') // Azure Container Instances Contributor Role
    principalId: functionApp.identity.principalId
  }
}
