/**
 * Copyright 2025 The Drasi Authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import './App.css';
import React from 'react';
import { Subject } from 'rxjs';
import { Box, Container, Stack, LinearProgress, Grid, Alert } from '@mui/material';
import { ResultSet, ReactionListener } from '@drasi/signalr-react';
import config from "./config.json";

// Dynamic SignalR URL detection for Codespaces/local development
const getSignalRUrl = () => {
  const hostname = window.location.hostname;
  if (hostname.includes('.github.dev') || hostname.includes('.app.github.dev')) {
    // In GitHub Codespaces
    const parts = hostname.split('-');
    const portIndex = parts.length - 1;
    const baseUrl = parts.slice(0, portIndex).join('-');
    return `https://${baseUrl}-8080.app.github.dev/hub`;
  } else {
    // Local development
    return config.signalRUrl || 'http://localhost:8080/hub';
  }
};

const signalRUrl = getSignalRUrl();

const buildings = new Map();

const floorStats = new Map();
const bldStats = new Map();

const reloadSubject = new Subject();

const roomSubject = new Subject();
const floorSubject = new Subject();
const bldSubject = new Subject();

var uiListener;
var floorListener;
var bldListener;

initBldQuery();
initFloorQuery();
initUIQuery();

// This function listens to the 'building-comfort-ui' query, which lives in the query-ui.yaml file
function initUIQuery() {
  uiListener = new ReactionListener(signalRUrl, config.uiQueryId, change => {
    if (change.op === 'x') {
      return;
    }
    
    if (change.op !== 'd') {  // if op 'u' or 'i'
      roomSubject.next(change.payload.after);
      upsertRoomData(change.payload.after);
    }

  });
  uiListener.reload(data => {
    data.sort((a, b) => {
      var ret;
      if (a.RoomId < b.RoomId) {
        ret = -1;
      } else if (a.RoomId > b.RoomId) {
        ret = 1;
      } else {
        ret = 0;
      }

      return ret;
    });

    buildings.clear();
    for (let item of data) {
      upsertRoomData(item);
    }
    reloadSubject.next();
  });  
}

// This function listens to the 'floor-comfort-level-calc' query
function initFloorQuery() {
  floorListener = new ReactionListener(signalRUrl, config.avgRoomQueryId, change => {
    if (change.op === 'x') {
      return;
    }
    floorStats.set(change.payload.after.FloorId, change.payload.after);
    floorSubject.next(change.payload.after);
  });
  floorListener.reload(data => {
    floorStats.clear();
    for (let item of data) {
      floorStats.set(item.FloorId, item);
    }
    reloadSubject.next();
  });  
}

// This function listens to the 'building-comfort-level-calc' query
function initBldQuery() {
  bldListener = new ReactionListener(signalRUrl, config.avgFloorQueryId, change => {
    if (change.op === 'x') {
      return;
    }
    
    bldStats.set(change.payload.after.BuildingId, change.payload.after);
    bldSubject.next(change.payload.after);
  });
  bldListener.reload(data => {
    bldStats.clear();
    for (let item of data) {
      bldStats.set(item.BuildingId, item);
    }
    reloadSubject.next();
  });  
}

function upsertRoomData(data) {
  if (!buildings.has(data.BuildingId)) {
    buildings.set(data.BuildingId, {
      id: data.BuildingId,
      name: data.BuildingName,
      floors: new Map()
    });
  }

  let bld = buildings.get(data.BuildingId);
  if (!bld.floors.has(data.FloorId)) {
    bld.floors.set(data.FloorId, {
      id: data.FloorId,
      name: data.FloorName,
      rooms: new Map()
    });
  }

  let floor = bld.floors.get(data.FloorId);
  floor.rooms.set(data.RoomId, data);
}

function App() {
  const [data, setData] = React.useState(Array.from(buildings.values()));

  reloadSubject.subscribe(v => {
    setData(Array.from(buildings.values()));
  });

  return (
    <Container maxWidth='100%'>
      {data.map((building) => <Building key={building.id} building={building}></Building>)}
    </Container>
  );
}

function Building(props) {
  const [bldComfort, setBldComfort] = React.useState(bldStats.has(props.building.id) ? bldStats.get(props.building.id) : {});

  React.useEffect(() => {    
    let subscription = bldSubject.subscribe(v => {
      if (v.BuildingId === props.building.id)
        setBldComfort(v);
    });
    
    return function cleanup() {
      subscription.unsubscribe();
    };
  });

  // Init setup
  let level = bldComfort.ComfortLevel ?? 0;
  return (
    <Grid key={props.building.id} container spacing={2} bgcolor="pink">      
      <Grid item xs={2}>
          <h2>{props.building.name}</h2>
          <LinearProgress  variant="determinate" value={level} color={chooseColor(level)} ></LinearProgress>
          {level}
          <h3>Comfort Alerts</h3>
          {/* If the comfort level of a room is outside of the desired range, a warning will be created here */}
          <ResultSet
            url={signalRUrl}
            queryId={config.roomAlertQueryId}
            itemKey={item => item.RoomId}>
              <RoomComfortAlert/>
          </ResultSet>
          {/* If the comfort level of a floor is outside of the desired range, a warning will be created here */}
          <ResultSet 
            url={signalRUrl}
            queryId={config.floorAlertQueryId}
            itemKey={item => item.FloorId}>
              <FloorComfortAlert/>
          </ResultSet>
      </Grid>
      <Grid item xs={10}>
        <Stack spacing={2}>
          {/* inits the floors */}
          {Array.from(props.building.floors.values()).map(floor => 
            <Floor key={floor.id} floor={floor}></Floor>
          )}
        </Stack>
      </Grid>
      
    </Grid>
  );
}

function Floor(props) {

  const [floorComfort, setFloorComfort] = React.useState(floorStats.has(props.floor.id) ? floorStats.get(props.floor.id) : {});
  React.useEffect(() => {    
    let subscription = floorSubject.subscribe(v => {
      if (v.FloorId === props.floor.id)
        setFloorComfort(v);
    });
    
    return function cleanup() {
      subscription.unsubscribe();
    };
  });  

  let level = floorComfort.ComfortLevel;
  return (
    <Box key={props.floor.id}>
      <Stack bgcolor="cyan" direction="row" spacing={2}>
        <Box>
          <h3>{props.floor.name}</h3>
          <LinearProgress  variant="determinate" value={level} color={chooseColor(level)} ></LinearProgress>
          {level}
        </Box>
        {/* Setup the rooms in the floor */}
        {Array.from(props.floor.rooms.values()).map(initRoom => (
          <Room key={initRoom.RoomId} initRoom={initRoom}></Room>
        ))}
      </Stack>
    </Box>
    )
}

function Room(props) {
  const [room, setRoom] = React.useState(props.initRoom);
  const [tempColor, setTempColor] = React.useState("black");
  const [humidityColor, setHumidityColor] = React.useState("black");
  const [co2Color, setCO2Color] = React.useState("black");

  React.useEffect(() => {    
    let subscription = roomSubject.subscribe(v => {
      if (v.RoomId === props.initRoom.RoomId) {
        // Animation to show the change in values
        let prev = buildings.get(props.initRoom.BuildingId)
          .floors.get(props.initRoom.FloorId)
          .rooms.get(props.initRoom.RoomId);
  
        if (v.Temperature !== prev.Temperature) {
          setTempColor("white");
          setTimeout(setTempColor, 200, "black");
        }
        if (v.Humidity !== prev.Humidity) {
          setHumidityColor("white");
          setTimeout(setHumidityColor, 200, "black");
        }
        if (v.CO2 !== prev.CO2) {
          setCO2Color("white");
          setTimeout(setCO2Color, 200, "black");
        }
        
        setRoom(v);
      }
    });
    
    return function cleanup() {
      subscription.unsubscribe();
    };
  });


  return (
  <Box key={room.RoomId} bgcolor="lightgray">
    <h4>
      {room.RoomName}      
    </h4>
    <LinearProgress  variant="determinate" value={room.ComfortLevel} color={chooseColor(room.ComfortLevel)} ></LinearProgress >
    <Grid container>                        
      <Grid item xs={6} color={tempColor}>
        Temp: {room.Temperature}
      </Grid>
      <Grid item xs={6} color={humidityColor}>
        Humidity: {room.Humidity}
      </Grid>
      <Grid item xs={6} color={co2Color}>
        CO2: {room.CO2}
      </Grid>
    </Grid>
  </Box>
  )
}

// This function creates a warning that displays the room name and the comfort level of the room
function RoomComfortAlert(props) {
  return (
    <Alert severity="warning">{props.RoomName} = {props.ComfortLevel}</Alert>
  );
}

// This function creates a warning that displays the floor name and the comfort level of the floor
function FloorComfortAlert(props) {
  return (
    <Alert severity="warning">{props.FloorName} = {props.ComfortLevel}</Alert>
  );
}

function chooseColor(v) {
  if (v < 40 || v > 50)
    return "error";
  return "primary";
}

export default App;
