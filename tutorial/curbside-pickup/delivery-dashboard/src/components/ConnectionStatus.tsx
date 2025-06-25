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

import React, { useState, useEffect } from 'react';
import { ReactionListener } from '@drasi/signalr-react';
import { Wifi, WifiOff } from 'lucide-react';

interface ConnectionStatusProps {
    url: string;
}

const ConnectionStatus: React.FC<ConnectionStatusProps> = ({ url }) => {
    const [isConnected, setIsConnected] = useState(false);
    const [listener, setListener] = useState<ReactionListener | null>(null);

    useEffect(() => {
        let retryInterval: NodeJS.Timeout | null = null;
        
        const createConnection = () => {
            try {
                // Create a listener with a dummy query ID just to monitor connection
                const newListener = new ReactionListener(
                    url, 
                    'connection-monitor', 
                    () => {}  // Empty callback since we only care about connection status
                );

                const hubConnection = newListener['sigRConn'].connection;
                
                hubConnection.onclose(() => {
                    setIsConnected(false);
                    // Start retry mechanism when connection is closed
                    if (!retryInterval) {
                        retryInterval = setInterval(() => {
                            console.log('Retrying SignalR connection...');
                            createConnection();
                        }, 5000); // Retry every 5 seconds
                    }
                });
                
                hubConnection.onreconnecting(() => setIsConnected(false));
                hubConnection.onreconnected(() => {
                    setIsConnected(true);
                    // Clear retry interval on successful reconnection
                    if (retryInterval) {
                        clearInterval(retryInterval);
                        retryInterval = null;
                    }
                });
                
                // Check initial connection status
                newListener['sigRConn'].started
                    .then(() => {
                        setIsConnected(true);
                        // Clear retry interval on successful connection
                        if (retryInterval) {
                            clearInterval(retryInterval);
                            retryInterval = null;
                        }
                    })
                    .catch(() => {
                        setIsConnected(false);
                        // Start retry mechanism if initial connection fails
                        if (!retryInterval) {
                            retryInterval = setInterval(() => {
                                console.log('Retrying SignalR connection...');
                                createConnection();
                            }, 5000); // Retry every 5 seconds
                        }
                    });

                setListener(newListener);
            } catch (error) {
                console.error('Failed to create SignalR connection:', error);
                setIsConnected(false);
            }
        };

        createConnection();

        // Cleanup function
        return () => {
            if (retryInterval) {
                clearInterval(retryInterval);
            }
            if (listener) {
                listener['sigRConn'].connection.stop();
            }
        };
    }, [url]);

    if (isConnected) {
        return (
            <div className="flex items-center gap-1 text-xs px-2 py-1 bg-green-100 text-green-800 rounded-full">
                <Wifi className="h-3 w-3" />
                <span>Live</span>
            </div>
        );
    }

    return (
        <div className="flex items-center gap-1 text-xs px-2 py-1 bg-red-100 text-red-800 rounded-full">
            <WifiOff className="h-3 w-3" />
            <span>Disconnected</span>
        </div>
    );
};

export default ConnectionStatus;