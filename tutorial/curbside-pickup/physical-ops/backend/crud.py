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

"""
Implements CRUD operations for database interactions.
"""

from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from models import Vehicle
from schemas import VehicleCreate, VehicleUpdate

def get_vehicle(db: Session, plate: str):
    return db.query(Vehicle).filter(Vehicle.plate == plate).first()

def get_vehicles(db: Session, skip: int = 0, limit: int = 100):
    return db.query(Vehicle).offset(skip).limit(limit).all()

def create_vehicle(db: Session, vehicle: VehicleCreate):
    db_vehicle = Vehicle(**vehicle.dict())
    try:
        db.add(db_vehicle)
        db.commit()
        db.refresh(db_vehicle)
        return db_vehicle
    except IntegrityError as e:
        db.rollback()
        if e.orig.args[0] == 1062:
            raise HTTPException(
                status_code=422,
                detail=[{
                    "loc": ["body", "plate"],
                    "msg": "A vehicle with this plate already exists",
                    "type": "value_error.duplicate"
                }]
            )
        raise HTTPException(
            status_code=422,
            detail="Database integrity error occurred"
        )

def update_vehicle(db: Session, plate: str, update_data: VehicleUpdate):
    db_vehicle = get_vehicle(db, plate)
    if not db_vehicle:
        raise HTTPException(
            status_code=404,
            detail="Vehicle not found"
        )
    try:
        for key, value in update_data.dict(exclude_unset=True).items():
            setattr(db_vehicle, key, value)
        db.commit()
        db.refresh(db_vehicle)
        return db_vehicle
    except:
        db.rollback()
        raise HTTPException(
            status_code=422,
            detail="Database integrity error occurred"
        )

def delete_vehicle(db: Session, plate: str):
    db_vehicle = get_vehicle(db, plate)
    if db_vehicle:
        db.delete(db_vehicle)
        db.commit()
    return db_vehicle
