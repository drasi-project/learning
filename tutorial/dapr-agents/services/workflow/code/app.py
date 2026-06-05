from __future__ import annotations

import asyncio
import logging

from dapr_agents import AgentRunner
from dapr_agents.workflow.utils.core import wait_for_shutdown
from dapr_agents.ext.drasi import drasi_trigger

from agent import make_agent


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def main() -> None:
    agent = make_agent()

    # Add Drasi CDC source
    agent.add_activation(drasi_trigger)

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
