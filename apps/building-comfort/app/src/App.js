import './App.css';
import React from 'react';
import axios from 'axios';
import { Subject } from 'rxjs';
import { Box, Button, Container, Stack, LinearProgress, Grid, Alert } from '@mui/material';
import { ReactionResult, ReactionListener } from 'react-reactive-graph';
import config from "./config.json";

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

function initUIQuery() {
  uiListener = new ReactionListener(config.signalRUrl, config.uiQueryId, change => {
    if (change.op === 'x') {
      return;
    }
    
    if (change.op === 'd') {
      if (change.payload.before)
        removeRoomData(change.payload.before);

      else
        removeRoomData(change.payload.after);
    }
    else {
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

function initFloorQuery() {
  floorListener = new ReactionListener(config.signalRUrl, config.avgRoomQueryId, change => {
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

function initBldQuery() {
  bldListener = new ReactionListener(config.signalRUrl, config.avgFloorQueryId, change => {
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

function removeRoomData(data) {

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
      if (v.BuildingId == props.building.id)
        setBldComfort(v);
    });
    
    return function cleanup() {
      subscription.unsubscribe();
    };
  });
  
  let level = bldComfort.ComfortLevel ?? 0;
  return (
    <Grid key={props.building.id} container spacing={2} bgcolor="pink">      
      <Grid item xs={2}>
          <h2>{props.building.name}</h2>
          <LinearProgress  variant="determinate" value={level} color={chooseColor(level)} ></LinearProgress>
          {level}
          <h3>Comfort Alerts</h3>
          <ReactionResult 
            url={config.signalRUrl}
            queryId={config.roomAlertQueryId}
            itemKey={item => item.RoomId}>
              <RoomComfortAlert/>
          </ReactionResult>
          <ReactionResult 
            url={config.signalRUrl}
            queryId={config.floorAlertQueryId}
            itemKey={item => item.FloorId}>
              <FloorComfortAlert/>
          </ReactionResult>
      </Grid>
      <Grid item xs={10}>
        <Stack spacing={2}>
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
      if (v.RoomId == props.initRoom.RoomId) {
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
    <Button variant="outlined" onClick={e => updateRoom(room.BuildingId, room.FloorId, room.RoomId, 40, 20, 700)}>
        Break
    </Button>
    <Button variant="outlined" onClick={e => updateRoom(room.BuildingId, room.FloorId, room.RoomId, 70, 40, 10)}>
        Reset
    </Button>
  </Box>
  )
}

function RoomComfortAlert(props) {
  return (
    <Alert severity="warning">{props.RoomName} = {props.ComfortLevel}</Alert>
  );
}

function FloorComfortAlert(props) {
  return (
    <Alert severity="warning">{props.FloorName} = {props.ComfortLevel}</Alert>
  );
}

async function updateRoom(buildingId, floorId, roomId, temperature, humidity, co2) {
  await axios.post(`${config.crudApiUrl}/building/${buildingId}/floor/${floorId}/room/${roomId}/sensor/temp`, { value: temperature });
  await delay(200);
  await axios.post(`${config.crudApiUrl}/building/${buildingId}/floor/${floorId}/room/${roomId}/sensor/humidity`, { value: humidity });
  await delay(200);
  await axios.post(`${config.crudApiUrl}/building/${buildingId}/floor/${floorId}/room/${roomId}/sensor/co2`, { value: co2 });
}

function chooseColor(v) {
  if (v < 40 || v > 50)
    return "error";
  return "primary";
}

function delay(n){
  return new Promise(function(resolve){
      setTimeout(resolve,n);
  });
}

export default App;
