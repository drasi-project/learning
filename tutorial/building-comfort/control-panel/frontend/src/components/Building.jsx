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

import React, { useEffect, useState } from 'react';
import { fetchFloors } from '../api';
import Floor from './Floor';
import { Box, Stack } from '@mui/material';

const Building = ({ building }) => {
  const [floors, setFloors] = useState([]);

  useEffect(() => {
    fetchFloors(building.id)
      .then((response) => {
        const sortedFloors = response.data.sort((a, b) => a.name.localeCompare(b.name));
        setFloors(sortedFloors);
      })
      .catch((error) => console.error(`Error fetching floors for building ${building.id}:`, error));
  }, [building.id]);

  return (
    <Box
      p={2}
      mb={3}
      sx={{
        backgroundColor: '#40444b', // Mid-gray for building blocks
        borderRadius: 8,
        boxShadow: '0px 4px 8px rgba(0, 0, 0, 0.3)',
        color: '#f0f0f0',
      }}
    >
      <h2>🏢 {building.name}</h2>
      <Stack spacing={2}>
        {floors.map((floor) => (
          <Floor key={floor.id} floor={floor} buildingId={building.id} />
        ))}
      </Stack>
    </Box>
  );
};

export default Building;
