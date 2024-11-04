targetScope = 'subscription'
// res grp done seperately as targetscope differs for sub resources
resource resGrp 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'minecraft'
  location: 'australiaeast'
}

var uniquePrefix = uniqueString(resGrp.id)

module log_analytics 'log-analytics.bicep' = {
  name: 'logs'
  scope: resGrp
  params: {
    uniquePrefix: uniquePrefix
  }
}

module container 'container.bicep' = {
  name: 'container'
  scope: resGrp
  params: {
    logAnalyticsWorkspaceName: log_analytics.outputs.logAnalyticsWorkspaceName
    uniquePrefix: uniquePrefix
  }
}

module function_app 'function-app.bicep' = {
  name: 'function'
  scope: resGrp
  params: {
    containerGroupName: container.outputs.containerGroupName
    logAnalyticsWorkspaceId: log_analytics.outputs.logAnalyticsWorkspaceId
    uniquePrefix: uniquePrefix
  }
}
