from typing import Any, Dict, Literal, Optional

from pydantic import BaseModel, Field

# TODO: replace these with Dapr Agents extension models

# Unpacked event models
class Source(BaseModel):
    """Source information for a Drasi event."""
    queryId: str = Field(description="The query ID that generated this event")
    ts_ms: int = Field(description="Source timestamp in milliseconds")


class Payload(BaseModel):
    """Payload containing the event data."""
    source: Source = Field(description="Source information")
    after: Optional[Dict[str, Any]] = Field(
        default=None, description="Record state after the change"
    )
    before: Optional[Dict[str, Any]] = Field(
        default=None, description="Record state before the change"
    )


class DrasiUnpackedEvent(BaseModel):
    """Drasi unpacked event model for CDC (Change Data Capture) events."""
    op: Literal["i", "u", "d", "x"] = Field(
        description="Operation type: i (insert), u (update), d (delete), x (control)"
    )
    ts_ms: int = Field(description="Event timestamp in milliseconds")
    seq: int = Field(description="Event sequence number")
    payload: Payload = Field(description="Event payload containing source and data")


class LowStockEvent(BaseModel):
    """Low stock event representing products below threshold."""
    productId: int = Field(description="Unique product identifier")
    productName: str = Field(description="Name of the product")
    productDescription: str = Field(description="Description of the product")
    stockOnHand: int = Field(description="Current quantity in stock")
    lowStockThreshold: int = Field(description="Threshold below which stock is considered low")
