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

import React, { useEffect, useState } from 'react';
import { fetchRooms } from '../api';
import Room from './Room';
import { Box, Grid } from '@mui/material';

const Floor = ({ buildingId, floor }) => {
  const [rooms, setRooms] = useState([]);

  useEffect(() => {
    fetchRooms(buildingId, floor.id)
      .then((response) => {
        const sortedRooms = response.data.sort((a, b) => a.name.localeCompare(b.name));
        setRooms(sortedRooms);
      })
      .catch((error) => console.error(`Error fetching rooms for floor ${floor.id}:`, error));
  }, [buildingId, floor.id]);

  return (
    <Box
      p={2}
      mb={3}
      sx={{
        backgroundColor: '#3a3f44',
        borderRadius: 8,
        boxShadow: '0px 4px 8px rgba(0, 0, 0, 0.3)',
        color: '#f0f0f0',
      }}
    >
      <h3>📂 {floor.name}</h3>
      <Grid container spacing={2} justifyContent="flex-start">
        {rooms.map((room) => (
          <Grid item key={room.id}>
            <Room room={room} buildingId={buildingId} floorId={floor.id} />
          </Grid>
        ))}
      </Grid>
    </Box>
  );
};

export default Floor;
