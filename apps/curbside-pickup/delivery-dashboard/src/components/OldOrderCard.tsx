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
import { Car, Clock, Truck, CheckSquare, PackageCheck } from 'lucide-react';
import { Order } from '../types';
import { getColorValue } from '../utils/colors';
import { formatTime } from '../utils/formatters';

interface OrderCardProps {
    order: Order;
    isDelivered: boolean;
    onDeliveryToggle: (orderId: string) => void;
}

const OldOrderCard: React.FC<OrderCardProps> = ({ order, isDelivered, onDeliveryToggle }) => {
    const { orderId, vehicleId, vehicleMake, vehicleModel, vehicleColor, readyTimestamp, driverName } = order;

    return (
        <div className={`bg-gradient-to-r ${
            isDelivered 
            ? 'from-gray-50 to-transparent border-gray-100' 
            : 'from-green-50 to-transparent border-green-100'
        } p-3 rounded-lg border transition-colors duration-200`}>
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
                                {isDelivered ? (
                                    <>
                                        <PackageCheck className="h-3 w-3 text-green-600" />
                                        <span className="text-xs text-green-600">
                                            Delivered
                                        </span>
                                    </>
                                ) : (
                                    <>
                                        <Clock className="h-3 w-3 text-gray-400" />
                                        <span className="text-xs text-gray-500">
                                            Ready since {formatTime(readyTimestamp)}
                                        </span>
                                    </>
                                )}
                            </div>
                        </div>
                        <div className="flex flex-col items-end gap-2">
                            <div className="flex items-center gap-1 text-sm text-gray-600">
                                <Truck className="h-4 w-4" />
                                {driverName}
                            </div>
                            <button
                                onClick={() => onDeliveryToggle(orderId)}
                                className={`px-3 py-1.5 rounded-md border flex items-center gap-2 transition-colors ${
                                    isDelivered
                                    ? 'bg-green-600 border-green-600 text-white'
                                    : 'border-gray-300 text-gray-500 hover:border-green-600 hover:text-green-600'
                                }`}
                            >
                                <CheckSquare className="h-5 w-5" />
                                <span className="text-sm">Delivered</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default OldOrderCard;