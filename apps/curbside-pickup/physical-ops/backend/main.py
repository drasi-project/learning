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
Entry point for the Physical Operations FastAPI application.
"""

from fastapi import FastAPI
from routers import vehicles
from database import Base, engine
from fastapi.middleware.cors import CORSMiddleware

# Initialize the database
Base.metadata.create_all(bind=engine)

# Create the FastAPI application
app = FastAPI(title="Physical Operations API", version="1.0.0")

# Include routers
app.include_router(vehicles.router, prefix="/vehicles", tags=["vehicles"])

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins, change to specific origins in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    """Root endpoint."""
    return {"message": "Welcome to the Physical Operations API!"}