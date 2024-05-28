# Deploy Sources, then wait for them to be ready
drasi apply -f ./source-questions.yaml ./source-games.yaml
drasi wait -f ./source-questions.yaml ./source-games.yaml -t 180

# Deploy Continuous Queries, then wait for them to be ready
drasi apply -f ./queries.yaml
drasi wait -f ./queries.yaml -t 180

# Deploy Reactions, then wait for them to be ready
drasi apply -f ./reaction-signalr.yaml ./reaction-gremlin.yaml
drasi wait -f ./reaction-signalr.yaml ./reaction-gremlin.yaml -t 180