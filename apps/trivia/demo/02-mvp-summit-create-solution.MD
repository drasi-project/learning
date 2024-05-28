# MVP Global Summit Live Drasi Demonstration - Create Solution

## Architecture

Show [Drasi Trivia Architecture](../images/DrasiTriviaArchitecture.png)

Discuss:
- Non Drasi
  - UI
  - [Drasi Trivia API](../images/DrasiTriviaApi.png)
  - 2 Databases
    - PostreSQL 
    - Cosmos Gremlin
- Drasi
  - 2 Sources
    - PostgreSQL
    - Cosmos Gremlin
  - 4 Continuous Queries
    - player-scores
    - team-scores
    - inactive-players
    - players-to-evict
  - 3 Reactions
    - SignalR
    - CosmosGremlin
    - Debug


## CLI

Run Drasi CLI and show options:

```
drasi
```

Mention:
1. init
1. apply
1. list
1. delete 


## Deploy All Resources

Show [deploy-all-resources.sh](../devops/deploy-all-resources.sh)


## Sources

Show PostgreSQL Source : [source-questions](../devops/source-questions.yaml)

Deploy PostgreSQL Source:

```
drasi apply -f ./devops/source-questions.yaml
```


Show Cosmso Source : [source-games](../devops/source-games.yaml)

Deploy Cosmos Source:

```
drasi apply -f ./devops/source-games.yaml
```


Show Source status using CLI:

```
drasi list Source
```

## Continuous Queries

Show [Continuous Query Yaml](../devops/queries.yaml)

Deploy Continuous Queries:

```
drasi apply -f ./devops/queries.yaml
```

Show Continuous Queries status using CLI

```
drasi list ContinuousQuery
```

Show [Test Query Yaml](../devops/test-query.yaml)

Test ```questions-per-category``` in VS Code.




## Reactions

Show [Debug Reaction](../devops/debug.yaml)

Deploy Debug Reaction:

```
drasi apply -f ./devops/debug.yaml
```

Setup port forwarding:

```
kubectl port-forward -n drasi-system services/test-debug-gateway 8080:8080

```
Connect to [Degug Reaction UI](http://localhost:8080/)

Open Portal - Cosmos - Date Explorer

Add Player, MEMBER_OF, Answer, ANSWER_FROM
```
g.V('3e63a4f4-a1b4-4285-8728-e1e86e6a02ee').as('team')
.addV('Player').property('id', 'allen').property('name', 'Allen').property('partition', 0).as('allen')
.addE('MEMBER_OF').from('allen').to('team')
.addV('Answer').property('id', 'allen_ans_1').property('questionId', 101).property('skipped', true).property('duration', 15.35).property('time', 1710360136256).property('partition', 0).as('answer')
.addE('ANSWER_FROM').from('answer').to('allen')
```

Add Answer, ANSWER_FROM
```
g.V('allen').as('allen')
.addV('Answer').property('id','allen_ans_2').property('questionId', 101).property('skipped', true).property('duration', 15.35).property('time', 1710360136256).property('partition', 0).as('answer')
.addE('ANSWER_FROM').from('answer').to('allen')
```

Show [Gremlin Reaction](../devops/reaction-gremlin.yaml)


Publish Gremlin Reaction

```
drasi apply -f ./devops/reaction-gremlin.yaml 
```


Show [SignalR Reaction](../devops/reaction-signalr.yaml)


Publish SignalR Reaction

```
drasi apply -f ./devops/reaction-signalr.yaml 
```



Show Reaction status using CLI

```
drasi list Reaction
```


Setup port forwarding:

```
kubectl port-forward -n drasi-system services/signalr-trivia-gateway 8086:8080

```

## Other Services

### Run API Functions

```
cd functions
npm start
```


### Run Web App

```
cd app
npm start
```

### Open Browser

Browse to [Local Drasi Triva Game](http://localhost:3000/)

Demonstrate answering a question