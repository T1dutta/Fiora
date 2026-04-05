from datetime import datetime, timedelta, timezone
from typing import Annotated

from fastapi import APIRouter, Depends

from app.db import get_db
from app.deps import get_current_user_id
from app.models.schemas import HealthAnalyzeBody
from app.services.fiora_ml import anomaly_score

router = APIRouter()


@router.post("/analyze")
async def analyze_health(
    user_id: Annotated[str, Depends(get_current_user_id)],
    body: HealthAnalyzeBody,
):
    db = get_db()
    since = datetime.now(timezone.utc) - timedelta(days=body.window_days)
    symptoms: list[str] = []
    async for d in db.period_entries.find(
        {"user_id": user_id, "created_at": {"$gte": since}}
    ):
        symptoms.extend(d.get("symptoms") or [])
    wearable_avg = None
    cur = db.wearable_events.find({"user_id": user_id, "ingested_at": {"$gte": since}})
    vals: list[float] = []
    async for w in cur:
        if w.get("metric_type") == "heart_rate":
            vals.append(float(w["value"]))
    if vals:
        wearable_avg = sum(vals) / len(vals)

    payload = {
        "user_id": user_id,
        "recent_symptoms": symptoms[:200],
        "wearable_avg_heart_rate": wearable_avg,
        "window_days": body.window_days,
    }
    result = await anomaly_score(payload)
    await db.health_analyses.insert_one(
        {
            "user_id": user_id,
            "created_at": datetime.now(timezone.utc),
            "input_summary": {
                "symptom_count": len(symptoms),
                "wearable_samples": len(vals),
            },
            "result": result,
        }
    )
    return result
