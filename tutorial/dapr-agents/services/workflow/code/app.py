#
# Copyright 2026 The Dapr Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from __future__ import annotations

import asyncio
import logging
import signal

import dapr.ext.workflow as wf
from dapr.clients import DaprClient
from workflow import (
    create_order_count,
    create_order,
    critical_stock_order_workflow,
    low_stock_order_workflow,
)

from dapr_agents.workflow.utils.registration import register_message_routes


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def _wait_for_shutdown() -> None:
    """Block until Ctrl+C or SIGTERM."""
    loop = asyncio.get_running_loop()
    stop = asyncio.Event()

    def _set_stop(*_: object) -> None:
        stop.set()

    try:
        loop.add_signal_handler(signal.SIGINT, _set_stop)
        loop.add_signal_handler(signal.SIGTERM, _set_stop)
    except NotImplementedError:
        # Windows fallback
        signal.signal(signal.SIGINT, lambda *_: _set_stop())
        signal.signal(signal.SIGTERM, lambda *_: _set_stop())

    await stop.wait()


async def main() -> None:
    runtime = wf.WorkflowRuntime()

    runtime.register_workflow(low_stock_order_workflow)
    runtime.register_workflow(critical_stock_order_workflow)
    runtime.register_activity(create_order_count)
    runtime.register_activity(create_order)

    runtime.start()

    try:
        with DaprClient() as client:
            # Wire streaming subscriptions for our router(s)
            closers = register_message_routes(
                targets=[low_stock_order_workflow, critical_stock_order_workflow],
                dapr_client=client,
            )

            try:
                await _wait_for_shutdown()
            finally:
                for close in closers:
                    try:
                        close()
                    except Exception:
                        logger.exception("Error while closing subscription")
    finally:
        runtime.shutdown()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
