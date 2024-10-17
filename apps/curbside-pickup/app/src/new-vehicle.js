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

export function NewVehicle() {
  const [plate, setPlate] = React.useState("");
  const [make, setMake] = React.useState("");
  const [model, setModel] = React.useState("");
  const [color, setColor] = React.useState("");

  return (
    <Stack>
      <TextField label="Plate" variant="outlined" value={plate} onChange={e => setPlate(e.target.value)} />
      <TextField label="Make" variant="outlined" value={make} onChange={e => setMake(e.target.value)} />
      <TextField label="Model" variant="outlined" value={model} onChange={e => setModel(e.target.value)} />
      <TextField label="Color" variant="outlined" value={color} onChange={e => setColor(e.target.value)} />
        <Button variant="contained" onClick={e => {
          axios
            .post(`${config.crudApiUrl}/vehicle`, {
              plate: plate,
              make: make,
              model: model,
              color: color,
              location: 'Parking Lot'
            })
            .catch(err => addLog(`POST Vehicle - ${err}`))
            .then(resp => {
              addLog(`POST Vehicle - ${resp.statusText}`);
              setPlate("");
              setMake("");
              setModel("");
              setColor("");
            });
        }}>Add Vehicle</Button>
    </Stack>
  );
}


