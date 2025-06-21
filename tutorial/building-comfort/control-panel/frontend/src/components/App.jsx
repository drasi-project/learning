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
import { fetchBuildings } from '../api';
import Building from './Building';
import { Box } from '@mui/material';

const App = () => {
  const [buildings, setBuildings] = useState([]);

  useEffect(() => {
    fetchBuildings()
      .then((response) => {
        const sortedBuildings = response.data.sort((a, b) => a.name.localeCompare(b.name));
        setBuildings(sortedBuildings);
      })
      .catch((error) => console.error("Error fetching buildings:", error));
  }, []);

  return (
    <Box
      sx={{
        maxWidth: '90%',
        margin: '0 auto',
        padding: 4,
        backgroundColor: '#23272a',
        borderRadius: 4,
        boxShadow: '0px 4px 10px rgba(0, 0, 0, 0.5)',
      }}
    >
      {buildings.map((building) => (
        <Building key={building.id} building={building} />
      ))}
    </Box>
  );
};

export default App;
