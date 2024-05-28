# API

## Buildings

### Get All Buildings

```
GET http://<service-url>/building
```

Returns an array of buildings:

```
[
  {
    "id": "building_01",
    "name": "Building 01",
    "comfortLevel": 50
  },
  {
    "id": "building_02",
    "name": "Building 02",
    "comfortLevel": 50
  }
]
```

Optionally query paramters include:

|Parameter|Description|
|-|-|
|includeFloors| Buildings include an array of floors that are PART_OF the building|
|includeRooms| If includeFloors is used, each floor will include an array of rooms that are PART_OF the floor|

### Get Specific Buildings

```
GET http://<service-url>/building/{building_id}
```

Returns the specified building:

```
{
    "id": "building_01",
    "name": "Building 01",
    "comfortLevel": 50
}
```

Optionally query paramters include:

|Parameter|Description|
|-|-|
|includeFloors| Building includes an array of floors that are PART_OF the building|
|includeRooms| If includeFloors is used, each floor will include an array of rooms that are PART_OF the floor|

## Floors
### Get All Floors

```
GET http://<service-url>/building/{building_id}/floor
```

Returns an array of floors in the specified building:

```
[
  {
    "id": "floor_01_01",
    "buildingId": "building_01",
    "name": "Floor 01",
    "comfortLevel": 50
  },
  {
    "id": "floor_01_02",
    "buildingId": "building_01",
    "name": "Floor 02",
    "comfortLevel": 50
  },
  {
    "id": "floor_01_03",
    "buildingId": "building_01",
    "name": "Floor 03",
    "comfortLevel": 50
  }
]
```

Optionally query paramters include:

|Parameter|Description|
|-|-|
|includeRooms| Floors include an array of rooms that are PART_OF the floor|

### Get Specific Floor

```
GET http://<service-url>/building/{building_id}/floor/{floor_id}
```

Returns the specified floor:

```
{
    "id": "floor_01_02",
    "buildingId": "building_01",
    "name": "Floor 02",
    "comfortLevel": 50
}
```

Optionally query paramters include:

|Parameter|Description|
|-|-|
|includeRooms| Floor includes an array of rooms that are PART_OF the floor|

## Rooms
### Get All Rooms

```
GET http://<service-url>/building/{building_id}/floor/{floor_id}/room
```

Returns an array of rooms in the specified building and floor:

```
[
  {
    "id": "room_01_02_01",
    "buildingId": "building_01",
    "floorId": "floor_01_02",
    "name": "Room 0201",
    "temp": "72",
    "humidity": "42",
    "co2": "500",
    "comfortLevel": 50
  },
  {
    "id": "room_01_02_02",
    "buildingId": "building_01",
    "floorId": "floor_01_02",
    "name": "Room 0202",
    "temp": "72",
    "humidity": "42",
    "co2": "500",
    "comfortLevel": 50
  },
  {
    "id": "room_01_02_03",
    "buildingId": "building_01",
    "floorId": "floor_01_02",
    "name": "Room 0203",
    "temp": "72",
    "humidity": "42",
    "co2": "500",
    "comfortLevel": 50
  }
]
```

### Get Specific Room

```
GET http://<service-url>/building/{building_id}/floor/{floor_id}/room/{room_id}
```

Returns the specified floor:

```
{
    "id": "room_01_02_03",
    "buildingId": "building_01",
    "floorId": "floor_01_02",
    "name": "Room 0203",
    "temp": "72",
    "humidity": "42",
    "co2": "500",
    "comfortLevel": 50
}
```

## Sensors

### Set a Room Sensor Value

```
POST http://<service-url>/building/{building_id}/floor/{floor_id}/room/{room_id}/sensor/{sensor_id}
```

The sensor_id can be one of these:
- temp
- humidity
- co2

POST BODY contains the sensor value:

```
{
    "value": 75
}
```

Returns the room that contains the updated sensor along with all current sensor values:

```
{
  "roomId": "room_01_03_03",
  "floorId": "floor_01_03",
  "buildingId": "building_01",
  "roomName": "Room 0303",
  "temp": 75,
  "humidity": 42,
  "co2": 500,
  "comfortLevel": 50
}
```