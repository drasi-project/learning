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

import axios from 'axios';

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:8004')
  .replace(/\/+$/, ''); // Replace trailing slashes from URL found in .env

const api = axios.create({
  baseURL: API_BASE_URL
});

export const fetchOrders = async (status) => {
  const response = await api.get(`/orders/`, {
    params: { status }
  });
  return response.data;
};

export const createOrder = async (orderData) => {
  const response = await api.post('/orders/', orderData);
  return response.data;
};

export const updateOrderStatus = async (orderId, status) => {
  const response = await api.patch(`/orders/${orderId}/status?status=${status}`);
  return response.data;
};

export const getOrder = async (orderId) => {
  const response = await api.get(`/orders/${orderId}`);
  return response.data;
};

// Error handler helper
export const handleApiError = (error) => {
  if (error.response) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx
    return error.response.data.detail || 'An error occurred while processing your request';
  } else if (error.request) {
    // The request was made but no response was received
    return 'No response received from server';
  } else {
    // Something happened in setting up the request that triggered an Error
    return 'Error setting up the request';
  }
};