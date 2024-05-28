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
|vehiclesQueryId|ID of the `Vehicles in Parking Lot` continuous query|
|zoneQueryId|ID of the `Vehicles in Curbside Pickup Queue` continuous query|
|dispatchQueryId|ID of the `Orders Ready For Pickup` continuous query|
|ordersQueryId|ID of the `Orders Being Prepared` continuous query|
|matchQueryId|ID of the `Orders Matched to Vehicles` continuous query|

```json
{
  "crudApiUrl": "http://xxxxx.azurewebsites.net",
  "signalRUrl": "http://yyyyy.azurewebsites.net/hub",
  "vehiclesQueryId": "62fc089add5a186540a1545e",
  "zoneQueryId": "62fc089add5a184f57a1545f",
  "dispatchQueryId": "62fc089add5a186b39a15461",
  "ordersQueryId": "62fc089add5a187428a15460",
  "matchQueryId": "62fc089add5a18168ba15462"
}
```
