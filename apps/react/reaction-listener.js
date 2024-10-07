/**
 * Copyright 2024 The Drasi Authors.
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

import {getConnection} from './connection-pool'

export default class ReactionListener {
    constructor(url, queryId, onMessage) {
        this.url = url;
        this.queryId = queryId;
        this.onMessage = onMessage;
        this.sigRConn = getConnection(url);     
        this.reloadData = []; 
        
        let self = this;

        this.sigRConn.started
        .then(result => {
            self.sigRConn.connection.on(self.queryId, self.onMessage);            
            }
        );
    }

    reload(callback) {
        console.log("requesting reload for " + this.queryId);
        let self = this;

        this.sigRConn.started
        .then(_ => {
            self.sigRConn.connection.stream("reload", this.queryId)
            .subscribe({
                next: item => {
                console.log(self.queryId + " reload next: " + JSON.stringify(item));
                switch (item['op']) {
                    case 'h':
                    self.reloadData = [];                  
                    break;
                    case 'r':
                    self.reloadData.push(item.payload.after);
                    break;
                }
                },
                complete: () => {
                console.log(self.queryId + " reload complete");
                if (callback) {
                    callback(self.reloadData);
                }
                
                },
                error: err => console.error(self.queryId + err)
            });
        });
      }
}