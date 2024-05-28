import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { driver } from 'gremlin'

const authenticator = new driver.auth.PlainTextSaslAuthenticator(
    `/dbs/${process.env["COSMOS_DB_NAME"]}/colls/${process.env["COSMOS_CONTAINER"]}`, process.env["COSMOS_GREMLIN_KEY"]
);

const gremlinClient = new driver.Client(
  process.env["COSMOS_GREMLIN_ENDPOINT"],
  {
    authenticator,
    traversalsource: "g",
    rejectUnauthorized: true,
    mimeType: "application/vnd.gremlin-v2.0+json"
  }
);


export async function answer(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    
    try {

        let reqBody: any = await request.json();
        let questionId = reqBody.questionId;
        let playerId = reqBody.playerId;
        let answer = reqBody.answer;
        let skipped = reqBody.skipped;
        let duration = reqBody.duration;

        let time = Date.now();
        
        gremlinClient.submit(`g
            .addV('Answer')
                .property('partition', 0)
                .property('questionId', questionId)
                .property('answer', answer)
                .property('skipped', skipped)
                .property('duration', duration)
                .property('time', time)
            .as('answer')
            .addE('ANSWER_FROM')
                .from('answer')
                .to(g.V([0, playerId]))`, {
            playerId,
            questionId,
            answer,
            skipped,
            duration,
            time
        });
    }
    catch (error) {
        context.error(error);
        return { status: 500 };
    }
    
    return { status: 200 };
};

app.http('answer', {
    methods: ['POST'],
    authLevel: 'anonymous',
    handler: answer
});
