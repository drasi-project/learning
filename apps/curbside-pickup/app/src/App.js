import './App.css';
import React from 'react';
import axios from 'axios';
import { Subject } from 'rxjs';
import { Box, Button, Container, Paper, List, ListItem, ListItemText, Grid } from '@mui/material';
import { ReactionResult } from 'react-reactive-graph';
import { NewVehicle } from './new-vehicle';
import { NewPickup } from './new-pickup';
import { LogBox, addLog } from './log-box';
import { colorHash } from './colorHash';
import config from "./config.json";

const matchSubject = new Subject();
const matches = new Map();

function App() {
  return (
    <Container maxWidth='100%'>
      <Grid container spacing={2}>
        <Grid item xs={6}>
          <Box border={'solid'} height={"100%"}>
            <b>Physical Operations - Vehicles</b>
            <Grid container spacing={2} paddingLeft={1} paddingRight={1} paddingBottom={1}>
              <Grid item xs={6}>
                <Box bgcolor='pink'>
                  <h3>Parking Lot</h3>
                  <List>
                    <ReactionResult
                      url={config.signalRUrl}
                      queryId={config.vehiclesQueryId}
                      itemKey={item => item.plate}
                      onMessage={msg => addLog(`Reaction from vehicle query: ${JSON.stringify(msg)}`)}>
                      <VehicleTemplate />
                    </ReactionResult>
                  </List>
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Box bgcolor='pink'>
                  <h3>Curbside Pickup Zone</h3>
                  <List>
                    <ReactionResult
                      url={config.signalRUrl}
                      queryId={config.zoneQueryId}
                      itemKey={item => item.plate}
                      onMessage={msg => addLog(`Reaction from pickup query: ${JSON.stringify(msg)}`)} >
                      <PickupZoneTemplate />
                    </ReactionResult>
                  </List>
                </Box>
              </Grid>
            </Grid>
          </Box>
        </Grid>

        <Grid item xs={6}>
          <Box border={'solid'} height={"100%"}>
            <b>Retail Operations - Orders</b>
            <Grid container spacing={2} paddingLeft={1} paddingRight={1} paddingBottom={1}>
              <Grid item xs={6}>
                <Box bgcolor='cyan'>
                  <h3>Ready for pickup</h3>
                  <List>
                    <ReactionResult
                      url={config.signalRUrl}
                      queryId={config.dispatchQueryId}
                      itemKey={item => item.id}
                      onMessage={msg => addLog(`Reaction from dispatch query: ${JSON.stringify(msg)}`)}>
                      <DispatchTemplate />
                    </ReactionResult>
                  </List>
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Box bgcolor='cyan'>
                  <h3>In Preparation</h3>
                  <List>
                    <ReactionResult
                      url={config.signalRUrl}
                      queryId={config.ordersQueryId}
                      itemKey={item => item.id}
                      onMessage={msg => addLog(`Reaction from order query: ${JSON.stringify(msg)}`)}>
                      <OrderTemplate />
                    </ReactionResult>
                  </List>
                </Box>
              </Grid>
            </Grid>
          </Box>
        </Grid>


        <Grid item xs={3}>
          <Paper>
            <NewVehicle />
          </Paper>
        </Grid>
        <Grid item xs={6}>
          <Box bgcolor='lightgreen'>
            <h3>Matched (Multi-database join)</h3>
            <List>
              <ReactionResult
                url={config.signalRUrl}
                queryId={config.matchQueryId}
                itemKey={item => item.OrderNumber}
                onMessage={msg => {
                  addLog(`Match Change: ${JSON.stringify(msg)}`);
                  if (msg.op === 'd') {
                    if (msg.payload.before)
                      matches.delete(msg.payload.before.OrderNumber);
                    else
                      matches.delete(msg.payload.after.OrderNumber);
                  }
                  else {
                    matches.set(msg.payload.after.OrderNumber, msg.payload.after);
                  }
                  matchSubject.next();
                }}
                onReloadItem={item => {
                  matches.set(item.OrderNumber, item);
                  matchSubject.next();
                }}>
                <MatchedTemplate />
              </ReactionResult>
            </List>
          </Box>          
        </Grid>
        <Grid item xs={3}>
          <Paper>
            <NewPickup />
          </Paper>
        </Grid>
      </Grid>
      <hr/>
      <Paper>
        <LogBox></LogBox>
      </Paper>

    </Container>
  );
}

function VehicleTemplate(props) {
  return (
    <ListItem>
      <ListItemText primary={props.plate} secondary={props.make + props.model} />
      <Button variant="contained" onClick={e => {
        axios
          .put(`${config.crudApiUrl}/vehicle/${props.id}`, {
            location: 'Curbside Queue'
          })
          .catch(err => addLog(`PUT Vehicle - ${err}`))
          .then(resp => addLog(`PUT Vehicle - ${resp.statusText}`));
      }}>Queue</Button>
    </ListItem>
  );
}

function PickupZoneTemplate(props) {
  let initMatch = false;
  for (let m of matches.values()) {
    if (m.LicensePlate == props.plate) {
      initMatch = true;
    }
  }

  const [isMatched, setIsMatched] = React.useState(initMatch);

  React.useEffect(() => {
    let subscription = matchSubject.subscribe(v => {
      for (let m of matches.values()) {
        if (m.LicensePlate == props.plate) {
          setIsMatched(true);
          return;
        }
      }
      setIsMatched(false);
    });

    return function cleanup() {
      subscription.unsubscribe();
    };
  });

  let borderSx = {};
  if (isMatched)
    borderSx = { borderColor: colorHash(props.plate.toLowerCase()).hex, borderWidth: '3px', borderStyle: 'solid' };

  return (
    <ListItem sx={borderSx}>
      <ListItemText primary={props.plate} secondary={props.make + props.model} />
      <Button variant="contained" onClick={e => {
        axios
          .put(`${config.crudApiUrl}/vehicle/${props.id}`, {
            location: 'Parking Lot'
          })
          .catch(err => addLog(`PUT Vehicle - ${err}`))
          .then(resp => addLog(`PUT Vehicle - ${resp.statusText}`));
      }}>Unqueue</Button>
    </ListItem>
  );
}

function OrderTemplate(props) {
  return (
    <ListItem>
      <ListItemText primary={props.name} secondary={props.id} />
      <Button variant="contained" onClick={e => {
        axios
          .put(`${config.crudApiUrl}/order/${props.id}`, {
            status: 'ready'
          })
          .catch(err => addLog(`PUT Order - ${err}`))
          .then(resp => addLog(`PUT Order - ${resp.statusText}`));
      }}>Dispatch</Button>
    </ListItem>
  );
}

function DispatchTemplate(props) {
  let initMatch = "";
  if (matches.has(props.id))
    initMatch = matches.get(props.id).LicensePlate;

  const [matchedVehicle, setMatchedVehicle] = React.useState(initMatch);

  React.useEffect(() => {
    let subscription = matchSubject.subscribe(v => {
      let m = matches.get(props.id);
      if (m)
        setMatchedVehicle(m.LicensePlate);
      else
        setMatchedVehicle("");
    });

    return function cleanup() {
      subscription.unsubscribe();
    };
  });

  let borderSx = {};
  if (matchedVehicle)
    borderSx = { borderColor: colorHash(matchedVehicle.toLowerCase()).hex, borderWidth: '3px', borderStyle: 'solid' };

  return (
    <ListItem sx={borderSx}>
      <ListItemText primary={props.name} secondary={props.id} />
      <Button variant="contained" onClick={e => {
        axios
          .put(`${config.crudApiUrl}/order/${props.id}`, {
            status: 'preparing'
          })
          .catch(err => addLog(`PUT Order - ${err}`))
          .then(resp => addLog(`PUT Order - ${resp.statusText}`));
      }}>Recall</Button>
    </ListItem>
  );
}

function MatchedTemplate(props) {
  return (
    <ListItem sx={{ borderColor: colorHash(props.LicensePlate.toLowerCase()).hex, borderWidth: '3px', borderStyle: 'solid' }}>
      <ListItemText >
      {props.LicensePlate} : {props.OrderNumber}
      </ListItemText>
      <Button variant="contained" onClick={e => {
        axios
          .put(`${config.crudApiUrl}/order/${props.OrderNumber}`, {
            status: 'delivered'
          })
          .catch(err => addLog(`PUT Order - ${err}`))
          .then(resp => addLog(`PUT Order - ${resp.statusText}`));

        axios
          .delete(`${config.crudApiUrl}/vehicle/${props.LicensePlate}`)
          .catch(err => addLog(`DELETE Vehicle - ${err}`))
          .then(resp => addLog(`DELETE Vehicle - ${resp.statusText}`));
      }}>Deliver</Button>
    </ListItem>
  );
}


export default App;
