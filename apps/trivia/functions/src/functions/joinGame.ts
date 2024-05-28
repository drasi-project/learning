import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { driver } from 'gremlin'
import { uniqueNamesGenerator, Config, starWars } from 'unique-names-generator';

const nameConfig: Config = {
  dictionaries: [starWars],
  separator: ' ',
  length: 1,
};

const authenticator = new driver.auth.PlainTextSaslAuthenticator(
    `/dbs/${process.env["COSMOS_DB_NAME"]}/colls/${process.env["COSMOS_CONTAINER"]}`, process.env["COSMOS_GREMLIN_KEY"]
);

function getRandomInt(min, max) {
    const minCeiled = Math.ceil(min);
    const maxFloored = Math.floor(max);
    return Math.floor(Math.random() * (maxFloored - minCeiled) + minCeiled);
}


const client = new driver.Client(
  process.env["COSMOS_GREMLIN_ENDPOINT"],
  {
    authenticator,
    traversalsource: "g",
    rejectUnauthorized: true,
    mimeType: "application/vnd.gremlin-v2.0+json"
  }
);

export async function joinGame(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log(`Http function processed request for url "${request.url}"`);

    try {

        let reqBody: any = await request.json();
        let teamName = reqBody.teamName;
        
        let teams = await client.submit("g.V().hasLabel('Team').has('name', teamName)", { teamName });    
        if (teams._items.length == 0) {
            return { status: 400, body: "Team not found" };
        }

        let team = teams._items[0];

        const playerName: string = uniqueNamesGenerator(nameConfig) + " " + getRandomInt(1, 100);

        let players = await client.submit("g.addV('Player').property('partition', 0).property('name', playerName)", { 
            playerName
        });

        let player = players._items[0];

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
            teamName: team.name
        };

        return { jsonBody: res };
    }
    catch (error) {
        context.error(error);
        return { status: 500 };
    }
};

app.http('joinGame', {
    methods: ['POST'],
    authLevel: 'anonymous',
    handler: joinGame
});
