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
Defines SQLAlchemy models for database tables.
"""

from sqlalchemy import Column, String, Enum
import uuid
from database import Base

class Vehicle(Base):
    __tablename__ = "vehicles"

    plate = Column(String(20), primary_key=True, index=True)
    make = Column(String(50), nullable=True)
    model = Column(String(50), nullable=True)
    color = Column(String(30), nullable=True)
    location = Column(Enum("Parking", "Curbside"), nullable=False, default="Parking")
