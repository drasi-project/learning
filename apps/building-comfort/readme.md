# Building Comfort Demo Setup

This README describes how to deploy the Building Comfort Demo for an Azure-hosted experience.

Before proceeding with this doc, it is recommended that you first be familiar with the overview of the Building Comfort Demo, its architecture, and how to self-host it in your cluster as described at:

> https://drasi-docs.azurewebsites.net/administrator/sample-app-deployment/building-comfort/

## Demo Contents

This folder contains the following sub-folders:

- [app](./app/) - contains the ReactJS application that is used to visualize and interact with the Building Comfort Demo.
- [devops](./devops/) - contains the files used to deploy and configure the Building Comfort Demo.
  - [azure-resources](./devops/azure-resources/) - contains the Bicep and configuration files used to deploy the Azure resources required by the Building Comfort Demo.
  - [data](./devops/data/) - contains the Python script used to populate the database used by the Building Comfort Demo with initial demo data.
  - [drasi](./devops/drasi/) - contains the Drasi YAML files used to apply the Drasi components for the Building Comfort Demo.
- [functions](./functions/) - contains Azure Functions used by the app and simulator to read and write to the source Cosmos database.

## Deploy Building Comfort Demo

### 1. Deploy the Azure resources

Under the `devops/azure-resources` subfolder is the `building-comfort.bicep` file which will help deploy the following required Azure resources:

- Cosmos Gremlin Graph Database for storing building data.
- Storage Account for serving the ReactJS app as a static website.
- Event Grid Topic for illustrating the use of the `reaction-eventgrid` component.
- Functions for hosting the CRUD API used by the ReactJS app.

The `parameters.json` file can be used to customize the deployment of the Azure resources as follows:

|Parameter|Description|Default Value|
|-|-|-|
|`deploymentName`|The name for the deployment. Also used as the Service Principal name, and prefix for the resulting Hosting Plan and Azure Functions app.|`rg-building-comfort-demo`|
|`cosmosAccountName`|The name for the CosmosDB account to create.|`drasi-demo`|
|`storageAccountName`|The name for the Storage Account used to host the ReactJS app.|`rgbuildingcomfort`|
|`eventGridTopicName`|The name of the Event Grid Topic to create.|`rg-building-comfort-demo`|

You will also need to [create a new resource group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups) if you don't already have one. The name of the resource group you create will be used in the next step.

From the `devops/azure-resources` subfolder, use the Azure CLI to deploy `cosmosdb.bicep`:

```bash
az login  # If you are not already logged in
az deployment group create --resource-group <resource-group-name> --template-file building-comfort.bicep --parameters @parameters.json
```

Note that Azure deployments are intended to be idempotent, and rerunning the above command with the same parameters can be used to retry a deployment with partially failed resource deployments, or reset the resource properties of an existing deployment back to the bicep specification.

### 2. Populate the CosmosDB Gremlin Graph

Once the deployment is complete, there should be a CosmosDB Gremlin Graph database named `Contoso` with an empty `Facilities` graph, and this step is the same as in the self-hosting case.


To populate the graph with the demo data, you'll need to create a `config.py` file under the `devops/data` subfolder as described by the [README](./devops/data/readme.md) in that folder. You can also use the template from the self-hosting instructions and edit the `cosmosUri` and `cosmosPassword` values to match your created Cosmos DB account:

```python
cosmosUri = "wss://my-drasi-db.gremlin.cosmos.azure.com:443/"
cosmosUserName = "/dbs/Contoso/colls/Facilities"
cosmosPassword = "xxx...xxx"
buildingCount = 1
floorCount = 3
roomCount = 5
defaultRoomTemp = 70
defaultRoomHumidity = 40
defaultRoomCo2 = 10
```

You can find the values for the `cosmosUri` and `cosmosPassword` in the Azure portal under your Cosmos DB account or by using the Azure CLI:

```bash
# For the cosmosUri, you can use the gremlinEndpoint returned by:
COSMOS_DB_ID=$(az cosmosdb show -n my-drasi-db -g my-resource-group --query id -o tsv)
az resource show --id "$COSMOS_DB_ID" --query properties.gremlinEndpoint -o tsv

# For the cosmosPassword, you can use the primaryMasterKey returned by:
az cosmosdb keys list --name my-drasi-db --resource-group my-resource-group --type keys --query primaryMasterKey -o tsv
```

Once you have the `config.py` file, you can run the `load_graph.py` script in the same directory to populate the graph with sample data:

```bash
pip install gremlinpython  # If you don't already have the gremlinpython package installed
python load_graph.py
```

### 3. Deploy the Drasi components

This step is similar to the [self-hosting instructions](https://project-drasi-docs.azurewebsites.net/administrator/sample-app-deployment/building-comfort/), with the option to deploy an Event Grid Reaction to support the Power Automate alerting demo.

#### Deploy the sources

From the `devops/drasi` subfolder, edit the `source-facilities.yaml` file to specify your Cosmos DB instance:

- `SourceAccountEndpoint` with the primary connection string
- `SourceKey` with the primary key, same as the `cosmosPassword` in `config.py`
- `SourceConnectionString` with the Gremlin endpoint, same as the `cosmosUri` in `config.py`

You can also look up the `SourceAccountEndpoint` value in the Azure portal or by using the Azure CLI:

```bash
az cosmosdb keys list --name my-drasi-db -g my-resource-group --type connection-strings --query "connectionStrings[?contains(description, 'Primary Gremlin Connection String')].[connectionString]" -o tsv
```

Apply the updated yaml file with `kubectl` to your Kubernetes cluster running Drasi:

```bash
kubectl apply -f source-facilities.yaml
```

#### Deploy the queries

From the `devops/drasi` subfolder, use `kubectl` to deploy the continuous queries:

```bash
kubectl apply -f query-alert.yaml
kubectl apply -f query-comfort-calc.yaml
kubectl apply -f query-ui.yaml
```

#### Deploy the reactions

From the `devops/drasi` subfolder, apply the Reaction yaml files with `kubectl` to your AKS cluster running Drasi:

```bash
kubectl apply -f reaction-signalr.yaml
```

### 4. Deploy the demo backend and frontend apps

#### Deploy the Backend Functions App to provide the CRUD API for updating the graph data

Ensure you have the [Azure Functions core tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=v4%2Cmacos%2Ccsharp%2Cportal%2Cbash#install-the-azure-functions-core-tools) installed.

From the `building-comfort/functions` folder, build and deploy the functions app:

```bash
npm install
func azure functionapp publish <Deployment Name>-app --javascript
```

For example, if you used the default `rg-building-comfort-demo` for the `deploymentName` parameter, you would run:

```bash
func azure functionapp publish rg-building-comfort-demo-app --javascript
```


#### Configure and deploy the frontend React app

Edit the `config.json` file under `app/src` subfolder to point to the URLs for your services deployed into Azure.

```json
{
  "crudApiUrl": "https://<deploymentName>-app.azurewebsites.net", // Functions app URL
  "signalRUrl": "https://<SignalRURL>/hub",                // Public URL to SignalR reaction 
  ...
}
```

From the `building-comfort/app` subfolder, build the react app:

```bash
npm install
npm run build
```

Ensure that your user logged into the Azure CLI has the _Storage Blob Data Contributor_ role on the storage account you created with `storageAccountName`:

```bash
MY_ID=$(az ad signed-in-user show --query id -o tsv)
STORAGE_ID=$(az storage account show -n <storageAccountName> --query id -o tsv)

# Check if you have the role assigned to you already. If not, you will see an empty list.
az role assignment list --scope "$STORAGE_ID" --assignee "$MY_ID" --role "Storage Blob Data Contributor"

# Assign the role if needed
az role assignment create --scope "$STORAGE_ID" --assignee "$MY_ID" --role "Storage Blob Data Contributor"
```

Ensure you have [AzCopy](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10) installed.

> ⚠️ For darwin/arm64: AzCopy does not have a darwin/arm64 release at the moment but can be installed via `go install`.
> Assuming `$GOPATH/bin` is already pathed:
>
> ```bash
> go install github.com/Azure/azure-storage-azcopy/v10@v10.17.0
> mv "$(which azure-storage-azcopy)" "$(dirname $(which azure-storage-azcopy))/azcopy"
>
> # Check if azcopy is installed
> azcopy --version
> ```

Login with AzCopy and deploy the app as a static website to your Azure storage account.

```bash
azcopy login
azcopy sync './build' 'https://<storageAccountName>.blob.core.windows.net/$web'
```


## Running the Building Comfort Demo

In addition to using the [Building Comfort frontend UI](https://project-drasi-docs.azurewebsites.net/administrator/sample-app-deployment/building-comfort/#using-the-frontend-app) to interact with the demo, there are a couple of additional options to drive changes with the demo.

### Adding data to the database manually

For visual demonstrations, you can use the Gremlin UI to the Cosmos DB graph instance to modify the data directly:

1. Navigate to the Azure Cosmos DB account in the [Azure portal](https://portal.azure.com).
2. Click _Data Explorer_ from the navigation menu. This should bring up the Apache Gremlin API view.
3. Under the Apache Gremlin API menu, click on `DATA` -> `Contoso` -> `Facilities` -> `Graph` to bring up the Graph tab.
4. From here, you can enter a Gremlin query directly into the query box and click `Execute Gremlin Query` to run it, or you can click on the `Load Graph` button to view the existing graph data.
5. From the _Results_ pane after loading the graph, you can click on any of the results to view the properties for that node. You can also click on the ✏️ icon to edit the properties for that node.

Note that while you can edit the `comfortLevel` value directly, this is a calculated value generated by the Gremlin Reaction, so for demo purposes it's best to edit one of the 3 sensor values that affect it instead: `temperature`, `humidity`, or `co2`.
