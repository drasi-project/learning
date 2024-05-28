import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";

import { Pool } from "pg"

const pool = new Pool();


export async function question(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log(`Http function processed request for url "${request.url}"`);

    const client = await pool.connect();
    try {
        const res = await client.query('SELECT q.*, c.name, c.color FROM "Question" q INNER JOIN "Category" c ON c.id = q.cat_id ORDER BY RANDOM() LIMIT 1');
    
        console.log(res.rows[0]);

        let resp = {
            id: res.rows[0].id,
            category: res.rows[0].name,
            color: res.rows[0].color,
            question: res.rows[0].text,
            answers: [res.rows[0].answer, res.rows[0].alt_ans_1, res.rows[0].alt_ans_2, res.rows[0].alt_ans_3],
            correctAnswer: res.rows[0].answer
        };

        shuffle(resp.answers);

        return { jsonBody: resp };

    }
    catch (error) {
        context.error(error);
        return { status: 500 };
    }
    finally {
        client.release();
    }    
};

function shuffle(array: any[]) {
    let currentIndex = array.length;
    let randomIndex: number;
  
    while (currentIndex > 0) {
      randomIndex = Math.floor(Math.random() * currentIndex);
      currentIndex--;
      [array[currentIndex], array[randomIndex]] = [array[randomIndex], array[currentIndex]];
    }
  
    return array;
  }

app.http('question', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: question
});
