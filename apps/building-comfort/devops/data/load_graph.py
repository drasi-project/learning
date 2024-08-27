
from gremlin_python.driver import client, serializer, protocol
from gremlin_python.driver.protocol import GremlinServerError
import sys
import traceback
import config

def print_status_attributes(result):
    # This logs the status attributes returned for successful requests.
    # See list of available response status attributes (headers) that Gremlin API can return:
    #     https://docs.microsoft.com/en-us/azure/cosmos-db/gremlin-headers#headers
    #
    # These responses includes total request units charged and total server latency time.
    # 
    # IMPORTANT: Make sure to consume ALL results returend by client tothe final status attributes
    # for a request. Gremlin result are stream as a sequence of partial response messages
    # where the last response contents the complete status attributes set.
    #
    # This can be 
    print("    Response status_attributes:\n    {0}".format(result.status_attributes))

def cleanup_graph(client):
    query = "g.V().drop()"

    print("\n> {0}".format(query))
    callback = client.submitAsync(query)
    if callback.result() is not None:
        callback.result().all().result() 
    print("\n")
    print_status_attributes(callback.result())
    print("\n")

def create_room(client, building_num, floor_num, room_num):

    room_id = f"room_{building_num:02}_{floor_num:02}_{room_num:02}"
    room_name = f"Room {floor_num:02}{room_num:02}"
    floor_id = f"floor_{building_num:02}_{floor_num:02}"

    print(f"Creating Room - room_num:{room_num:02}, room_id: {room_id}, room_name:{room_name}")

    # Add Room Node    
    query = f"g.addV('Room').property('id', '{room_id}')"
    query += f".property('name', '{room_name}')"
    query += f".property('temp', {config.defaultRoomTemp})"
    query += f".property('humidity', {config.defaultRoomHumidity})"
    query += f".property('co2', {config.defaultRoomCo2})"

    callback = client.submitAsync(query)
    if callback.result() is not None:
        print("    Inserted this node:\n    {0}\n".format(
            callback.result().all().result()))
    else:
        print("Something went wrong with this query:\n    {0}".format(query))

    # Add PART_OF relation
    query = f"g.V('{room_id}').addE('PART_OF').to(g.V('{floor_id}'))"

    callback = client.submitAsync(query)
    if callback.result() is not None:
        print("    Inserted this edge:\n    {0}\n".format(
            callback.result().all().result()))
    else:
        print("Something went wrong with this query:\n    {0}".format(query))

def create_floor(client, building_num, floor_num):

    floor_id = f"floor_{building_num:02}_{floor_num:02}"
    floor_name = f"Floor {floor_num:02}"
    building_id = f"building_{building_num:02}"

    print(f"Creating Floor - floor_num:{floor_num:02}, floor_id: {floor_id}, floor_name:{floor_name}")

    # Add Floor Node
    query = f"g.addV('Floor').property('id', '{floor_id}')"
    query += f".property('name', '{floor_name}')"

    callback = client.submitAsync(query)
    if callback.result() is not None:
        print("    Inserted this node:\n    {0}\n".format(
            callback.result().all().result()))
    else:
        print("Something went wrong with this query:\n    {0}".format(query))

    # Add PART_OF relation
    query = f"g.V('{floor_id}').addE('PART_OF').to(g.V('{building_id}'))"

    callback = client.submitAsync(query)
    if callback.result() is not None:
        print("    Inserted this edge:\n    {0}\n".format(
            callback.result().all().result()))
    else:
        print("Something went wrong with this query:\n    {0}".format(query))

    # Add Rooms
    for room_num in range(1, config.roomCount + 1):
      create_room(client, building_num, floor_num, room_num)


def create_building(client, building_num):

    building_id = f"building_{building_num:02}"
    building_name = f"Building {building_num:02}"

    print(f"Creating Building - building_num:{building_num:02}, building_id: {building_id}, building_name:{building_name}")

    query = f"g.addV('Building').property('id', '{building_id}')"
    query += f".property('name', '{building_name}')"

    callback = client.submitAsync(query)
    if callback.result() is not None:
        print("    Inserted this node:\n    {0}\n".format(
            callback.result().all().result()))
    else:
        print("Something went wrong with this query:\n    {0}".format(query))

    for floor_num in range(1, config.floorCount + 1):
      create_floor(client, building_num, floor_num)

try:
    client = client.Client(config.cosmosUri, 'g',
                           username=config.cosmosUserName,
                           password=config.cosmosPassword,
                           message_serializer=serializer.GraphSONSerializersV2d0()
                           )

    # Drop the entire Graph
    input("About to drop whatever graph is on the server. Press any key to continue...")
    cleanup_graph(client)

    # Insert buildings
    input("About to create data. Press any key to continue...")
    for building_num in range(1, config.buildingCount + 1):
      create_building(client, building_num)

except GremlinServerError as e:
    print('Code: {0}, Attributes: {1}'.format(e.status_code, e.status_attributes))

    # GremlinServerError.status_code returns the Gremlin protocol status code
    # These are broad status codes which can cover various scenaios, so for more specific
    # error handling we recommend using GremlinServerError.status_attributes['x-ms-status-code']
    # 
    # Below shows how to capture the Cosmos DB specific status code and perform specific error handling.
    # See detailed set status codes than can be returned here: https://docs.microsoft.com/en-us/azure/cosmos-db/gremlin-headers#status-codes
    #
    # See also list of available response status attributes that Gremlin API can return:
    #     https://docs.microsoft.com/en-us/azure/cosmos-db/gremlin-headers#headers
    cosmos_status_code = e.status_attributes["x-ms-status-code"]
    if cosmos_status_code == 409:
        print('Conflict error!')
    elif cosmos_status_code == 412:
        print('Precondition error!')
    elif cosmos_status_code == 429:
        print('Throttling error!');
    elif cosmos_status_code == 1009:
        print('Request timeout error!')
    else:
        print("Default error handling")

    traceback.print_exc(file=sys.stdout) 
    sys.exit(1)

print("\nAnd that's all! Sample complete")
input("Press Enter to continue...")