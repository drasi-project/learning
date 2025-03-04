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

// Order Status
export const ORDER_STATUS = {
    PREPARING: 'preparing',
    READY: 'ready'
  };
  
  // Alert Types
  export const ALERT_TYPE = {
    ERROR: 'error',
    SUCCESS: 'success'
  };
  
  // Alert Durations (in milliseconds)
  export const ALERT_DURATION = {
    ERROR: 10000,    // 10 seconds
    SUCCESS: 5000    // 5 seconds
  };
  
  // Form Validation Messages
  export const VALIDATION_MESSAGES = {
    REQUIRED: 'This field is required',
    INVALID_INPUT: 'Invalid input'
  };
  
  // API Error Messages
  export const API_ERROR_MESSAGES = {
    DEFAULT: 'An error occurred. Please try again later.',
    NETWORK: 'Network error. Please check your connection.',
    SERVER: 'Server error. Please try again later.',
    NOT_FOUND: 'Resource not found.',
    VALIDATION: 'Please check your input and try again.'
  };