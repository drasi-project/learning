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

    useEffect(() => {
        // Create a listener with a dummy query ID just to monitor connection
        const listener = new ReactionListener(
            url, 
            'connection-monitor', 
            () => {}  // Empty callback since we only care about connection status
        );

        const hubConnection = listener['sigRConn'].connection;
        
        hubConnection.onclose(() => setIsConnected(false));
        hubConnection.onreconnecting(() => setIsConnected(false));
        hubConnection.onreconnected(() => setIsConnected(true));
        
        // Check initial connection status
        listener['sigRConn'].started
            .then(() => setIsConnected(true))
            .catch(() => setIsConnected(false));

        // No cleanup needed as ReactionListener handles connection cleanup
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