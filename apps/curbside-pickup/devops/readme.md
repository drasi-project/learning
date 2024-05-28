# Deploy Curbside Demo

## Login to Azure CLI

```bash
az login
```

## Deploy the Azure resources

From the `curbside-pickup/devops` folder deploy the `curbside.bicep` template.
This will deploy the CosmosDb, storage account and function app resources that will be required.

```bash
az deployment group create --resource-group project-drasi-demo --template-file curbside.bicep
```

## Deploy the Functions App

From the `curbside-pickup/functions` folder, build and deploy the functions app

```bash
npm install
func azure functionapp publish drasi-curbside-demo-app --javascript
```

## Deploy the Front End

Ensure you have [AzCopy](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10) installed.

Double check the `config.json` file under `/app/src` to ensure the Urls are correct.

```json
{
  "crudApiUrl": "https://drasi-curbside-demo-app.azurewebsites.net",
  "signalRUrl": "https://rg-demo-signalr.happycoast-8bd2f07c.westus.azurecontainerapps.io/hub",
  ...
}
```

From the `curbside-pickup/app` folder, build the react app

```bash
npm install
npm run build
```

Login with AzCopy

```bash
azcopy login
```

Publish the built react app to the static website

```bash
azcopy sync './build' 'https://drasicurbside.blob.core.windows.net/$web'
```

## Add the Pickup zone data

Login to the Azure portal and navigate to the [Data explorer of the CosmosDb account](https://ms.portal.azure.com/#@microsoft.onmicrosoft.com/resource/subscriptions/2865c7d1-29fa-485a-8862-717377bdbf1b/resourceGroups/project-drasi-demo/providers/Microsoft.DocumentDB/databaseAccounts/curbside-demo/dataExplorer)

Expand the `Contoso/PhysicalOperations` Graph

Execute each of these Gremlin queries in the query box

```javascript
g.addV('Zone').property('name','Curbside Queue').property('type','Curbside Queue')
```

```javascript
g.addV('Zone').property('name','Parking Lot').property('type','Parking Lot')
```

## Deploy the sources

Currently, we are unable to create a Kubernetes Secret using the Drasi CLI, so it needs to be manaually created using `kubectl`. Navigate to your CosmosDB account in the Azure Portal. You will need to retrieve the value of `PRIMARY CONNECTION STRING` from the `Keys` blade. Run the following command to create the secrets:

```bash
kubectl create secret generic phys-ops-creds --from-literal=accountEndpoint=${PRIMARY CONNECTION STRING}
kubectl create secret generic retail-ops-creds --from-literal=accountEndpoint=${PRIMARY CONNECTION STRING}
```
Navigate to the `/apps/curbside-pickup/devops` folder, and from there, you can deploy the two sources using the Drasi CLI:

```bash
drasi apply -f phys-ops-source.yaml
drasi apply -f retail-ops-source.yaml
```
## Deploy the queries

Use the drasi CLI to deploy the continuous queries

```bash
drasi apply -f queries-with-gremlin.yaml
```

## Deploy the reactor

Use the drasi CLI to deploy the SignalR reaction

```bash
drasi apply -f signalr-reaction.yaml
```
