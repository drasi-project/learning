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

const gremlin = require('gremlin');

// Retail Ops Client
const authenticator = new gremlin.driver.auth.PlainTextSaslAuthenticator(
  `/dbs/${process.env["RETAIL_OPS_DB_NAME"]}/colls/${process.env["RETAIL_OPS_CNT_NAME"]}`, process.env["RETAIL_OPS_KEY"]
)

const client = new gremlin.driver.Client(
  process.env["RETAIL_OPS_URL"],
  {
    authenticator,
    traversalsource: "g",
    rejectUnauthorized: true,
    mimeType: "application/vnd.gremlin-v2.0+json"
  }
);

async function GetOrderById(context, id) {
  // context.log(`GetOrderById: ${JSON.stringify(id)}`);

  const res = await client.submit(`g.V(id)`,  { id });
  const node = res.first();

  if (node) {
    return {
      body: {
        id: node.id,
        customerName: node.properties?.customerName[0]?.value ?? "",
        status: node.properties?.name[0]?.value ?? ""
      }
    };
  } else {
    // TODO 
  }
}

async function GetAllOrders(context) {
  // context.log(`GetAllOrders`);

  const orders = [];
  var readable = client.stream(`g.V().hasLabel("Order")`, {}, { batchSize: 100 });

  try {
    for await (const result of readable) {
      for (const node of result.toArray()) {
        const v = {
          id: node.id,
          customerName: node.properties?.customerName[0]?.value ?? "",
          status: node.properties?.name[0]?.value ?? ""
        };
        orders.push(v);
      }
    }
  } catch (err) {
    console.error(err.stack);
  }

  return {
    body: orders
  };
}

async function CreateOrder(context, order) {
  // context.log(`CreateOrder: ${JSON.stringify(order)}`);

  // Create Order
  const orderRes = await client.submit("g.addV(label).property('name', name).property('customerName', customerName).property('status', status)", {
    label: "Order",
    name: `order - ${order.customerName}`,
    customerName: order.customerName,
    status: "preparing"
  });

  context.log(`CreateOrder - orderRes: ${JSON.stringify(orderRes)}`);
  const orderNode = orderRes.first();

  // Create Driver
  const driverRes = await client.submit("g.addV(label).property('name', name).property('make', make).property('model', model).property('color', color).property('plate', plate)", {
    label: "Driver",
    name: order.pickup.name,
    make: order.pickup.make ?? "",
    model: order.pickup.model ?? "",
    color: order.pickup.color ?? "",
    plate: order.pickup.plate ?? ""
  });

  context.log(`CreateOrder - orderRes: ${JSON.stringify(orderRes)}`);
  const driverNode = driverRes.first();

  // Create Order Pickup
  const pickupRes = await client.submit("g.addV(label).property('name', name)", {
    label: "OrderPickup",
    name: `${orderNode.id}::${driverNode.id}`
  });

  context.log(`CreateOrder - orderRes: ${JSON.stringify(orderRes)}`);
  const pickupNode = pickupRes.first();

  // Create Relations
  await client.submit("g.V(source).addE(relationship).to(g.V(target))", {
    source: pickupNode.id,
    relationship: "PICKUP_ORDER",
    target: orderNode.id
  });

  await client.submit("g.V(source).addE(relationship).to(g.V(target))", {
    source: pickupNode.id,
    relationship: "PICKUP_DRIVER",
    target: driverNode.id
  });
  
  return {
    body: {
      id: orderNode.id
    }
  };
}

async function UpdateOrder(context, id, order) {
  context.log(`UpdateOrder: ${JSON.stringify(order)}`);

  const res = await client.submit("g.V(id).property('status', status)", {
    id,
    label: "Order",
    status: order.status ?? "preparing"
  });

  // context.log(`UpdateOrder - res: ${JSON.stringify(res)}`);
  const node = res.first();

  return {
    body: {
      id: node.id,
      customerName: node.properties?.customerName[0]?.value ?? "",
      status: node.properties?.name[0]?.value ?? ""
    }
  };
}

module.exports = async function (context, req) {
  // context.log(`request: ${JSON.stringify(req)}`);

  var result = {};

  switch (req.method) {
    case "GET":
      if (req.params.id) {
        result = await GetOrderById(context, req.params.id);
      } else {
        result = await GetAllOrders(context);
      }
      break;
    case "POST":
      if (req.body) {
        result = await CreateOrder(context, req.body);
      }
      break;
    case "PUT":
      if (req.body) {
        result = await UpdateOrder(context, req.params.id, req.body);
      }
      break;
    default:
      break;
  }

  // const name = (req.query.name || (req.body && req.body.name));
  // const responseMessage = name
  //   ? "Hello, " + name + ". This HTTP triggered function executed successfully."
  //   : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.";

  // return {
  //   // status: 200, /* Defaults to 200 */
  //   body: responseMessage
  // };
  return result;
}