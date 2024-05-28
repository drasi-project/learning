
# Kubernetes (as a source) demo

## Setup

Connect to the cluster and set the `k8s-demo` as the current namespace

```bash
az account set --subscription 2865c7d1-29fa-485a-8862-717377bdbf1b

az aks get-credentials --resource-group reactive-graph-demo --name reactive-graph-demo

kubectl config set-context --current --namespace=k8s-demo
```

## Realtime pod deletion / creation demo

The following Cypher query is used to monitor containers with the name 'redis'.

```cypher
MATCH 
  (p:Pod)-[:HOSTS]->(c:Container) 
WHERE c.name = 'redis'
RETURN 
  p.name as Pod,
  p.phase as PodPhase,
  p.message as PodMessage,
  c.name as Container,
  c.image as Image,
  c.started as Started,
  c.ready as Ready,
  c.restartCount as RestartCount,
  c.state as State,
  c.reason as Reason,
  c.message as Message
```

Navigate to debug UI for the query: https://rg-demo-debug1.happycoast-8bd2f07c.westus.azurecontainerapps.io/query/demo-query1

While watching the debug UI, run the following command, which will show the termination of the redis pod and it's recreation in realtime.

```bash
kubectl delete pods/redis-0
```

## Governance demo (joining onto PostgreSQL)

This demo show cases joining a virtual graph of your Kubernetes cluster to a relational database table, with the following continuous query

```yaml
sources:    
  subscriptions:
    - id: k8s
      nodes:
        - sourceLabel: Container
        - sourceLabel: Pod
      relations:
        - sourceLabel: HOSTS
    - id: demo-devops
      nodes:
        - sourceLabel: RiskyImage
  joins:
    - id: INCLUDES
      keys:
        - label: RiskyImage
          property: Image
        - label: Container
          property: image
query: > 
  MATCH 
    (r:RiskyImage)-[:INCLUDES]->(c:Container)<-[:HOSTS]-(p:Pod)
  RETURN 
    p.name as Pod,
    c.name as Container,
    c.image as Image,
    c.started as Started,
    c.ready as Ready,
    c.state as State,
    c.reason as Reason,
    c.message as Message,
    r.Reason as Risk
```

Navigate to the debug UI of the query: https://rg-demo-debug1.happycoast-8bd2f07c.westus.azurecontainerapps.io/query/risky-containers

There are 2 pods running the `my-app` image, one is on version `0.1` and the other on `0.2`. There is also an entry in the `RiskyImage` table in Postgres the marks version `0.1` as having a security risk, and so it appears on our governance dashboard.

Use a tool such as [PgAdmin](https://www.pgadmin.org) to connect to `reactive-graph.postgres.database.azure.com`

Run the following SQL script to mark version `0.2` as having a critical bug:

```sql
insert into "RiskyImage" ("Id", "Image", "Reason") values (101, 'drasidemo.azurecr.io/my-app:0.2', 'Critical Bug')
```

Now, a both instances of the app should appear on the dashboard.

Now use kubectl to upgrade `my-app-2`to version `0.3`

```bash
kubectl set image pod/my-app-2 app=drasidemo.azurecr.io/my-app:0.3
```

Now `my-app-2` should disappear from the dashboard, since version `0.3` is not marked as a risk.

After the demo, reset the data

```sql
delete from "RiskyImage" where "Id" = 101
```

```bash
kubectl set image pod/my-app-2 app=drasidemo.azurecr.io/my-app:0.2
```