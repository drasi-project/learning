# Building Comfort Demo Setup

This README describes how to deploy the Building Comfort Demo for an Azure-hosted experience.

Before proceeding with this doc, it is recommended that you first be familiar with the overview of the Building Comfort Demo, its architecture, and how to self-host it in your cluster as described at:

> https://project-drasi-docs.azurewebsites.net/administrator/sample-app-deployment/building-comfort/

Hosting the Building Comfort Demo in Azure is similar to self-hosting it in your cluster with a couple of key differences:

1. The applications are hosted in Azure and not run locally on your machine.
2. Other additional Azure services need to be deployed to support that, such as Azure Functions and Azure Storage.
3. Optional demo components such as Teams alerts through Power Automate and using an IOT simulator are also described here.

## Demo Contents

This folder contains the following sub-folders:

- [app](./app/) - contains the ReactJS application that is used to visualize and interact with the Building Comfort Demo.
- [devops](./devops/) - contains the files used to deploy and configure the Building Comfort Demo.
  - [azure-resources](./devops/azure-resources/) - contains the Bicep and configuration files used to deploy the Azure resources required by the Building Comfort Demo.
  - [data](./devops/data/) - contains the Python script used to populate the database used by the Building Comfort Demo with initial demo data.
  - [power-automate](./devops/power-automate/) - contains the optional Power Automate flow used to illustrate sending alerts to Microsoft Teams.
  - [reactive-graph](./devops/reactive-graph/) - contains the Kubectl YAML files used to apply the Drasi components for the Building Comfort Demo.
- [functions](./functions/) - contains Azure Functions used by the app and simulator to read and write to the source Cosmos database.
- [iot-simulator](./iot-simulator/) - contains the code of a command line tool that can be used to simulate high volumes of sensor data automatically being updated in the Building Comfort Demo on a regular interval.

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
|`cosmosAccountName`|The name for the CosmosDB account to create.|`reactive-graph-demo`|
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

> ⚠️ Until Full Fidelity Change Feed (FFCF) is a public feature for Cosmos DB, you will also need to submit a request to enable that
> feature for your Cosmos DB account through the [Private Preview form](https://forms.office.com/pages/responsepage.aspx?id=v4j5cvGGr0GRqy180BHbR9ecQmQM5J5LlXYOPoIbyzdUOFVRNUlLUlpRV0dXMjFRNVFXMDNRRjVDNy4u).

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

From the `devops/reactive-graph` subfolder, edit the `source-facilities.yaml` file to specify your Cosmos DB instance:

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

From the `devops/reactive-graph` subfolder, use `kubectl` to deploy the continuous queries:

```bash
kubectl apply -f query-alert.yaml
kubectl apply -f query-comfort-calc.yaml
kubectl apply -f query-ui.yaml
```

#### Deploy the reactions

From the `devops/reactive-graph` subfolder, edit the `reaction-gremlin.yaml` file to specify your Gremlin graph in the Cosmos DB instance:

- `DatabaseHost` with the host DNS name for the Gremlin endpoint. This is the same as the `cosmosUri` in `config.py` without the `wss://` prefix or the port number.
- `DatabasePrimaryKey` with the primary key, same as the `cosmosPassword` in `config.py`.

Similarly, edit the `reaction-eventgrid.yaml` file to specify your Event Grid topic:

- `EventGridUri` with the Event Grid topic endpoint.
- `EventGridKey` with the Event Grid topic key.

```bash
# To get the topic endpoint for EventGridUri
az eventgrid topic show --resource-group <resource-group-name> --name <eventGridTopicName> --query endpoint -o tsv

# To get the primary key for EventGridKey
az eventgrid topic key list --resource-group <resource-group-name> --name <eventGridTopicName> --query key1 -o tsv
```

Apply the Reaction yaml files with `kubectl` to your AKS cluster running Drasi:

```bash
kubectl apply -f reaction-gremlin.yaml
kubectl apply -f reaction-eventgrid.yaml
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

#### Configure ingress for the frontend app to signalR reaction

The frontend app is served as a static web site that is executed in the client browser, which needs to be able to connect to the signalR Reaction hub. To enable this, you can configure an ingress for the signalR reaction so that it has a Public IP address that can be accessed from the browser.

A basic ingress setup using NGINX can be deployed using Helm as follows:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm install ingress-nginx ingress-nginx/ingress-nginx \
--create-namespace \
--namespace ingress-basic \
--set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
```

In AKS this will automatically create a Public IP Resource and the appropriate Network Security Group (NSG) rules to allow access to it.

You can then deploy an Ingress resource to route the traffic to the signalR Reaction. From the `building-comfort/devops` folder:

```bash
kubectl apply -f ingress-signalr.yaml
```

You can then get the public IP address as returned by the `ADDRESS` of the ingress from running:

```bash
kubectl get ingress building-comfort-signalr-ingress
```

> ⚠️ If you are not connected to CorpNet, you will still need to be connected to [Azure VPN for Developers](https://eng.ms/docs/microsoft-security/security/azure-security/security-health-analytics/network-isolation/tsgs/howtos/work-from-home-guidance/work-from-home-guidance#managed-vpn-azvpndev-access-status-jan-2023) (AzVPNDev) to access the Public IP address.
> You can [request access](https://eng.ms/docs/microsoft-security/security/azure-security/security-health-analytics/network-isolation/tsgs/howtos/work-from-home-guidance/work-from-home-guidance#managed-vpn-azvpndev-access-status-jan-2023) to the pilot, with the AzVPNDev configuration automatically made available to your Windows machine via InTune. This is not currently available for MacOS.
>
> This additional step is required because of Management Group Level Network Security Rules (a.k.a. [Simply Secure V2](https://eng.ms/docs/microsoft-security/security/azure-security/security-health-analytics/network-isolation/tsgs/azurenetworkmanager/programoverview)) imposed on all Non-prod environments, which includes the Azure Incubations Dev subscription. These rules supersede the NSG rules for the AKS cluster and do not allow access to the Public IP address.

#### Configure and deploy the frontend React app

Edit the `config.json` file under `app/src` subfolder to point to the URLs for your services deployed into Azure.

```json
{
  "crudApiUrl": "https://<deploymentName>-app.azurewebsites.net", // Functions app URL
  "signalRUrl": "https://<ingress public IP>/hub",                // Public URL to SignalR reaction 
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

### 5. [Optional] Create a Power Automate flow to send alerts to the Reactive Graph Teams channel

1. Navigate to the [Power Automate site](https://make.preview.powerautomate.com/) and select `My Flows` -> `Import` -> `Import Package (Legacy)`.
2. Click the `Import` button and select the `RoomAlert-PowerAutomateFlow.zip` file in the `devops/power-automate` subfolder.
3. In the Import package wizard after the upload is complete, configure:
   1. _Azure Queues Connection_ to point to one of the Event Subscription StorageQueues of the Event Grid topic.
   2. _Microsoft Teams Connection_ to point to the Teams connection where you want to receive the alerts.

> ⚠️ The RoomAlert-PowerAutomateFlow.zip defaults to updating an existing deployed workflow, so you may need to delete the existing workflow before importing the zip file.

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

### Running the IOT Simulator

The application can also be driven as a simulation of IoT devices sending data to the backend to demonstrate the volume of data and the real-time processing of the data by the Reactive Graph.

Under the `iot-simulator` subfolder, edit the `config.json` file to point the `functionUrl` to your Functions app URL:

```json
{
  "interval": 500,
  "functionUrl": "https://<deploymentName>-app.azurewebsites.net"
}
```

You can then run the simulator with:

```bash
npm install
node iot-sim.js
```
