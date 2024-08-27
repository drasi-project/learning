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

async function UpdateSensor(context, bid, fid, rid, sid, sensorData) {
  // context.log(`UpdateSensor - rid:${rid}, sid:${sid}, sensorData:${JSON.stringify(sensorData)}`);

  var query = `g.V(bid).hasLabel("Building")`;
  query += `.in("PART_OF").hasLabel("Floor").hasId(fid)`;
  query += `.in("PART_OF").hasLabel("Room").hasId(rid)`;
  query += ".property(sid, value)";

  const params = {
    bid,
    fid,
    rid,
    sid,
    value: sensorData.value
  };

  const res = await client.submit(query, params);

  // context.log(`UpdateOrder - res: ${JSON.stringify(res)}`);
  const node = res.first();

  let roomName = node.properties?.name[0]?.value ?? "";
  let temp = node.properties?.temp[0]?.value ?? "";
  let humidity = node.properties?.humidity[0]?.value ?? "";
  let co2 = node.properties?.co2[0]?.value ?? "";
  let comfortLevel = Math.floor(50 + (temp - 72) + (humidity - 42) + (co2 > 500 ? (co2 - 500) / 25 : 0));
  console.log(`comfortLevel: ${comfortLevel}`);
  return {
    body: {
      roomId: rid,
      floorId: fid,
      buildingId: bid,
      roomName: node.properties?.name[0]?.value ?? "",
      temp: node.properties?.temp[0]?.value ?? "",
      humidity: node.properties?.humidity[0]?.value ?? "",
      co2: node.properties?.co2[0]?.value ?? "",
      comfortLevel: comfortLevel
    }
  };
}

module.exports = async function (context, req) {
  // context.log(`request: ${JSON.stringify(req)}`);

  var result = {};

  switch (req.method) {
    case "GET":
      break;
    case "POST":
      if (req.body) {
        result = await UpdateSensor(context, req.params.bid, req.params.fid, req.params.rid, req.params.sid, req.body);
      }
      break;
    case "PUT":
      break;
    default:
      break;
  }
  return result;
}