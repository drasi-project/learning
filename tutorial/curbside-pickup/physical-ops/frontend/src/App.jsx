// Copyright 2025 The Drasi Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import React, { useState, useEffect, useCallback } from 'react';
import { ParkingSquare, ShoppingBag, PlusCircle } from 'lucide-react';
import { vehicleApi } from './services/vehicleApi';
import Alert from './components/Alert.jsx';
import VehicleCard from './components/VehicleCard.jsx';
import VehicleForm from './components/VehicleForm.jsx';

const App = () => {
  const [isFormVisible, setIsFormVisible] = useState(false);
  const [vehicles, setVehicles] = useState([]);
  const [alert, setAlert] = useState(null);
  
  const showAlert = useCallback((message, type = 'error') => {
    setAlert({ message, type });
  }, []);

  const loadVehicles = useCallback(async () => {
    try {
      const response = await vehicleApi.getAll();
      setVehicles(response.data);
    } catch (error) {
      showAlert('Failed to load vehicles');
    }
  }, [showAlert]);

  useEffect(() => {
    loadVehicles();
  }, [loadVehicles]);

  const handleAddVehicle = async (vehicleData) => {
    try {
      await vehicleApi.create(vehicleData);
      await loadVehicles();
      setIsFormVisible(false);
      showAlert('Vehicle added successfully', 'success');
    } catch (error) {
      if (error.response?.status === 422) {
        const validationErrors = error.response.data.detail;
        const errorMessages = validationErrors
          .map((err) => `${err.loc.join(' -> ')}: ${err.msg}`)
          .join('\n');
  
        showAlert(`Validation Error:\n${errorMessages}`);
      } else {
        showAlert('Failed to add vehicle');
      }
    }
  };

  const handleMoveVehicle = async (vehicle) => {
    const newLocation = vehicle.location === 'Parking' ? 'Curbside' : 'Parking';
    try {
      await vehicleApi.updateLocation(vehicle.plate, newLocation);
      await loadVehicles();
    } catch (error) {
      showAlert(`Failed to move vehicle to ${newLocation}`);
    }
  };

  const parkingLotVehicles = vehicles.filter(v => v.location === 'Parking');
  const curbsideVehicles = vehicles.filter(v => v.location === 'Curbside');

  return (
    <div className="p-6 w-full min-h-screen bg-gray-100">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-bold">Physical Operations</h1>
          <button
            onClick={() => setIsFormVisible(true)}
            className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600"
          >
            <PlusCircle size={20} />
            Add Vehicle
          </button>
        </div>

        {/* Vehicle Zones */}
        <div className="grid grid-cols-2 gap-8 mb-8">
          {/* Parking Lot */}
          <div className="bg-white rounded-lg p-6 shadow-lg">
            <div className="flex items-center gap-2 mb-4">
              <ParkingSquare size={24} className="text-blue-600" />
              <h2 className="text-xl font-semibold">Parking Lot</h2>
            </div>
            <div className="bg-gray-100 p-4 rounded-lg min-h-96">
              <div className="grid grid-cols-3 gap-4">
                {parkingLotVehicles.map(vehicle => (
                  <VehicleCard
                    key={vehicle.plate}
                    vehicle={vehicle}
                    onAction={handleMoveVehicle}
                    actionText="→ Curb"
                  />
                ))}
              </div>
            </div>
          </div>

          {/* Curbside Pickup */}
          <div className="bg-white rounded-lg p-6 shadow-lg">
            <div className="flex items-center gap-2 mb-4">
              <ShoppingBag size={24} className="text-blue-600" />
              <h2 className="text-xl font-semibold">Curbside Pickup</h2>
            </div>
            <div className="bg-yellow-50 p-4 rounded-lg min-h-96">
              <div className="grid grid-cols-2 gap-4">
                {curbsideVehicles.map(vehicle => (
                  <VehicleCard
                    key={vehicle.plate}
                    vehicle={vehicle}
                    onAction={handleMoveVehicle}
                    actionText="← Parking"
                    colorClass="border-2 border-green-500"
                  />
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Modal Form */}
        {isFormVisible && (
          <VehicleForm 
            onSubmit={handleAddVehicle}
            onClose={() => setIsFormVisible(false)}
          />
        )}

        {/* Alert */}
        {alert && (
          <Alert
            message={alert.message}
            type={alert.type}
            onClose={() => setAlert(null)}
          />
        )}
      </div>
    </div>
  );
};

export default App;