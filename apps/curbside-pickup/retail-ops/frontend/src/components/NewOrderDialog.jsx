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
import { Plus } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogTitle,
  DialogTrigger,
  DialogPortal,
  DialogOverlay,
} from "@radix-ui/react-dialog";

const NewOrderDialog = ({ onSubmit }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [formData, setFormData] = useState({
    customer_name: '',
    driver_name: '',
    plate: ''
  });
  const [errors, setErrors] = useState({});

  const validateForm = () => {
    const newErrors = {};
    if (!formData.customer_name.trim()) newErrors.customer_name = 'Customer name is required';
    if (!formData.driver_name.trim()) newErrors.driver_name = 'Driver name is required';
    if (!formData.plate.trim()) newErrors.plate = 'License plate is required';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = () => {
    if (validateForm()) {
      onSubmit(formData);
      setFormData({ customer_name: '', driver_name: '', plate: '' });
      setIsOpen(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger asChild>
        <button className="flex items-center gap-2 bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600">
          <Plus size={20} />
          New Pickup Order
        </button>
      </DialogTrigger>
      <DialogPortal>
        <DialogOverlay className="fixed inset-0 bg-black bg-opacity-25" />
        <DialogContent className="fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-white p-6 rounded-lg shadow-lg sm:max-w-md w-full">
          <DialogTitle className="text-lg font-semibold mb-4">New Pickup Order</DialogTitle>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Customer Name *
              </label>
              <input 
                className={`w-full border p-2 rounded ${errors.customer_name ? 'border-red-500' : ''}`}
                value={formData.customer_name}
                onChange={(e) => setFormData({...formData, customer_name: e.target.value})}
                placeholder="Enter customer name"
              />
              {errors.customer_name && (
                <p className="text-red-500 text-xs mt-1">{errors.customer_name}</p>
              )}
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Driver Name *
              </label>
              <input 
                className={`w-full border p-2 rounded ${errors.driver_name ? 'border-red-500' : ''}`}
                value={formData.driver_name}
                onChange={(e) => setFormData({...formData, driver_name: e.target.value})}
                placeholder="Enter driver name"
              />
              {errors.driver_name && (
                <p className="text-red-500 text-xs mt-1">{errors.driver_name}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                License Plate *
              </label>
              <input 
                className={`w-full border p-2 rounded ${errors.plate ? 'border-red-500' : ''}`}
                value={formData.plate}
                onChange={(e) => setFormData({...formData, plate: e.target.value})}
                placeholder="Enter vehicle plate number"
              />
              {errors.plate && (
                <p className="text-red-500 text-xs mt-1">{errors.plate}</p>
              )}
            </div>

            <button 
              className="w-full bg-blue-500 text-white p-2 rounded-lg hover:bg-blue-600 flex items-center justify-center gap-2"
              onClick={handleSubmit}
            >
              <Plus size={20} />
              Create Pickup Order
            </button>
          </div>
        </DialogContent>
      </DialogPortal>
    </Dialog>
  );
};

export default NewOrderDialog;