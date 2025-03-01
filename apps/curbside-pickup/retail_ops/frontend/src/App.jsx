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

import React, { useState, useEffect, useCallback } from 'react';
import Alert from './components/Alert';
import { PreparingOrderList, ReadyOrderList } from './components/OrderList';
import NewOrderDialog from './components/NewOrderDialog';
import { fetchOrders, updateOrderStatus, createOrder } from './utils/api';

function App() {
  const [orders, setOrders] = useState({ preparing: [], ready: [] });
  const [alert, setAlert] = useState(null);

  const showAlert = (message, type = 'error') => {
    setAlert({ message, type });
    setTimeout(() => {
      setAlert(null);
    }, type === 'error' ? 10000 : 5000);
  };

  const loadOrders = useCallback(async () => {
    try {
      const [preparingOrders, readyOrders] = await Promise.all([
        fetchOrders('preparing'),
        fetchOrders('ready')
      ]);
      setOrders({
        preparing: preparingOrders,
        ready: readyOrders
      });
    } catch (error) {
      showAlert('Failed to fetch orders');
      console.error('Error fetching orders:', error);
    }
  }, []);

  useEffect(() => {
    loadOrders();
  }, [loadOrders]);

  const handleNewOrder = async (formData) => {
    try {
      await createOrder({
        customer_name: formData.customer_name,
        driver_name: formData.driver_name,
        plate: formData.plate,
        status: 'preparing'
      });
      showAlert('Order created successfully', 'success');
      loadOrders();
    } catch (error) {
      showAlert('Failed to create order');
      console.error('Error creating order:', error);
    }
  };

  const handleStatusChange = async (orderId, newStatus) => {
    try {
      await updateOrderStatus(orderId, newStatus);
      showAlert('Order status updated successfully', 'success');
      loadOrders();
    } catch (error) {
      showAlert('Failed to update order status');
      console.error('Error updating order status:', error);
    }
  };

  return (
    <div className="p-6 w-full min-h-screen bg-gray-100">
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-bold">Retail Operations</h1>
          <NewOrderDialog onSubmit={handleNewOrder} />
        </div>
        
        <div className="grid grid-cols-2 gap-8 mb-8">
          <PreparingOrderList 
            orders={orders.preparing} 
            onStatusChange={handleStatusChange}
          />
          <ReadyOrderList 
            orders={orders.ready} 
            onStatusChange={handleStatusChange}
          />
        </div>
      </div>

      {alert && (
        <Alert 
          message={alert.message} 
          type={alert.type} 
          onClose={() => setAlert(null)} 
        />
      )}
    </div>
  );
}

export default App;