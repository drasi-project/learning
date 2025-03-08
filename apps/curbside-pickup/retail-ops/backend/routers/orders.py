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

'''
Routes for managing orders.
'''

from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from models import Order
from sqlalchemy.orm import Session
from database import get_db
from schemas import OrderCreate, OrderResponse
from crud import create_order, get_order_by_id, update_order

router = APIRouter()

@router.post("/", response_model=OrderResponse)
def create_new_order(order: OrderCreate, db: Session = Depends(get_db)):
    return create_order(db, order)

@router.get("/", response_model=list[OrderResponse])
def list_orders(status: Optional[str] = None, db: Session = Depends(get_db)):
    """
    List orders with optional filtering by status.
    """
    if status:
        if status not in ["preparing", "ready"]:
            raise HTTPException(status_code=400, detail="Invalid status value")
        return db.query(Order).filter(Order.status == status).all()
    return db.query(Order).all()

@router.get("/{order_id}", response_model=OrderResponse)
def retrieve_order(order_id: int, db: Session = Depends(get_db)):
    order = get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@router.patch("/{order_id}/status", response_model=OrderResponse)
def modify_order_status(order_id: int, status: str, db: Session = Depends(get_db)):
    if status not in ["preparing", "ready"]:
        raise HTTPException(status_code=400, detail="Invalid status value")
    order = update_order(db, order_id, status)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order
