from datetime import date, datetime, timezone
from typing import Annotated, Any

from fastapi import APIRouter, Depends

from app.db import get_db
from app.deps import get_current_user_id
from app.models.common import serialize_doc
from app.models.schemas import PeriodDayLogBody, PeriodEntryCreate
from app.services.cycle_prediction import predict_next_period
from app.services.period_pipeline import evaluate_and_maybe_alert

router = APIRouter()


def _as_date(d: date | datetime | None) -> date | None:
    if d is None:
        return None
    if isinstance(d, datetime):
        return d.date()
    if isinstance(d, date):
        return d
    return None


def _map_flow_to_intensity(flow_label: str) -> str | None:
    """Map UI labels like 'Light' to stored enum."""
    key = flow_label.strip().lower()
    if key in ("none", ""):
        return None
    if key in ("light", "medium", "heavy"):
        return key
    return None


async def _save_period_entry(
    user_id: str,
    doc: dict[str, Any],
) -> tuple[dict[str, Any], dict[str, Any] | None]:
    """Insert period log and run severe-cramps pipeline."""
    db = get_db()
    res = await db.period_entries.insert_one(doc)
    doc["_id"] = res.inserted_id
    serialized = serialize_doc(doc)
    # Step: evaluate rules vs profile + wearables; may create alert row.
    severe = await evaluate_and_maybe_alert(db, user_id, doc)
    return serialized, severe


@router.post("")
async def post_period_day(
    user_id: Annotated[str, Depends(get_current_user_id)],
    body: PeriodDayLogBody,
):
    """
    POST /periods — store daily log (date, flow, symptoms, pain_level) and evaluate alerts.
    """
    now = datetime.now(timezone.utc)
    flow_intensity = _map_flow_to_intensity(body.flow)
    doc = {
        "user_id": user_id,
        "start_date": body.date,
        "flow": body.flow.strip(),
        "flow_intensity": flow_intensity,
        "symptoms": body.symptoms,
        "pain_level": body.pain_level,
        "created_at": now,
    }
    entry, severe = await _save_period_entry(user_id, doc)
    out: dict[str, Any] = {"entry": entry, "severe_cramps": severe}
    return out


@router.post("/entries")
async def add_entry(user_id: Annotated[str, Depends(get_current_user_id)], body: PeriodEntryCreate):
    """Legacy path: same storage + detection (backward compatible)."""
    now = datetime.now(timezone.utc)
    doc = {
        "user_id": user_id,
        "start_date": body.start_date,
        "end_date": body.end_date,
        "flow_intensity": body.flow_intensity,
        "flow": body.flow,
        "symptoms": body.symptoms,
        "pain_level": body.pain_level,
        "notes": body.notes,
        "created_at": now,
    }
    entry, severe = await _save_period_entry(user_id, doc)
    out: dict[str, Any] = {"entry": entry}
    if severe:
        out["severe_cramps"] = severe
    return out


@router.get("/entries")
async def list_entries(user_id: Annotated[str, Depends(get_current_user_id)], limit: int = 50):
    db = get_db()
    cur = db.period_entries.find({"user_id": user_id}).sort("start_date", -1).limit(limit)
    items = [serialize_doc(d) async for d in cur]
    return {"items": items}


@router.get("/prediction")
async def cycle_prediction(user_id: Annotated[str, Depends(get_current_user_id)]):
    db = get_db()
    cur = db.period_entries.find({"user_id": user_id}).sort("start_date", -1).limit(24)
    starts: list[date] = []
    async for d in cur:
        sd = _as_date(d.get("start_date"))
        if sd is not None:
            starts.append(sd)
    pred = predict_next_period(starts)
    pred_doc = {
        "user_id": user_id,
        "generated_at": datetime.now(timezone.utc),
        **pred,
    }
    await db.cycle_predictions.insert_one(pred_doc)
    return pred
