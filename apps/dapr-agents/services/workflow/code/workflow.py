from __future__ import annotations
import os

from dapr.ext.workflow import DaprWorkflowContext

from dapr_agents.llm.dapr import DaprChatClient
from dapr_agents.workflow.decorators.decorators import message_router

from models import DrasiUnpackedEvent, LowStockEvent

# Initialize the LLM client and workflow runtime
llm = DaprChatClient(component_name="openai")

PUBSUB_NAME = os.getenv("DAPR_PUBSUB_NAME", "workflow-pubsub")

@message_router(
    pubsub=PUBSUB_NAME, topic="low-stock-events", message_model=DrasiUnpackedEvent
)
def low_stock_order_workflow(ctx: DaprWorkflowContext, wf_input: dict) -> str:
    """Order a random amount of stock for a low stock product."""
    op = wf_input["op"]

    if op == "i":
        event = LowStockEvent.model_validate(wf_input["payload"]["after"])
        
        order_count = yield ctx.call_activity(create_order_count, input={"current_stock_count": event.stockOnHand, "multiplier": 1})
        order = yield ctx.call_activity(create_order, input={"item": event.model_dump(), "order_count": order_count})

        return order

    return "Low stock event received, no action needed"


@message_router(
    pubsub=PUBSUB_NAME, topic="critical-stock-events", message_model=DrasiUnpackedEvent
)
def critical_stock_order_workflow(ctx: DaprWorkflowContext, wf_input: dict) -> str:
    """Order a fixed amount of stock for a critical stock product."""
    op = wf_input["op"]

    if op == "i":
        event = LowStockEvent.model_validate(wf_input["payload"]["after"])

        order_count = yield ctx.call_activity(create_order_count, input={"current_stock_count": event.stockOnHand, "multiplier": 10})
        order = yield ctx.call_activity(create_order, input={"item": event.model_dump(), "order_count": order_count})

        return order

    return "Critical stock event received, no action needed"


def create_order_count(ctx, input: dict) -> int:
    """Order a random amount of stock based on the current stock count and a multiplier."""
    import random

    # Ensure order count is always positive
    current_stock_count = max(int(input["current_stock_count"]), 1)
    multiplier = int(input["multiplier"])

    return random.randint(1, 10) * multiplier * current_stock_count


def create_order(ctx, input: dict) -> str:
    item = input["item"]
    order_count = int(input["order_count"])

    return str(
        llm.generate(
            messages=(
                f"Create an inventory order of {order_count} units for the item:\n{item}.\n"
                f"Output the item ID, item name, item description, the previous item count, and the new item count after the units are added in the format:\n"
                f"Item ID: <item_id>\nItem Name: <item_name>\nItem Description: <item_description>\nPrevious count: <previous_count>\nNew count: <new_count>\n"
            )
        )
    )
