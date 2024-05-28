# Kubernetes Demo

## Create Kubernetes Source

Export the Kubernetes credentials to a file named `demo-credentials.yaml`

```bash
az aks get-credentials --resource-group reactive-graph-demo --name reactive-graph-demo --file demo-credentials.yaml
```

Create a secret named `k8s-context` from the `demo-credentials.yaml` file

```bash
kubectl create secret generic k8s-context --from-file=demo-credentials.yaml
```

Create the source that references the secret

```bash
drasi apply -f k8s-source.yaml
```

## Create PostgreSQL DB and source

### Prerequisites

- A PostgreSQL instance of at least version 10 or greater.
- Your PostgreSQL instance must be configured to support `LOGICAL` replication.
- A PostgreSQL user that has at least the LOGIN, REPLICATION and CREATE permissions on the database and SELECT permissions on the tables you are interested in.

#### Azure Database for PostgreSQL

If you are using Azure Database for PostgreSQL, you can configure the replication to `LOGICAL` from the Azure portal under the `Replication` tab, or you can use the CLI as follows:

```azurecli
az postgres server configuration set --resource-group mygroup --server-name myserver --name azure.replication_support --value logical

az postgres server restart --resource-group mygroup --name myserver
```

### Create RiskyImage table

Use a tool such as [pgAdmin](https://www.pgadmin.org/) to create a new database called `demo-devops`.

Use the following script to create a table named `RiskyImage`.

```sql
CREATE TABLE IF NOT EXISTS public."RiskyImage"
(
    "Id" integer NOT NULL,
    "Image" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "Reason" character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT "RiskyImage_pkey" PRIMARY KEY ("Id")
)
```

### Insert the base data

```sql
insert into "RiskyImage" ("Id", "Image", "Reason") values (1, 'drasidemo.azurecr.io/my-app:0.1', 'Security Risk')
insert into "RiskyImage" ("Id", "Image", "Reason") values (2, 'docker.io/library/redis:6.2.3-alpine', 'Compliance Issue')
```

### Deploy the source

Update the connection details/password in `devops-source.yaml` and apply it to your cluster.

```bash
drasi apply -f devops-source.yaml
```

## Deploy queries

```bash
drasi apply -f queries.yaml
```

## Deploy Debug reaction

```bash
drasi apply -f debug.yaml
```

## Create initial containers

```bash
kubectl apply -f my-app.yaml
```
