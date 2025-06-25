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
Defines Pydantic models for request and response validation.
"""

from enum import Enum
from pydantic import BaseModel, Field
from typing import Optional

class LocationEnum(str, Enum):
    PARKING = "Parking"
    CURBSIDE = "Curbside"

class VehicleBase(BaseModel):
    plate: str = Field(..., title="License Plate", max_length=20)
    make: Optional[str] = Field(None, title="Vehicle Manufacturer", max_length=50)
    model: Optional[str] = Field(None, title="Vehicle Model", max_length=50)
    color: Optional[str] = Field(None, title="Vehicle Color", max_length=30)
    location: LocationEnum = Field(..., title="Vehicle Location")

class VehicleCreate(VehicleBase):
    pass

class VehicleUpdate(BaseModel):
    location: str = Field(..., title="Updated Location", max_length=30)

class VehicleResponse(VehicleBase):
    class Config:
        from_attributes = True
