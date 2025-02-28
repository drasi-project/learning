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
import { Clock, Truck } from 'lucide-react';
import OrderCard from './OrderCard';

const OrderList = ({ 
  title, 
  icon: Icon,
  iconColor, 
  bgColor, 
  orders, 
  status,
  onStatusChange 
}) => {
  return (
    <div className="bg-white rounded-lg p-6 shadow-lg">
      <div className="flex items-center gap-2 mb-4">
        <Icon size={24} className={iconColor} />
        <h2 className="text-xl font-semibold">{title}</h2>
      </div>
      <div className={`${bgColor} p-4 rounded-lg min-h-96`}>
        <div className="space-y-4">
          {orders.map(order => (
            <OrderCard
              key={order.id}
              order={order}
              status={status}
              onStatusChange={onStatusChange}
            />
          ))}
          {orders.length === 0 && (
            <div className="text-gray-500 text-center py-4">
              No orders {status === 'preparing' ? 'in preparation' : 'ready for pickup'}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export const PreparingOrderList = ({ orders, onStatusChange }) => (
  <OrderList
    title="In Preparation"
    icon={Clock}
    iconColor="text-orange-500"
    bgColor="bg-orange-50"
    orders={orders}
    status="preparing"
    onStatusChange={onStatusChange}
  />
);

export const ReadyOrderList = ({ orders, onStatusChange }) => (
  <OrderList
    title="Ready for Pickup"
    icon={Truck}
    iconColor="text-green-500"
    bgColor="bg-green-50"
    orders={orders}
    status="ready"
    onStatusChange={onStatusChange}
  />
);

export default OrderList;