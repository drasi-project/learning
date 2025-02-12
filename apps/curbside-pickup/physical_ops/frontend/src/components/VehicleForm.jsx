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

import React, { useState } from 'react';
import { X } from 'lucide-react';
import { CAR_MAKES } from '../constants/vehicles';
import { VEHICLE_COLORS } from '../constants/colors';

const VehicleForm = ({ onSubmit, onClose }) => {
  const [formData, setFormData] = useState({
    plate: '',
    make: '',
    model: '',
    color: '',
    location: 'Parking'
  });
  const [errors, setErrors] = useState({});

  const validateForm = () => {
    const newErrors = {};
    if (!formData.plate) newErrors.plate = true;
    if (!formData.make) newErrors.make = true;
    if (!formData.model) newErrors.model = true;
    if (!formData.color) newErrors.color = true;

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (validateForm()) {
      onSubmit(formData);
      setFormData({
        plate: '',
        make: '',
        model: '',
        color: 'Blue',
        location: 'Parking'
      });
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 shadow-lg mx-auto max-w-2xl w-full m-4">
        {/* Header with close button */}
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">Add New Vehicle</h2>
          <button 
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            <X size={24} />
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="space-y-4">
            {/* First Row */}
            <div className="grid grid-cols-2 gap-4">
              <input 
                className={`w-full border p-2 rounded ${errors.plate ? 'border-red-500 bg-red-50' : ''}`}
                placeholder="License Plate *"
                value={formData.plate}
                onChange={(e) => {
                  setFormData({...formData, plate: e.target.value});
                  setErrors({...errors, plate: false});
                }}
              />
              <select 
                className={`w-full border p-2 rounded bg-white ${errors.make ? 'border-red-500 bg-red-50' : ''}`}
                value={formData.make}
                onChange={(e) => {
                  setFormData({...formData, make: e.target.value, model: ''});
                  setErrors({...errors, make: false});
                }}
              >
                <option value="">Select Make *</option>
                {Object.keys(CAR_MAKES).map(make => (
                  <option key={make} value={make}>{make}</option>
                ))}
              </select>
            </div>

            {/* Second Row */}
            <div className="grid grid-cols-2 gap-4">
              <select 
                className={`w-full border p-2 rounded bg-white ${errors.model ? 'border-red-500 bg-red-50' : ''}`}
                value={formData.model}
                disabled={!formData.make}
                onChange={(e) => {
                  setFormData({...formData, model: e.target.value});
                  setErrors({...errors, model: false});
                }}
              >
                <option value="">Select Model *</option>
                {formData.make && CAR_MAKES[formData.make].map(model => (
                  <option key={model} value={model}>{model}</option>
                ))}
              </select>

              <div className={`flex gap-2 items-center ${errors.color ? 'bg-red-50 rounded p-2' : ''}`}>
                <span className="text-sm text-gray-500">Color *</span>
                {VEHICLE_COLORS.map(color => (
                  <button
                    type="button"
                    key={color.name}
                    className={`w-6 h-6 rounded-full focus:ring-2 focus:ring-offset-2 focus:ring-blue-500
                      ${formData.color === color.hex ? 'ring-2 ring-offset-2 ring-blue-500' : ''}
                      ${errors.color ? 'ring-1 ring-red-500' : ''}`}
                    style={{ backgroundColor: color.hex }}
                    title={color.name}
                    onClick={() => {
                      setFormData({...formData, color: color.name});
                      setErrors({...errors, color: false});
                    }}
                  />
                ))}
              </div>
            </div>

            {/* Submit Button */}
            <div className="flex justify-end pt-2">
              <button 
                type="submit"
                className="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600"
              >
                Add Vehicle
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};

export default VehicleForm;