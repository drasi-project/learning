# Copyright 2024 The Drasi Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import psycopg2
from psycopg2 import sql
import config

def connect_to_db():
    conn = psycopg2.connect(
        host=config.postgres_host,
        port=config.postgres_port,
        dbname=config.postgres_db,
        user=config.postgres_user,
        password=config.postgres_password
    )
    return conn

def create_building(conn, building_num):
    building_id = f"building_{building_num:02}"
    building_name = f"Building {building_num:02}"
    query = sql.SQL("INSERT INTO {table} (id, name) VALUES (%s, %s)")
    with conn.cursor() as cursor:
        cursor.execute(query.format(table=sql.Identifier('Building')), (building_id, building_name))
    conn.commit()
    return building_id

def create_floor(conn, building_id, floor_num):
    floor_id = f"floor_{building_id[-2:]}_{floor_num:02}"
    floor_name = f"Floor {floor_num:02}"
    query = sql.SQL("INSERT INTO {table} (id, name, building_id) VALUES (%s, %s, %s)")
    with conn.cursor() as cursor:
        cursor.execute(query.format(table=sql.Identifier('Floor')), (floor_id, floor_name, building_id))
    conn.commit()
    return floor_id

def create_room(conn, floor_id, room_num):
    room_id = f"room_{floor_id[-5:]}_{room_num:02}"
    room_name = f"Room {room_num:02}"
    query = sql.SQL("""
    INSERT INTO {table} (id, name, temperature, humidity, co2, floor_id)
    VALUES (%s, %s, %s, %s, %s, %s)
    """)
    with conn.cursor() as cursor:
        cursor.execute(query.format(table=sql.Identifier('Room')), (room_id, room_name, config.defaultRoomTemp, config.defaultRoomHumidity, config.defaultRoomCo2, floor_id))
    conn.commit()

def main():
    conn = connect_to_db()
    try:
        for building_num in range(1, config.buildingCount + 1):
            building_id = create_building(conn, building_num)
            for floor_num in range(1, config.floorCount + 1):
                floor_id = create_floor(conn, building_id, floor_num)
                for room_num in range(1, config.roomCount + 1):
                    create_room(conn, floor_id, room_num)
    finally:
        conn.close()

if __name__ == "__main__":
    main()