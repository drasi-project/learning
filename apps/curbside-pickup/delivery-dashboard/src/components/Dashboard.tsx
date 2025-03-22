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
import { ResultSet } from '@drasi/signalr-react';
import { PackageCheck } from 'lucide-react';
import { Order } from '../types';
import OrderCard from './OrderCard';
import ConnectionStatus from './ConnectionStatus';

const Dashboard: React.FC = () => {
    const signalRUrl = import.meta.env.VITE_SIGNALR_URL ? 
    import.meta.env.VITE_SIGNALR_URL.replace(/\/+$/, '') : undefined;
    const queryId = import.meta.env.VITE_QUERY_ID;

    if (!signalRUrl || !queryId) {
        return (
            <div className="text-red-600 p-4">
                Error: Missing environment variables. Please check .env file.
            </div>
        );
    }

    return (
        <div className="w-full h-full p-4 bg-gray-50">
            <div className="max-w-2xl mx-auto bg-white rounded-xl shadow-lg p-4 flex flex-col min-h-[350px]">
                <div className="flex items-center justify-between border-b pb-3">
                    <div className="flex items-center gap-2">
                        <div className="bg-green-100 p-2 rounded-full">
                            <PackageCheck className="text-green-600 h-5 w-5" />
                        </div>
                        <h2 className="font-bold text-lg">Ready for Delivery</h2>
                    </div>
                    <ConnectionStatus url={signalRUrl} />
                </div>

                <div className="overflow-auto flex-1 py-2">
                    <div className="space-y-3">
                        <ResultSet
                            url={signalRUrl}
                            queryId={queryId}
                            sortBy={(item: Order) => item.readyTimestamp}
                        >
                            {(order: Order) => (
                                <OrderCard 
                                    key={order.orderId} 
                                    order={order}
                                />
                            )}
                        </ResultSet>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;