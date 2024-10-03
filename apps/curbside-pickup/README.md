# Curbside pickup notification application
This README describes how to install and deploy the Curbside Pickup app fon self-hosted Drasi. Before proceeding please familiarize yourself with the overview of the app, its architecture, and how to self-host it in your cluster.
## Overview

This application acts as a efficiemt notification service for delivery drivers, notifying them when orders are ready for pickup and they need to drive to the curbside pickup zones. The description details how to use Azure Functions and Drasi to build an uncomplicated solution for alerting.

### Prerequisistes
* NodeJs
* [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local)
* An Azure account
* [AzCopy](https://learn.microsoft.com//azure/storage/common/storage-use-azcopy-v10?tabs=dnf)
* Kubectl
* Drasi deployed to the Kubernetes cluster. Your kubectl context points to this cluster
* Drasi CLI
* This repo folder cloned to a folder on your local machine

This app has the following elements
* 2 Sources watching for changes in separate databases.
* Continuous Queries  subscribed to each Source
* One Continuous Query that joins events across the two databases
* A SignalR Reaction that receives changes and forwards them to any connected frontend clients
* An Azure Function App that provides Http endpoints to update data in the databases
* A React frontend that invokes updates via the function app and listens for changes via the SignalR Reaction.

# Setup
## Setting up the databases
1. Login to Azure CLI
   
   `
      az login
   `
   
1. From the curbside-pickup/devops folder deploy the curbside.bicep template. This will deploy the CosmosDb, storage account and function app resources that will be required. Add your resource group to the command and then run.

  `
  az deployment group create --resource-group <your resource group> --template-file curbside.bicep
  `

2. Insert your resource group name and pick a name for your CosmosDb account, for example:

  `
  az deployment group create -f database.bicep --resource-group <your resource group> -p cosmosAccountName=my-drasi-db
  `
  
   This will create a new CosmosDb account with the Gremlin API and a database named Contoso with 2 empty graphs, named PhysicalOperations and RetailOperations.

3. Add the Pickup zone data. For this, login to the Azure portal and navigate to the Data explorer blade of your CosmosDb account, expand the Contoso/PhysicalOperations Graph and execute each of these Gremlin queries in the query box.

    `
      g.addV('Zone').property('name','Curbside Queue').property('type','Curbside Queue')
       `
 
    `
     g.addV('Zone').property('name','Parking Lot').property('type','Parking Lot')
      `
4. Create Kubernetes Secrets to help you connect to the the database. Use kubectl for this. Navigate to your CosmosDB account in the Azure Portal. You will need to retrieve the value of PRIMARY CONNECTION STRING from the Keys blade. Run the following command to create the secrets:

  `
  kubectl create secret generic phys-ops-creds --from-literal=accountEndpoint=${PRIMARY CONNECTION STRING}
  kubectl create secret generic retail-ops-creds --from-literal=accountEndpoint=${PRIMARY CONNECTION STRING}
  `
## Deploy the Azure Functions app
1. From the curbside-pickup/functions folder, build and deploy the functions app
    `
   npm install
   func azure functionapp publish drasi-curbside-demo-app --javascript
   `
##  Deploy the frontend client
 Ensure that you have [AzCopy](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?tabs=dnf) installed. This is a command line utility to copy blobs and files from storage accounts. Also, check to confirm the followin URLs in the config.json file under /app/src are correct.
 
 `
 {
  "crudApiUrl": "https://drasi-curbside-demo-app.azurewebsites.net",

  "signalRUrl": "https://rg-demo-signalr.happycoast-8bd2f07c.westus.azurecontainerapps.io/hub",
  ...
}
 `

1. From the curbside-pickup/app folder, build the React app
   `
   npm install
   npm run build
   `

 2. Login with AzCopy

    `
    azcopy login
    `

3. Publish the built react app to the static website

   `
   azcopy sync './build' 'https://drasicurbside.blob.core.windows.net/$web'
   `

   ## Deploy Sources

   Now that we have the foundation in place, let start deploying Drasi Sources.
   
   1. Navigate to the /apps/curbside-pickup/devops folder, and from there, you can deploy the two sources using the Drasi CLI:

  ` 
    drasi apply -f phys-ops-source.yaml
    drasi apply -f retail-ops-source.yaml
  `

  ## Apply Continuous Queries
 Next we will apply the Continuos Queries defined in the queries-with-gremlin.yaml file.

 1. Use the Drasi CLI to deploy the continuous queries

  `
  drasi apply -f queries-with-gremlin.yaml
  `

 ## Deploy Reactions
1. Use the Drasi CLI to deploy the SignalR Reaction described earlier
`
drasi apply -f signalr-reaction.yaml
`

2. Create a port forward for the SignalR reaction to an available port on your local machine. Currently we have to use kubectl to achieve this.

`
kubectl port-forward services/signalr1-reaction-gateway 5001:8080 -n default
`
## View changes in the dashboard

1. From the /apps/curbside-pickup/app folder, start the React app
   `
   npm start
   `
   The dashboard will be accessible at http://localhost:3000. It will display sections showing drivers and their vehicles in the parking lot and at the curbside queue, orders that are ready for pickup and those that are being prepared, and importantly, a section that shows orders that are ready matched to pickup drivers in the pickup zone.








  
