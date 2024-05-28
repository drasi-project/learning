param cosmosAccountName string

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


output CosmosDbId string = contosoGraphDB.id
output GremlinUrl string = 'wss://${contosoGraphDB.name}.gremlin.cosmos.azure.com:443/'
