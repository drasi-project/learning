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

import React from 'react';
import { Package, ShoppingBag } from 'lucide-react';

const OrderCard = ({ 
  order, 
  status, 
  onStatusChange 
}) => {
  const isPreparing = status === 'preparing';
  
  return (
    <div className={`bg-white p-4 rounded-lg shadow ${!isPreparing ? 'border-2 border-green-500' : ''}`}>
      <div className="flex justify-between items-start">
        <div>
          <div className="flex items-center gap-2">
            {isPreparing ? (
              <Package size={20} className="text-orange-500" />
            ) : (
              <ShoppingBag size={20} className="text-green-500" />
            )}
            <span className="font-semibold">Order #{order.id}</span>
          </div>
          <div className="text-sm text-gray-600 mt-1">Customer: {order.customer_name}</div>
          <div className="text-xs text-gray-500 mt-1">Driver: {order.driver_name}</div>
          <div className="text-xs text-gray-500">Vehicle: {order.plate}</div>
        </div>
        <div>
          <button 
            className={`text-white text-sm px-3 py-1 rounded-full ${
              isPreparing 
                ? 'bg-green-500 hover:bg-green-600' 
                : 'bg-gray-500 hover:bg-gray-600'
            }`}
            onClick={() => onStatusChange(order.id, isPreparing ? 'ready' : 'preparing')}
          >
            {isPreparing ? 'Mark Ready' : 'Return to Prep'}
          </button>
        </div>
      </div>
    </div>
  );
};

export default OrderCard;