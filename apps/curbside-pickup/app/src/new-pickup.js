/**
 * Copyright 2024 The Drasi Authors.
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