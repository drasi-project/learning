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

import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { driver } from 'gremlin'

const authenticator = new driver.auth.PlainTextSaslAuthenticator(
    `/dbs/${process.env["COSMOS_DB_NAME"]}/colls/${process.env["COSMOS_CONTAINER"]}`, process.env["COSMOS_GREMLIN_KEY"]
);

const client = new driver.Client(
  process.env["COSMOS_GREMLIN_ENDPOINT"],
  {
    authenticator,
    traversalsource: "g",
    rejectUnauthorized: true,
    mimeType: "application/vnd.gremlin-v2.0+json"
  }
);

export async function switchTeam(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log(`Http function processed request for url "${request.url}"`);

    let reqBody: any = await request.json();
    let teamName = reqBody.teamName;
    let playerId = reqBody.playerId;
    
    let teams = await client.submit("g.V().hasLabel('Team').has('name', teamName)", { teamName });    
    if (teams._items.length == 0) {
        return { status: 400, body: "Team not found" };
    }

    let team = teams._items[0];

    let players = await client.submit("g.V([0, playerId])", { 
        playerId
    });

    if (players._items.length == 0) {
        return { status: 400, body: "Player not found" };
    }

    let player = players._items[0];

    await client.submit("g.V([0, playerId]).outE('MEMBER_OF').drop()", {
        playerId
    });

    let member = await client.submit("g.addE('MEMBER_OF').from(g.V([0, playerId])).to(g.V([0, teamId]))", {
        playerId: player.id,
        teamId: team.id
    });
    
    console.log(player);
    console.log(member);

    let res = { 
        playerId: player.id,
        playerName: player.properties.name[0].value,
        teamId: team.id,
        teamName: team.properties.name[0].value
    };

    return { jsonBody: res };
};

app.http('switchTeam', {
    methods: ['POST'],
    authLevel: 'anonymous',
    handler: switchTeam
});
