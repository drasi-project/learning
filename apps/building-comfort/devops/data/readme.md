# Configuration (config.py)

|Property|Description|
|-|-|
|cosmosUri|Cosmos Gremlin URI. Get from Azure portal.|
|cosmosUserName|Cosmos Gremlin database and collection name. Get from Azure portal.|
|cosmosPassword|Secret key to write to Cosmos Gremlin. Get from Azure portal.|
|buildingCount|Number of Buildings to create|
|floorCount|Number of Floors per Building|
|roomCount|Number of Rooms per Floor|
|defaultRoomTemp|Default Temperature sensor values for Room|
|defaultRoomHumidity|Default Humidity sensor values for Room|
|defaultRoomNoise|Default Noise sensor values for Room|
|defaultRoomLight|Default Light sensor values for Room|



Example of `config.py`:

```
cosmosUri = "wss://reactive-graph-demo.gremlin.cosmos.azure.com:443/"
cosmosUserName = "/dbs/Contoso/colls/Facilities"
cosmosPassword = "xxx...xxx"
buildingCount = 1
floorCount = 3
roomCount = 5
defaultRoomTemp = 70
defaultRoomHumidity = 40
defaultRoomCo2 = 10
```