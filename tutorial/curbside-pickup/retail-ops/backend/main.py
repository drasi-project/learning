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
Entry point for the Retail Operations API backend.
"""

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from routers import orders
from database import Base, engine
import os

# Initialize the database
Base.metadata.create_all(bind=engine)

# Create the FastAPI application
# Get root_path from environment variable for proper routing behind reverse proxy
root_path = os.getenv("ROOT_PATH", "")
app = FastAPI(
    title="Retail Operations API", 
    version="1.0.0",
    root_path=root_path
)

# Include the orders router
app.include_router(orders.router, prefix="/orders", tags=["orders"])

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins, change to specific origins in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve static files if they exist
static_dir = os.path.join(os.path.dirname(__file__), "static")
if os.path.exists(static_dir):
    # Mount static files at root, but handle index.html specially
    app.mount("/assets", StaticFiles(directory=static_dir), name="static")
    
    @app.get("/", summary="Retail Ops Frontend", description="Serves the React frontend application for managing customer orders")
    async def serve_frontend():
        """Serve the React app."""
        index_path = os.path.join(static_dir, "index.html")
        if os.path.exists(index_path):
            return FileResponse(index_path)
        return {"message": "Retail Operations API - Frontend not found"}
else:
    @app.get("/")
    def root():
        """Root endpoint when no static files are present."""
        return {"message": "Welcome to the Retail Operations API!"}