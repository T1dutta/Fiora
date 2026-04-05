"""
Post-processing after a period day log is stored: HR context, severe cramps, alerts.
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any

from motor.motor_asyncio import AsyncIOMotorDatabase

from app.services.cramps_detection import detect_severe_cramps
from app.services.notifications import log_emergency_contact_flag, send_severe_cramps_push


async def _recent_heart_rate(db: AsyncIOMotorDatabase, user_id: str) -> float | None:
    """Latest heart_rate wearable sample within the last 24 hours."""
    since = datetime.now(timezone.utc) - timedelta(hours=24)
    doc = await db.wearable_events.find_one(
        {
            "user_id": user_id,
            "metric_type": "heart_rate",
            "recorded_at": {"$gte": since},
        },
        sort=[("recorded_at", -1)],
    )
    if not doc:
        return None
    try:
        return float(doc["value"])
    except (KeyError, TypeError, ValueError):
        return None


async def _baseline_heart_rate(db: AsyncIOMotorDatabase, user_id: str) -> float | None:
    """
    Rolling average HR from wearables (last 14 days), excluding last 6 hours,
    as a simple personal baseline.
    """
    now = datetime.now(timezone.utc)
    window_start = now - timedelta(days=14)
    exclude_recent = now - timedelta(hours=6)
    pipeline = [
        {
            "$match": {
                "user_id": user_id,
                "metric_type": "heart_rate",
                "recorded_at": {"$gte": window_start, "$lt": exclude_recent},
            }
        },
        {"$group": {"_id": None, "avg": {"$avg": "$value"}}},
    ]
    cur = db.wearable_events.aggregate(pipeline)
    rows = await cur.to_list(1)
    if not rows or rows[0].get("avg") is None:
        return None
    return float(rows[0]["avg"])


async def evaluate_and_maybe_alert(
    db: AsyncIOMotorDatabase,
    user_id: str,
    entry_doc: dict[str, Any],
) -> dict[str, Any] | None:
    """
    Run severe-cramps detection; persist alert + side effects if triggered.
    Returns a dict for API response, or None if not severe.
    """
    profile = await db.profiles.find_one({"user_id": user_id})
    hr = await _recent_heart_rate(db, user_id)
    baseline = await _baseline_heart_rate(db, user_id)
    if profile and profile.get("baseline_heart_rate") is not None:
        try:
            baseline = float(profile["baseline_heart_rate"])
        except (TypeError, ValueError):
            pass

    wearable_ctx: dict[str, Any] = {}
    if hr is not None:
        wearable_ctx["heart_rate"] = hr
    if baseline is not None:
        wearable_ctx["baseline_hr"] = baseline

    detection = detect_severe_cramps(entry_doc, wearable_ctx, profile)
    if not detection["is_severe"]:
        return None

    message = (
        "Elevated pain reported that may need attention. "
        "Consider rest, comfort measures, and contact a clinician if symptoms worsen."
    )
    now = datetime.now(timezone.utc)
    alert_doc = {
        "user_id": user_id,
        "type": "SEVERE_CRAMPS",
        "message": message,
        "detail_reason": detection["reason"],
        "created_at": now,
        "status": "unread",
    }
    ins = await db.alerts.insert_one(alert_doc)
    alert_id = str(ins.inserted_id)

    await send_severe_cramps_push(
        user_id,
        "Severe cramps alert",
        message,
    )

    emergency_phone = (profile or {}).get("emergency_contact")
    if emergency_phone:
        log_emergency_contact_flag(user_id, emergency_phone, alert_id)

    return {
        "triggered": True,
        "alert_id": alert_id,
        "reason": detection["reason"],
        "message": message,
    }
