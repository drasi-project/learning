const { EventHubProducerClient } = require("@azure/event-hubs");
const { v4: uuidv4 } = require('uuid');

require('dotenv').config();

const connectionString = process.env["EVENTHUB_CONNECTION_STRING"];

let vehicles = [
    { vehicleId: '000', odometer: 15000, maxDaily: 100, oilChangeProb: 0.02, brakeProb: 0.02 },
    { vehicleId: '001', odometer: 15000, maxDaily: 300, oilChangeProb: 0.01, brakeProb: 0.01 },
    { vehicleId: '002', odometer: 10000, maxDaily: 50, oilChangeProb: 0.01, brakeProb: 0.07 },
    { vehicleId: '003', odometer: 25000, maxDaily: 260, oilChangeProb: 0.01, brakeProb: 0.01 },
    { vehicleId: '004', odometer: 15000, maxDaily: 180, oilChangeProb: 0.03, brakeProb: 0.01 },
    { vehicleId: '005', odometer: 10000, maxDaily: 100, oilChangeProb: 0.02, brakeProb: 0.01 },
    { vehicleId: '006', odometer: 15000, maxDaily: 220, oilChangeProb: 0.02, brakeProb: 0.01 },
    { vehicleId: '007', odometer: 25000, maxDaily: 320, oilChangeProb: 0.1, brakeProb: 0.01 },
    { vehicleId: '008', odometer: 10000, maxDaily: 350, oilChangeProb: 0.02, brakeProb: 0.02 },
    { vehicleId: '009', odometer: 12000, maxDaily: 100, oilChangeProb: 0.01, brakeProb: 0.01 },
]

// @ts-ignore
const statusProducer = new EventHubProducerClient(connectionString, "vehiclestatus");
// @ts-ignore
const eventProducer = new EventHubProducerClient(connectionString, "vehicleevent");


const startDate = new Date('2024-05-01T00:00:00Z').getTime();
const endDate = new Date('2024-07-01T00:00:00Z').getTime();
const msInHour = 3600000;
const sleepTime = 10000;

const sendMaintenanceAlert = async (vehicleId, timestamp, dueDate, subType) => {
    let data = {
        "eventId": uuidv4(),
        "eventType": "MaintenanceAlert",
        "eventSubType": subType,
        "driverId": null,
        "extendedProperties": [
            {
                "name": "MaximumDueDates",
                "value": new Date(dueDate).toISOString()
            }
        ],
        "additionalProperties": {
            "Data": {},
            "Id": uuidv4(),
            "Source": "CCDKfeed",
            "Type": "VehicleDataStream",
            "Time": new Date(timestamp).toISOString(),
            "DataSchema": null,
            "DataContentType": null,
            "ExtensionAttributes": {}
        },
        "vehicleId": vehicleId,
        "timestamp": new Date(timestamp).toISOString(),
        "schemaVersion": "1.0",
        "geoLocation": null
    };

    console.log(data);

    let batch = await eventProducer.createBatch();
    batch.tryAdd({ body: data });
    await eventProducer.sendBatch(batch);
};


const sendStatus = async (vehicleId, timestamp, odometer, rpm) => {
    let data = {
        "additionalProperties": {
            "Data": {},
            "DataContentType": null,
            "DataSchema": null,
            "ExtensionAttributes": {},
            "Id": uuidv4(),
            "Source": "CCDKfeed",
            "Time": new Date(timestamp).toISOString(),
            "Type": "VehicleDataStream"
        },
        "geoLocation": null,
        "schemaVersion": "1.0",
        "signals": [
            {
                "name": "Vehicle.TraveledDistance",
                "timestamp": new Date(timestamp).toISOString(),
                "value": odometer
            },
            {
                "name": "OBD.EngineSpeed",
                "timestamp": new Date(timestamp).toISOString(),
                "value": rpm
            }
        ],
        "timestamp": new Date(timestamp).toISOString(),
        "vehicleId": vehicleId
    };
    console.log(data);
    let batch = await statusProducer.createBatch();
    batch.tryAdd({ body: data });
    await statusProducer.sendBatch(batch);
};

const main = async () => {
    try {
        
        for (let time = startDate; time < endDate; time += (msInHour * 24)) {            
            console.log(new Date(time).toISOString());
            let promises = [];
            for (const v of vehicles) {
                
                let engineRpm = 0;
                v.odometer = Math.round(v.odometer + (Math.random() * v.maxDaily));

                if (Math.random() < 0.7) {
                    if (Math.random() < 0.1) {
                        engineRpm = 6000 + (Math.random() * 1000);
                    } else {
                        engineRpm = Math.random() * 5000;
                    }
                }
                await sendStatus(v.vehicleId, time, v.odometer, Math.round(engineRpm));            

                if (Math.random() < v.oilChangeProb) {
                    await sendMaintenanceAlert(v.vehicleId, time, time + (msInHour * 24 * 30), 'OilChange');
                }

                if (Math.random() < v.brakeProb) {
                    await sendMaintenanceAlert(v.vehicleId, time, time + (msInHour * 24 * 30), 'BrakePadChange');
                }

            }
            promises.push(new Promise((resolve) => setTimeout(resolve, sleepTime)));
            await Promise.all(promises);            
        }
        
    } catch (err) {
        console.error(err);
    }
};

main().catch(console.error);