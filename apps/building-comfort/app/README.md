# Overview

## Setup

Create Source
Create Continuous Queries
Create Query Node
Create SignalR subscriptions for each query

## Front-end app Configuration

The `/src/config.json` file holds settings for external APIs and Continuous Query IDs.

|Property|Description|
|----|-------------------|
|crudApiUrl|Url the points to where the `functions` project is hosted|
|signalRUrl|Url that points to our SignalR hub service (ReactiveGraphSignalRHub project).|
|uiQueryId|ID of the `Building Comfort UI` continuous query|
|avgFloorQueryId|ID of the `Building Comfort Level Inputs` continuous query|
|avgRoomQueryId|ID of the `Floor Comfort Level Inputs` continuous query|
|buildingAlertQueryId|ID of the `Building Comfort Level Alert` continuous query|
|floorAlertQueryId|ID of the `Floor Comfort Level Alert` continuous query|
|roomAlertQueryId|ID of the `Room Comfort Level Alert` continuous query|

```json
{
  "crudApiUrl": "http://xxxxx.azurewebsites.net",
  "signalRUrl": "http://yyyyy.azurewebsites.net/hub",
  "uiQueryId": "62fd513f9424ec26ca2ae049",
  "avgFloorQueryId": "62fd513f9424ecf6a72ae045",
  "avgRoomQueryId": "62fd513f9424ecf4692ae044",
  "buildingAlertQueryId": "62fd513f9424ecde0f2ae048",
  "floorAlertQueryId": "62fd513f9424ecc8602ae047",
  "roomAlertQueryId": "62fd513f9424ec06b82ae046"
}
```
