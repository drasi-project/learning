import os

from dapr_agents import DurableAgent, DaprChatClient
from dapr_agents.agents.configs import (
    AgentExecutionConfig,
    AgentMemoryConfig,
    AgentRegistryConfig,
    AgentStateConfig,
    AgentPubSubConfig,
)
from dapr_agents.memory import ConversationDaprStateMemory
from dapr_agents.storage.daprstores.stateservice import StateStoreService

CONVERSATION_NAME = os.getenv("DAPR_CONVERSATION_NAME", "workflow-openai")
PUBSUB_NAME = os.getenv("DAPR_PUBSUB_NAME", "workflow-pubsub")
MEMORY_STORE_NAME = os.getenv("DAPR_MEMORY_STORE_NAME", "workflow-memory")
STATE_STORE_NAME = os.getenv("DAPR_STATE_STORE_NAME", "workflow-store")
REGISTRY_STORE_NAME = os.getenv("DAPR_REGISTRY_STORE_NAME", "workflow-registry")

INSTRUCTIONS = [
    "You are an expert inventory replenishment and procurement assistant.",
    "You operate in an event-driven environment where stock-related events trigger your behavior.",
    "Your primary responsibility is to generate accurate, policy-compliant purchase orders (POs) in response to inventory stock events.",
    "You receive events indicating low stock levels or critical stock levels for products, and you must determine the appropriate quantity to order based on the event details and any relevant business rules.",
    "For low stock events, you should order a quantity that is sufficient to replenish the stock without overstocking, taking into account the current stock level and a reasonable multiplier.",
    "For critical stock events, you should order a larger quantity to quickly replenish the stock, using a higher multiplier to ensure that the stock level is restored to a safe threshold.",
]


def make_agent() -> DurableAgent:
    return DurableAgent(
        name="OrderAgent",
        role="Expert procurement assistant capable of reacting to stock events",
        goal="Create purchase orders for stock based on stock events.",
        instructions=INSTRUCTIONS,
        llm=DaprChatClient(component_name=CONVERSATION_NAME),
        memory=AgentMemoryConfig(
            store=ConversationDaprStateMemory(store_name=MEMORY_STORE_NAME),
        ),
        state=AgentStateConfig(
            store=StateStoreService(store_name=STATE_STORE_NAME),
        ),
        registry=AgentRegistryConfig(
            store=StateStoreService(store_name=REGISTRY_STORE_NAME),
            team_name="default",
        ),
        pubsub=AgentPubSubConfig(
            pubsub_name=PUBSUB_NAME,
            agent_topic="order-agent-topic",
            broadcast_topic="order-agent-topic", # Why does it only work when broadcast topic is included
        ),
        execution=AgentExecutionConfig(max_iterations=1),
    )