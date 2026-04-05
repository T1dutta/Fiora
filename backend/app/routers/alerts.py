from typing import Annotated

from fastapi import APIRouter, Depends, Query

from app.db import get_db
from app.deps import get_current_user_id
from app.models.common import serialize_doc

router = APIRouter()


@router.get("")
async def list_alerts(
    user_id: Annotated[str, Depends(get_current_user_id)],
    status_filter: str | None = Query(default=None, alias="status"),
    limit: int = Query(default=50, ge=1, le=200),
):
    """Return alerts for the current user (newest first)."""
    db = get_db()
    q: dict = {"user_id": user_id}
    if status_filter:
        q["status"] = status_filter
    cur = db.alerts.find(q).sort("created_at", -1).limit(limit)
    return {"items": [serialize_doc(d) async for d in cur]}
