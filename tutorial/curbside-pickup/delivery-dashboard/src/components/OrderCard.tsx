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
import { Car, Clock, Truck } from 'lucide-react';
import { Order } from '../types';
import { getColorValue } from '../utils/colors';
import { formatTime } from '../utils/formatters';

interface OrderCardProps {
    order: Order;
}

const OrderCard: React.FC<OrderCardProps> = ({ order }) => {
    const { orderId, vehicleId, vehicleMake, vehicleModel, vehicleColor, readyTimestamp, driverName } = order;

    return (
        <div className="bg-gradient-to-r from-green-50 to-transparent p-3 rounded-lg border border-green-100">
            <div className="flex items-start gap-3">
                <div className="bg-white p-2 rounded shadow-sm">
                    <Car 
                        className="h-8 w-8"
                        style={{ color: getColorValue(vehicleColor) }}
                    />
                </div>
                <div className="flex-1">
                    <div className="flex justify-between items-start">
                        <div>
                            <div className="font-medium">Order #{orderId}</div>
                            <div className="text-sm text-gray-600">
                                {`${vehicleId} • ${vehicleColor} ${vehicleMake} ${vehicleModel}`}
                            </div>
                            <div className="flex items-center gap-1 mt-1">
                                <Clock className="h-3 w-3 text-gray-400" />
                                <span className="text-xs text-gray-500">
                                    Ready since {formatTime(readyTimestamp)}
                                </span>
                            </div>
                        </div>
                        <div className="flex items-center gap-1 text-sm text-gray-600">
                            <Truck className="h-4 w-4" />
                            {driverName}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default OrderCard;