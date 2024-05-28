import React from 'react';
import { Button, Stack, TextField } from '@mui/material';
import axios from 'axios';
import config from "./config.json";
import { addLog } from './log-box';

export function NewPickup() {
  const [plate, setPlate] = React.useState("");
  const [driver, setDriver] = React.useState("");
  const [customer, setCustomer] = React.useState("");

  return (
    <Stack>
      <TextField label="Plate" variant="outlined" value={plate} onChange={e => setPlate(e.target.value)} />
      <TextField label="Driver" variant="outlined" value={driver} onChange={e => setDriver(e.target.value)} />
      <TextField label="Customer" variant="outlined" value={customer} onChange={e => setCustomer(e.target.value)} />      
        <Button variant="contained" onClick={e => {
          axios
            .post(`${config.crudApiUrl}/order`, {
              customerName: customer,
              status: "preparing",
              pickup : {
                plate: plate,
                name: driver
              }              
            })
            .catch(err => addLog(`POST Order - ${err}`))
            .then(resp => {
              addLog(`POST Order - ${resp.statusText}`);
              setPlate("");
              setDriver("");
              setCustomer("");
            });
        }}>Add Pickup</Button>
    </Stack>
  );
}