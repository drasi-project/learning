const gremlin = require('gremlin');

// Physical Ops Client
const authenticator = new gremlin.driver.auth.PlainTextSaslAuthenticator(
  `/dbs/${process.env["PHYSICAL_OPS_DB_NAME"]}/colls/${process.env["PHYSICAL_OPS_CNT_NAME"]}`, process.env["PHYSICAL_OPS_KEY"]
)

const client = new gremlin.driver.Client(
  process.env["PHYSICAL_OPS_URL"],
  {
    authenticator,
    traversalsource: "g",
    rejectUnauthorized: true,
    mimeType: "application/vnd.gremlin-v2.0+json"
  }
);

async function GetVehicleById(context, id) {
  // context.log(`GetVehicleById: ${JSON.stringify(id)}`);

  const res = await client.submit(`g.V(id)`, { id });
  const node = res.first();

  if (node) {
    return {
      body: {
        id: node.id,
        name: node.properties?.name[0]?.value ?? "",
        make: node.properties?.make[0]?.value ?? "",
        model: node.properties?.model[0]?.value ?? "",
        color: node.properties?.color[0]?.value ?? "",
        plate: node.properties?.plate[0]?.value ?? ""
      }
    };
  } else {
    // TODO 
  }
}

async function GetAllVehicles(context) {
  // context.log(`GetAllVehicles`);

  const vehicles = [];
  var readable = client.stream(`g.V().hasLabel("Vehicle")`, {}, { batchSize: 100 });

  try {
    for await (const result of readable) {
      for (const node of result.toArray()) {
        const v = {
          id: node.id,
          name: node.properties?.name[0]?.value ?? "",
          make: node.properties?.make[0]?.value ?? "",
          model: node.properties?.model[0]?.value ?? "",
          color: node.properties?.color[0]?.value ?? "",
          plate: node.properties?.plate[0]?.value ?? ""
        };
        vehicles.push(v);
      }
    }
  } catch (err) {
    console.error(err.stack);
  }

  return {
    body: vehicles
  };
}

async function CreateVehicle(context, vehicle) {
  // context.log(`CreateVehicle: ${JSON.stringify(vehicle)}`);

  const locationRes = await client.submit("g.V().hasLabel('Zone').has('type', location)", {
    location: vehicle.location
  });
  const locationNode = locationRes.first();

  const res = await client.submit("g.addV(label).property('name', name).property('make', make).property('model', model).property('color', color).property('plate', plate).addE('LOCATED_IN').to(g.V(location))", {
    label: "Vehicle",
    name: `${vehicle.color} ${vehicle.make} ${vehicle.model} (${vehicle.plate})`,
    make: vehicle.make ?? "",
    model: vehicle.model ?? "",
    color: vehicle.color ?? "",
    plate: vehicle.plate ?? "",
    location: locationNode.id
  });

  // context.log(`CreateVehicle - res: ${JSON.stringify(res)}`);
  const node = res.first();

  return {
    body: {
      id: node.id,
      name: node.properties?.name[0]?.value ?? "",
      make: node.properties?.make[0]?.value ?? "",
      model: node.properties?.model[0]?.value ?? "",
      color: node.properties?.color[0]?.value ?? "",
      plate: node.properties?.plate[0]?.value ?? ""
    }
  };
}

async function UpdateVehicle(context, id, location) {
  context.log(`UpdateVehicle: ${JSON.stringify(location)}`);

  const locationRes = await client.submit("g.V().hasLabel('Zone').has('type', location)", {
    location: location.location
  });

  const locationNode = locationRes.first();
  await client.submit("g.V(source).outE().hasLabel('LOCATED_IN').drop()", { source: id });
  await client.submit("g.V(source).addE(relationship).to(g.V(target))", {
    source: id,
    relationship: "LOCATED_IN",
    target: locationNode.id
  });

  return {
    body: {}
  };
}

async function DeleteVehicleByPlate(context, plate) {
  context.log(`DeleteVehicle: ${JSON.stringify(plate)}`);

  const res = await client.submit("g.V().hasLabel('Vehicle').has('plate', plate).drop()", { plate });

  return {
    body: `Delete Vehicle ${plate}`
  };
}

module.exports = async function (context, req) {
  // context.log(`request: ${JSON.stringify(req)}`);

  var result = {};

  switch (req.method) {
    case "GET":
      if (req.params.id) {
        result = await GetVehicleById(context, req.params.id);
      } else {
        result = await GetAllVehicles(context);
      }
      break;
    case "POST":
      if (req.body) {
        result = await CreateVehicle(context, req.body);
      }
      break;
    case "PUT":
      if (req.body) {
        result = await UpdateVehicle(context, req.params.id, req.body);
      }
      break;
    case "DELETE":
      if (req.params.id) {
        result = await DeleteVehicleByPlate(context, req.params.id);
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