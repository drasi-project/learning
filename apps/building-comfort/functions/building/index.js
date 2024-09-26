const gremlin = require('gremlin');

// Facilities Client
const authenticator = new gremlin.driver.auth.PlainTextSaslAuthenticator(
  `/dbs/${process.env["FACILITIES_DB_NAME"]}/colls/${process.env["FACILITIES_CNT_NAME"]}`, process.env["FACILITIES_KEY"]
)

const client = new gremlin.driver.Client(
  process.env["FACILITIES_URL"],
  {
    authenticator,
    traversalsource: "g",
    rejectUnauthorized: true,
    mimeType: "application/vnd.gremlin-v2.0+json"
  }
);

async function GetBuildingById(context, id, includeFloors = false, includeRooms = false) {
  // context.log(`GetBuildingById: ${JSON.stringify(id)}`);

  const res = await client.submit(`g.V(id).hasLabel("Building")`,  { id });
  const node = res.first();

  if (node) {
    return {
      body: {
        id: node.id,
        name: node.properties?.name[0]?.value ?? "",
        comfortLevel: node.properties?.comfortLevel[0]?.value ?? "",
        floors: includeFloors ? await GetAllFloorsForBuilding(context, id, includeRooms) : undefined
      }
    };
  } else {
    // TODO 
  }
}

async function GetAllBuildings(context, includeFloors = false, includeRooms = false) {
  // context.log(`GetAllBuildings`);

  const buildings = [];
  var readable = client.stream(`g.V().hasLabel("Building")`, {}, { batchSize: 100 });

  try {
    for await (const result of readable) {
      for (const node of result.toArray()) {
        const v = {
            id: node.id,
            name: node.properties?.name[0]?.value ?? "",
            comfortLevel: node.properties?.comfortLevel[0]?.value ?? "",
            floors: includeFloors ? await GetAllFloorsForBuilding(context, node.id, includeRooms) : undefined
          };
          buildings.push(v);
      }
    }
  } catch (err) {
    console.error(err.stack);
  }

  return {
    body: buildings
  };
}

async function GetAllFloorsForBuilding(context, bid, includeRooms = false) {
  // context.log(`GetAllFloorsForBuilding`);

  const floors = [];
  var readable = client.stream(`g.V(bid).hasLabel("Building").in("PART_OF").hasLabel("Floor")`, { bid }, { batchSize: 100 });

  try {
    for await (const result of readable) {
      for (const node of result.toArray()) {
        const v = {
          id: node.id,
          name: node.properties?.name[0]?.value ?? "",
          comfortLevel: node.properties?.comfortLevel[0]?.value ?? "",
          rooms: includeRooms ? await GetAllRoomsForFloor(context, node.id) : undefined
        };
        floors.push(v);
      }
    }
  } catch (err) {
    console.error(err.stack);
  }

  return floors;
}

async function GetAllRoomsForFloor(context, fid) {
  // context.log(`GetAllRoomsForFloor`);

  const rooms = [];
  var readable = client.stream(`g.V(fid).hasLabel("Floor").in("PART_OF").hasLabel("Room")`, { fid }, { batchSize: 100 });

  try {
    for await (const result of readable) {
      for (const node of result.toArray()) {
        const v = {
          id: node.id,
          name: node.properties?.name[0]?.value ?? "",
          temp: node.properties?.temp[0]?.value ?? "",
          humidity: node.properties?.humidity[0]?.value ?? "",
          co2: node.properties?.co2[0]?.value ?? "",
          comfortLevel: node.properties?.comfortLevel[0]?.value ?? ""
        };
        rooms.push(v);
      }
    }
  } catch (err) {
    console.error(err.stack);
  }

  return rooms;
}

module.exports = async function (context, req) {
  // context.log(`request: ${JSON.stringify(req)}`);

  var result = {};

  switch (req.method) {
    case "GET":
      const includeFloors = "includeFloors" in req.query && req.query.includeFloors != "false";
      const includeRooms = "includeRooms" in req.query && req.query.includeRooms != "false";
      if (req.params.bid) {      
        result = await GetBuildingById(context, req.params.bid, includeFloors, includeRooms);
      } else {
        result = await GetAllBuildings(context, includeFloors, includeRooms);
      }
      break;
    default:
      break;
  }
  return result;
}