# Copyright 2025 The Drasi Authors.
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

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from sqlalchemy import Column, String, Integer, ForeignKey
from contextlib import contextmanager
from typing import List, Optional
from pydantic import BaseModel
import os
from dotenv import load_dotenv

load_dotenv()

# Database setup
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://test:test@localhost:5432/building-comfort-db')
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Models
class Building(Base):
    __tablename__ = 'Building'
    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    floors = relationship('Floor', back_populates='building', cascade="all, delete-orphan")

class Floor(Base):
    __tablename__ = 'Floor'
    id = Column(String, primary_key=True)
    building_id = Column(String, ForeignKey('Building.id'), nullable=False)
    name = Column(String, nullable=False)
    building = relationship('Building', back_populates='floors')
    rooms = relationship('Room', back_populates='floor', cascade="all, delete-orphan")

class Room(Base):
    __tablename__ = 'Room'
    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    temperature = Column(Integer)
    humidity = Column(Integer)
    co2 = Column(Integer)
    floor_id = Column(String, ForeignKey('Floor.id'), nullable=False)
    floor = relationship('Floor', back_populates='rooms')

# Pydantic models
class RoomResponse(BaseModel):
    id: str
    floorId: str
    name: str
    temperature: int
    humidity: int
    co2: int

    class Config:
        orm_mode = True

class FloorResponse(BaseModel):
    id: str
    buildingId: str
    name: str
    rooms: Optional[List[RoomResponse]] = None

    class Config:
        orm_mode = True

class BuildingResponse(BaseModel):
    id: str
    name: str
    floors: Optional[List[FloorResponse]] = None

    class Config:
        orm_mode = True

class SensorUpdate(BaseModel):
    value: int

class SensorUpdateResponse(BaseModel):
    roomId: str
    floorId: str
    buildingId: str
    temperature: int
    humidity: int
    co2: int

# Create FastAPI app
# Get root_path from environment variable for proper routing behind reverse proxy
root_path = os.getenv("ROOT_PATH", "")
app = FastAPI(
    title="Building Comfort API", 
    version="1.0.0",
    root_path=root_path,
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database dependency
@contextmanager
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Helper functions
def get_room_data(room: Room) -> dict:
    return {
        'id': room.id,
        'floorId': room.floor_id,
        'name': room.name,
        'temperature': room.temperature,
        'humidity': room.humidity,
        'co2': room.co2
    }

def get_floor_data(floor: Floor, include_rooms: bool = False) -> dict:
    data = {
        'id': floor.id,
        'buildingId': floor.building_id,
        'name': floor.name,
    }
    if include_rooms:
        data['rooms'] = [get_room_data(room) for room in floor.rooms]
    return data

def get_building_data(building: Building, include_floors: bool = False, include_rooms: bool = False) -> dict:
    data = {
        'id': building.id,
        'name': building.name,
    }
    if include_floors:
        data['floors'] = [get_floor_data(floor, include_rooms) for floor in building.floors]
    return data

# API Routes
@app.get("/api/buildings", response_model=List[BuildingResponse])
def get_buildings(
    includeFloors: bool = Query(False, alias="includeFloors"),
    includeRooms: bool = Query(False, alias="includeRooms")
):
    with get_db() as db:
        buildings = db.query(Building).all()
        return [get_building_data(b, includeFloors, includeRooms) for b in buildings]

@app.get("/api/buildings/{bid}", response_model=BuildingResponse)
def get_building(
    bid: str,
    includeFloors: bool = Query(False, alias="includeFloors"),
    includeRooms: bool = Query(False, alias="includeRooms")
):
    with get_db() as db:
        building = db.query(Building).filter(Building.id == bid).first()
        if not building:
            raise HTTPException(status_code=404, detail="Building not found")
        return get_building_data(building, includeFloors, includeRooms)

@app.get("/api/buildings/{bid}/floors", response_model=List[FloorResponse])
def get_floors(
    bid: str,
    includeRooms: bool = Query(False, alias="includeRooms")
):
    with get_db() as db:
        floors = db.query(Floor).filter(Floor.building_id == bid).all()
        return [get_floor_data(f, includeRooms) for f in floors]

@app.get("/api/buildings/{bid}/floors/{fid}", response_model=FloorResponse)
def get_floor(
    bid: str,
    fid: str,
    includeRooms: bool = Query(False, alias="includeRooms")
):
    with get_db() as db:
        floor = db.query(Floor).filter(Floor.building_id == bid, Floor.id == fid).first()
        if not floor:
            raise HTTPException(status_code=404, detail="Floor not found")
        return get_floor_data(floor, includeRooms)

@app.get("/api/buildings/{bid}/floors/{fid}/rooms", response_model=List[RoomResponse])
def get_rooms(bid: str, fid: str):
    with get_db() as db:
        rooms = db.query(Room).filter(Room.floor_id == fid).all()
        return [get_room_data(r) for r in rooms]

@app.get("/api/buildings/{bid}/floors/{fid}/rooms/{rid}", response_model=RoomResponse)
def get_room(bid: str, fid: str, rid: str):
    with get_db() as db:
        room = db.query(Room).filter(Room.floor_id == fid, Room.id == rid).first()
        if not room:
            raise HTTPException(status_code=404, detail="Room not found")
        return get_room_data(room)

@app.post("/api/buildings/{bid}/floors/{fid}/rooms/{rid}/sensors/{sid}", response_model=SensorUpdateResponse)
def update_sensor_data(bid: str, fid: str, rid: str, sid: str, sensor_update: SensorUpdate):
    with get_db() as db:
        room = db.query(Room).filter(Room.id == rid, Room.floor_id == fid).first()
        if not room:
            raise HTTPException(status_code=404, detail="Room not found")
        
        if sid == 'temperature':
            room.temperature = sensor_update.value
        elif sid == 'humidity':
            room.humidity = sensor_update.value
        elif sid == 'co2':
            room.co2 = sensor_update.value
        else:
            raise HTTPException(status_code=400, detail="Invalid sensor ID")
        
        db.commit()
        db.refresh(room)
        
        return SensorUpdateResponse(
            roomId=rid,
            floorId=fid,
            buildingId=bid,
            temperature=room.temperature,
            humidity=room.humidity,
            co2=room.co2
        )

# Serve static files if they exist
static_dir = os.path.join(os.path.dirname(__file__), "static")
if os.path.exists(static_dir):
    # Mount static files at root, but handle index.html specially
    app.mount("/assets", StaticFiles(directory=static_dir), name="static")
    
    @app.get("/", summary="Control Panel Frontend", description="Serves the React frontend application")
    async def serve_frontend():
        """Serve the React app."""
        index_path = os.path.join(static_dir, "index.html")
        if os.path.exists(index_path):
            return FileResponse(index_path)
        return {"message": "Building Comfort Control Panel - Frontend not found"}
else:
    @app.get("/")
    def root():
        """Root endpoint when no static files are present."""
        return {"message": "Welcome to the Building Comfort API!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv('PORT', 5000)))