param deploymentName string = 'drasi-curbside-demo'

param cosmosAccountName string = 'reactive-graph-demo'

param storageAccountName string = 'drasicurbside'

param location string = resourceGroup().location


resource contosoGraphDB 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: toLower(cosmosAccountName)
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    backupPolicy: {
      type: 'Continuous'
    }
    databaseAccountOfferType: 'Standard'
    locations: [ 
      { 
        locationName: location
      }
    ]
    capabilities: [
      {
        name: 'EnableGremlin'
      }
      {
        name: 'EnableServerless'
      }
    ]
  }
  
  resource database 'gremlinDatabases' = {
    name: 'Contoso'
    properties: {
      resource: {
        id: 'Contoso'
      }
      
    }

    resource physicalGraph 'graphs' = {
      name: 'PhysicalOperations'
      properties: {
        resource: {
          id: 'PhysicalOperations'
          partitionKey: {
            kind: 'Hash'
            paths: [
              '/name'
            ]
          }
          indexingPolicy: {
            indexingMode: 'consistent'
            automatic: true
            includedPaths: [
              {
                path: '/*'
              }
            ]
          }  
        }
      }
    }
    resource retailGraph 'graphs' = {
      name: 'RetailOperations'
      properties: {
        resource: {
          id: 'RetailOperations'
          partitionKey: {
            kind: 'Hash'
            paths: [
              '/name'
            ]
          }
          indexingPolicy: {
            indexingMode: 'consistent'
            automatic: true
            includedPaths: [
              {
                path: '/*'
              }
            ]
          }  
        }
      }
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location  
  sku: {
    name: 'Standard_LRS'    
  }
  properties: {
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    isHnsEnabled: true
    accessTier: 'Hot'
    dnsEndpointType: 'Standard'    
  }
  kind: 'StorageV2'
}

resource webContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${storageAccount.name}/default/$web'  
  properties: {
    publicAccess: 'Blob'
  }
}

resource azHostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${deploymentName}-asp'
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
  }
}

resource azFunctionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: '${deploymentName}-app'
  kind: 'functionapp'
  location: location
  identity: {
    type: 'SystemAssigned'
  }  
  properties: {
    serverFarmId: azHostingPlan.id
    enabled: true
    siteConfig: {
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
      appSettings: [
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
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~16'
        }
        {
          name: 'RETAIL_OPS_URL'
          value: 'wss://${contosoGraphDB.name}.gremlin.cosmos.azure.com:443/'
        }
        {
          name: 'RETAIL_OPS_DB_NAME'
          value: 'Contoso'
        }
        {
          name: 'RETAIL_OPS_CNT_NAME'
          value: 'RetailOperations'
        }
        {
          name: 'RETAIL_OPS_KEY'
          value: contosoGraphDB.listKeys().primaryMasterKey
        }
        {
          name: 'PHYSICAL_OPS_URL'
          value: 'wss://${contosoGraphDB.name}.gremlin.cosmos.azure.com:443/'
        }
        {
          name: 'PHYSICAL_OPS_DB_NAME'
          value: 'Contoso'
        }
        {
          name: 'PHYSICAL_OPS_CNT_NAME'
          value: 'PhysicalOperations'
        }
        {
          name: 'PHYSICAL_OPS_KEY'
          value: contosoGraphDB.listKeys().primaryMasterKey
        }
      ]
    }
  }
}

resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  // This is the Storage Account Contributor role, which is the minimum role permission we can give. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=17d1049b-9a84-46fb-8f53-869881c3d3ab
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'DeploymentScript'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: storageAccount
  name: guid(resourceGroup().id, managedIdentity.id, contributorRoleDefinition.id)
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deploymentScript'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  dependsOn: [
    roleAssignment
  ]
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: loadTextContent('./enable-static-website.ps1')
    retentionInterval: 'PT4H'
    environmentVariables: [
      {
        name: 'ResourceGroupName'
        value: resourceGroup().name
      }
      {
        name: 'StorageAccountName'
        value: storageAccount.name
      }
    ]
  }
}

output FrontEndUrl string = storageAccount.properties.primaryEndpoints.web
output CosmosDb string = contosoGraphDB.id
output FunctionApp string = azFunctionApp.properties.defaultHostName
output StorageAccount string = storageAccount.name
