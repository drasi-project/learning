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

import axios from 'axios';

// Use relative path in production (when served from same domain)
// or use environment variable/localhost for development
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 
  (import.meta.env.PROD ? '' : 'http://localhost:8003');

// In production, when served from a base path, we need to include it
const baseURL = import.meta.env.PROD 
  ? `${import.meta.env.BASE_URL}vehicles`.replace(/\/+/g, '/')
  : `${API_BASE_URL}/vehicles`;

const api = axios.create({
  baseURL: baseURL
});

export const vehicleApi = {
  getAll: () => api.get('/'),
  getByPlate: (plate) => api.get(`/${plate}`),
  create: (vehicleData) => api.post('/', vehicleData),
  updateLocation: (plate, location) => api.put(`/${plate}`, { location }),
  delete: (plate) => api.delete(`/${plate}`)
};