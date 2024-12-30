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

from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Models
class Building(db.Model):
    __tablename__ = 'Building'
    id = db.Column(db.String, primary_key=True)
    name = db.Column(db.String, nullable=False)
    floors = db.relationship('Floor', back_populates='building', cascade="all, delete-orphan")

class Floor(db.Model):
    __tablename__ = 'Floor'
    id = db.Column(db.String, primary_key=True)
    building_id = db.Column(db.String, db.ForeignKey('Building.id'), nullable=False)
    name = db.Column(db.String, nullable=False)
    building = db.relationship('Building', back_populates='floors')
    rooms = db.relationship('Room', back_populates='floor', cascade="all, delete-orphan")

class Room(db.Model):
    __tablename__ = 'Room'
    id = db.Column(db.String, primary_key=True)
    name = db.Column(db.String, nullable=False)
    temperature = db.Column(db.Integer)
    humidity = db.Column(db.Integer)
    co2 = db.Column(db.Integer)
    floor_id = db.Column(db.String, db.ForeignKey('Floor.id'), nullable=False)
    floor = db.relationship('Floor', back_populates='rooms')

# Helper functions
def get_building_by_id(bid, include_floors=False, include_rooms=False):
    building = Building.query.get(bid)
    if building:
        building_data = {
            'id': building.id,
            'name': building.name,
            'floors': [get_floor_data(floor, include_rooms) for floor in building.floors] if include_floors else None
        }
        return building_data
    return None

def get_floor_data(floor, include_rooms=False):
    return {
        'id': floor.id,
        'buildingId': floor.building_id,
        'name': floor.name,
        'rooms': [get_room_data(room) for room in floor.rooms] if include_rooms else None
    }

def get_room_data(room):
    return {
        'id': room.id,
        'floorId': room.floor_id,
        'name': room.name,
        'temperature': room.temperature,
        'humidity': room.humidity,
        'co2': room.co2
    }

# Routes
@app.route('/buildings', methods=['GET'])
def get_buildings():
    include_floors = request.args.get('includeFloors', 'false').lower() == 'true'
    include_rooms = request.args.get('includeRooms', 'false').lower() == 'true'
    buildings = Building.query.all()
    buildings_data = [get_building_by_id(building.id, include_floors, include_rooms) for building in buildings]
    return jsonify(buildings_data)

@app.route('/buildings/<bid>', methods=['GET'])
def get_building(bid):
    include_floors = request.args.get('includeFloors', 'false').lower() == 'true'
    include_rooms = request.args.get('includeRooms', 'false').lower() == 'true'
    building_data = get_building_by_id(bid, include_floors, include_rooms)
    if building_data:
        return jsonify(building_data)
    else:
        return 'Building not found', 404

@app.route('/buildings/<bid>/floors', methods=['GET'])
def get_floors(bid):
    include_rooms = request.args.get('includeRooms', 'false').lower() == 'true'
    floors = Floor.query.filter_by(building_id=bid).all()
    floors_data = [get_floor_data(floor, include_rooms) for floor in floors]
    return jsonify(floors_data)

@app.route('/buildings/<bid>/floors/<fid>', methods=['GET'])
def get_floor(bid, fid):
    include_rooms = request.args.get('includeRooms', 'false').lower() == 'true'
    floor = Floor.query.filter_by(building_id=bid, id=fid).first()
    if floor:
        return jsonify(get_floor_data(floor, include_rooms))
    else:
        return 'Floor not found', 404

@app.route('/buildings/<bid>/floors/<fid>/rooms', methods=['GET'])
def get_rooms(bid, fid):
    rooms = Room.query.filter_by(floor_id=fid).all()
    rooms_data = [get_room_data(room) for room in rooms]
    return jsonify(rooms_data)

@app.route('/buildings/<bid>/floors/<fid>/rooms/<rid>', methods=['GET'])
def get_room(bid, fid, rid):
    room = Room.query.filter_by(floor_id=fid, id=rid).first()
    if room:
        return jsonify(get_room_data(room))
    else:
        return 'Room not found', 404

@app.route('/buildings/<bid>/floors/<fid>/rooms/<rid>/sensors/<sid>', methods=['POST'])
def update_sensor_data(bid, fid, rid, sid):
    data = request.get_json()
    value = data.get('value')
    room = Room.query.filter_by(id=rid, floor_id=fid).first()
    if not room:
        return 'Room not found', 404
    
    if sid == 'temperature':
        room.temperature = value
    elif sid == 'humidity':
        room.humidity = value
    elif sid == 'co2':
        room.co2 = value
    else:
        return 'Invalid sensor ID', 400
    
    db.session.commit()

    return jsonify({
        'roomId': rid,
        'floorId': fid,
        'buildingId': bid,
        'temperature': room.temperature,
        'humidity': room.humidity,
        'co2': room.co2,
    }), 200



# Start server
if __name__ == '__main__':
    app.run(port=int(os.getenv('PORT', 58580)), debug=True)