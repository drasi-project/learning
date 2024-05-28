

```json
{
    "event_id": "000e1234-e89b-52d4-a457-426614174012",
    "type": "telemetry",
    "timestamp": 0,
    "vehicle_id": "123e4567-e89b-12d3-a456-426614174000",
    "engine_hours": 1000,
    "odometer": 20000,
    "battery_level": 95,
    "signals": [
        {
            "name": "Vehicle.CurrentLocation.Latitude",
            "value": "-29.12249",
            "timestamp": "2024-04-05T16:07:16.0000000Z"
        },
        {
            "name": "Vehicle.CurrentLocation.Longitude",
            "value": "25.42657",
            "timestamp": "2024-04-05T16:07:16.0000000Z"
        },
        {
            "name": "Vehicle.CurrentLocation.Heading",
            "value": "96",
            "timestamp": "2024-04-05T16:07:16.0000000Z"
        },
        {
            "name": "Vehicle.Speed",
            "value": "119",
            "timestamp": "2024-04-05T16:07:16.0000000Z"
        },
        {
            "name": "Vehicle.TraveledDistance",
            "value": "4563",
            "timestamp": "2024-04-05T16:07:16.0000000Z"
        }
    ],
}
```

WHERE node.

```json
{
    "event_id": "000e1234-e89b-52d4-a457-426614174013",
    "type": "signal",
    "vehicle_id": "123e4567-e89b-12d3-a456-426614174000",
    "signal_name": "BRAKE_FLUID_LOW",
    "value": true
}
```


```json
{
    "label": ["Telemetry"],
    "id": "000e1234-e89b-52d4-a457-426614174012",
    "properties": {
        "engine_hours": 777,
        "battery": 0
    }
}
```

```yaml
nodes:
    - op: insert
      select: $[?(@.type == 'Telemetry')]
      label: Telemetry
      id: 
        context: Selected / Root / Static
        expression: $.event_id
      properties:
        - engine_hours: $.signals[name="Vehicle.TraveledDistance"].value
        - odometer: $.signals[name="Vehicle.TraveledDistance"].value
        - battery_level: 
            context: Selected
            expression: $.battery_level

    - op: insert
      match:
        - type: "telemetry"
        - (exists($.signals[name="engine_hours"]))
      label: EngineHoursTelemetry
      id: $.event_id
      properties:
        - value: $.signals[name="engine_hours"].value

    - op: update
      match:
        - type: "telemetry"      
      label: Vehicle
      id: $.vehicle_id
      properties:
        - engine_hours: $.engine_hours
        - odometer: $.odometer
        - battery_level: $.battery_level

    - op: update
      match:
        - type: "signal"      
        - signal_name: "BRAKE_FLUID_LOW"
      label: Vehicle
      id: $.vehicle_id
      properties:
        - brake_fluid_low: $.value

relations:
    - op: insert
      match:
        - type: "telemetry"      
      label: HAS
      id: {$.event_id}-{$.vehicle_id}
      startId: $.vehicle_id
      endId: $.event_id

    - op: delete
      match:
        - type: "telemetry"      
      label: HAS
      id: {$.event_id}-{$.vehicle_id}
      startId: $.vehicle_id
      endId: $.event_id



```