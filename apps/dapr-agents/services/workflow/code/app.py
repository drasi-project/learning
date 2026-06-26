from __future__ import annotations

import asyncio
import logging
from typing import Any

from dapr_agents import AgentRunner
from dapr_agents.agents.schemas import TriggerAction
from dapr_agents.workflow.utils.core import wait_for_shutdown
from dapr_agents.ext.drasi import drasi_trigger

from agent import make_agent
from models import DrasiUnpackedEvent


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


DRASI_OP_TO_DESCRIPTION = {
    "i": "insert",
    "u": "update",
    "d": "delete",
    "x": "control",
}


def make_task(event: DrasiUnpackedEvent, ctx: Any) -> TriggerAction:
    return TriggerAction(
        task=(
            f"Create a summary of the changes in this {DRASI_OP_TO_DESCRIPTION[event.op]} event for the '{event.payload.source.queryId}' query.\n"
            f"This is the state before the change: {event.payload.before}.\n"
            f"This is the state after the change: {event.payload.after}.\n"
        )
    )


async def main() -> None:
    agent = make_agent()

    # Register Drasi query subscriptions
    drasi_trigger(agent, query_id="critical-stock-event-query", task_mapper=make_task)
    drasi_trigger(agent, query_id="low-stock-event-query", task_mapper=make_task)
    
    runner = AgentRunner()
    try:
        runner.subscribe(agent)
        await wait_for_shutdown()
    finally:
        runner.shutdown(agent)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
