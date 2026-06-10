from __future__ import annotations

import asyncio
import logging

from dapr_agents import AgentRunner
from dapr_agents.agents.schemas import TriggerAction
from dapr_agents.workflow.utils.core import wait_for_shutdown
from dapr_agents.ext.drasi import drasi_trigger

from agent import make_agent
from models import DrasiUnpackedEvent

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


_DRASI_OP_TO_DESCRIPTION = {
    "i": "insert",
    "u": "update",
    "d": "delete",
    "x": "control",
}


def make_task(event: DrasiUnpackedEvent) -> TriggerAction:
    return TriggerAction(
        task=(
            f"Create a summary of the changes in this {_DRASI_OP_TO_DESCRIPTION[event.op]} event for the '{event.payload.source.queryId}' query.\n"
            f"This is the state before the change: {event.payload.before}.\n"
            f"This is the state after the change: {event.payload.after}.\n"
        )
    )


async def main() -> None:
    agent = make_agent()

    # Add Drasi CDC source
    drasi_trigger(agent, mapper=make_task)

    runner = AgentRunner()
    try:
        # Allow the agent to react to Drasi events 
        runner.subscribe(agent)
        await wait_for_shutdown()
    finally:
        runner.shutdown(agent)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
