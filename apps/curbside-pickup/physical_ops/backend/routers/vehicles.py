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
Defines route handlers for vehicle-related operations.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from crud import get_vehicle, get_vehicles, create_vehicle, update_vehicle, delete_vehicle
from schemas import VehicleCreate, VehicleUpdate, VehicleResponse

router = APIRouter()

@router.get("/", response_model=List[VehicleResponse])
def read_vehicles(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Fetch a list of all vehicles."""
    return get_vehicles(db, skip=skip, limit=limit)

@router.get("/{plate}", response_model=VehicleResponse)
def read_vehicle(plate: str, db: Session = Depends(get_db)):
    """Fetch a vehicle by its license plate."""
    vehicle = get_vehicle(db, plate)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle

@router.post("/", response_model=VehicleResponse)
def create_new_vehicle(vehicle: VehicleCreate, db: Session = Depends(get_db)):
    """Create a new vehicle."""
    return create_vehicle(db, vehicle)

@router.put("/{plate}", response_model=VehicleResponse)
def update_vehicle_location(plate: str, update_data: VehicleUpdate, db: Session = Depends(get_db)):
    """Update the location of an existing vehicle."""
    vehicle = update_vehicle(db, plate, update_data)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle

@router.delete("/{plate}", response_model=VehicleResponse)
def delete_vehicle_by_plate(plate: str, db: Session = Depends(get_db)):
    """Delete a vehicle by its license plate."""
    vehicle = delete_vehicle(db, plate)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle
