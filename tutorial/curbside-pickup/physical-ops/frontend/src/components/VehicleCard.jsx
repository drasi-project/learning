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

import React from 'react';
import { Car } from 'lucide-react';
import { VEHICLE_COLORS, DEFAULT_COLOR } from '../constants/colors';

const VehicleCard = ({ vehicle, onAction, actionText, colorClass = '' }) => {
  return (
    <div className={`bg-white p-4 rounded-lg shadow ${colorClass}`}>
      <Car size={48} style={{ color: getHexByName(vehicle.color) }} />
      <div className="text-sm font-semibold">{vehicle.plate}</div>
      <div className="text-xs text-gray-600">{vehicle.make} {vehicle.model}</div>
      <button 
        onClick={() => onAction(vehicle)}
        className="mt-2 bg-gray-500 text-white text-sm px-3 py-1 rounded-full hover:bg-gray-600"
      >
        {actionText}
      </button>
    </div>
  );
};

// Helper function to get hex code by name
const getHexByName = (colorName) => {
  const color = VEHICLE_COLORS.find(c => c.name === colorName);
  return color ? color.hex : DEFAULT_COLOR.hex; // Use Yellow if color is unknown
};

export default VehicleCard;