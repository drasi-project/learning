param cosmosAccountName string = 'reactive-graph-demo'
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
  
      resource facilitiesGraph 'graphs' = {
        name: 'Facilities'
        properties: {
          resource: {
            id: 'Facilities'
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

