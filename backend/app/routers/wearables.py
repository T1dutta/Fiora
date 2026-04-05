from datetime import datetime, timezone
import random
from typing import Annotated

from fastapi import APIRouter, Depends

from app.db import get_db
from app.deps import get_current_user_id
from app.models.common import serialize_doc
from app.models.schemas import WearableIngest

router = APIRouter()


@router.post("/sync")
async def sync_metric(user_id: Annotated[str, Depends(get_current_user_id)], body: WearableIngest):
    db = get_db()
    doc = {
        "user_id": user_id,
        "source": body.source,
        "metric_type": body.metric_type,
        "value": body.value,
        "unit": body.unit,
        "recorded_at": body.recorded_at,
        "metadata": body.metadata or {},
        "ingested_at": datetime.now(timezone.utc),
    }
    res = await db.wearable_events.insert_one(doc)
    doc["_id"] = res.inserted_id
    return serialize_doc(doc)


@router.post("/sync-mock")
async def sync_mock_data(user_id: Annotated[str, Depends(get_current_user_id)]):
    """Generates realistic mock smartwatch data and saves it instantly."""
    db = get_db()
    now = datetime.now(timezone.utc)
    
    # 1. Heart Rate
    heart_rate = random.randint(62, 108)
    hr_doc = {
        "user_id": user_id,
        "source": "Apple Watch Simulator",
        "metric_type": "heart_rate",
        "value": heart_rate,
        "unit": "bpm",
        "recorded_at": now.isoformat(),
        "ingested_at": now,
    }
    await db.wearable_events.insert_one(hr_doc)
    
    # 2. Sleep
    sleep_duration_hours = round(random.uniform(5.5, 8.5), 1)
    sleep_doc = {
        "user_id": user_id,
        "source": "Apple Watch Simulator",
        "metric_type": "sleep_duration",
        "value": sleep_duration_hours,
        "unit": "hours",
        "recorded_at": now.isoformat(),
        "ingested_at": now,
    }
    await db.wearable_events.insert_one(sleep_doc)
    
    # 3. Steps
    steps = random.randint(3500, 12500)
    steps_doc = {
        "user_id": user_id,
        "source": "Apple Watch Simulator",
        "metric_type": "steps",
        "value": float(steps),
        "unit": "count",
        "recorded_at": now.isoformat(),
        "ingested_at": now,
    }
    await db.wearable_events.insert_one(steps_doc)
    
    return {
        "status": "success",
        "synced_metrics": ["heart_rate", "sleep_duration", "steps"],
        "values": {
            "heart_rate": heart_rate,
            "sleep_duration": sleep_duration_hours,
            "steps": steps
        }
    }


@router.get("/events")
async def list_events(user_id: Annotated[str, Depends(get_current_user_id)], limit: int = 100):
    db = get_db()
    cur = db.wearable_events.find({"user_id": user_id}).sort("recorded_at", -1).limit(limit)
    return {"items": [serialize_doc(d) async for d in cur]}
