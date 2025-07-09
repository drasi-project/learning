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

import React, { useState } from 'react';
import { updateRoomSensor, fetchRoom } from '../api';
import { Box, Stack, TextField, Button, Snackbar, Alert } from '@mui/material';

const Room = ({ room, buildingId, floorId }) => {
  const [temperature, setTemperature] = useState(room.temperature);
  const [humidity, setHumidity] = useState(room.humidity);
  const [co2, setCO2] = useState(room.co2);
  const [toast, setToast] = useState({ open: false, success: true, message: '' });

  const showToast = (success, message) => {
    setToast({ open: true, success, message });
    setTimeout(() => {
      setToast({ open: false, success: true, message: '' });
    }, 3000); // Toast disappears after 3 seconds
  };

  const updateRoom = async (updates) => {
    try {
      await Promise.all(
        Object.entries(updates).map(([sensor, value]) =>
          updateRoomSensor(buildingId, floorId, room.id, sensor, value)
        )
      );

      const response = await fetchRoom(buildingId, floorId, room.id);
      setTemperature(response.data.temperature);
      setHumidity(response.data.humidity);
      setCO2(response.data.co2);

      showToast(true, 'Update successful!');
    } catch (error) {
      console.error('Error updating room:', error);
      showToast(false, 'Update failed.');
    }
  };

  const handleApply = () => {
    const updates = { temperature, humidity, co2 };
    updateRoom(updates);
  };

  const handleReset = () => {
    const resetValues = { temperature: 70, humidity: 40, co2: 10 };
    updateRoom(resetValues);
  };

  const handleBreak = () => {
    const breakValues = { temperature: 40, humidity: 20, co2: 700 };
    updateRoom(breakValues);
  };

  return (
    <Box
      p={2}
      mb={2}
      sx={{
        backgroundColor: '#2c2f33', // Dark background
        borderRadius: 8,
        boxShadow: '0px 2px 4px rgba(0, 0, 0, 0.2)',
        color: '#ffffff',
        width: '250px', // Compact size
        textAlign: 'center',
      }}
    >
      <h4>🚪 {room.name}</h4>
      {/* First Row: Inputs */}
      <Stack direction="row" spacing={1} justifyContent="center">
        <TextField
          label="🌡️Temp"
          type="number"
          value={temperature}
          onChange={(e) => setTemperature(Number(e.target.value))}
          size="small"
          sx={{
            width: '70px',
            input: { color: '#f0f0f0' }, // Light text color
            label: { color: '#b0b0b0' }, // Light label color
          }}
        />
        <TextField
          label="💧Hum"
          type="number"
          value={humidity}
          onChange={(e) => setHumidity(Number(e.target.value))}
          size="small"
          sx={{
            width: '70px',
            input: { color: '#f0f0f0' },
            label: { color: '#b0b0b0' },
          }}
        />
        <TextField
          label="🫁 CO₂"
          type="number"
          value={co2}
          onChange={(e) => setCO2(Number(e.target.value))}
          size="small"
          sx={{
            width: '70px',
            input: { color: '#f0f0f0' },
            label: { color: '#b0b0b0' },
          }}
        />
      </Stack>
      {/* Second Row: Buttons */}
      <Stack direction="row" spacing={1} justifyContent="center" mt={1}>
        <Button
          variant="contained"
          color="primary"
          onClick={handleApply}
          sx={{ textTransform: 'none' }}
        >
          Apply
        </Button>
        <Button
          variant="outlined"
          color="success"
          onClick={handleReset}
          sx={{ textTransform: 'none' }}
        >
          Reset
        </Button>
        <Button
          variant="outlined"
          color="error"
          onClick={handleBreak}
          sx={{ textTransform: 'none' }}
        >
          Break
        </Button>
      </Stack>
      <Snackbar open={toast.open} anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}>
        <Alert severity={toast.success ? 'success' : 'error'}>{toast.message}</Alert>
      </Snackbar>
    </Box>
  );
};

export default Room;
