from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException

from app.db import get_db
from app.deps import get_current_user_id
from app.models.common import serialize_doc
from app.models.schemas import PointsEarnBody, PointsRedeemBody

router = APIRouter()

# Demo catalog: map codes to discount percent (replace with commerce integration)
PRODUCTS = {
    "PADS10": {"label": "Pads bundle", "points": 500, "discount_percent": 10},
    "CUP15": {"label": "Menstrual cup", "points": 1200, "discount_percent": 15},
}


@router.get("/balance")
async def balance(user_id: Annotated[str, Depends(get_current_user_id)]):
    db = get_db()
    pipeline = [{"$match": {"user_id": user_id}}, {"$group": {"_id": None, "total": {"$sum": "$delta"}}}]
    cur = db.points_ledger.aggregate(pipeline)
    agg = await cur.to_list(1)
    total = int(agg[0]["total"]) if agg else 0
    return {"points": total}


@router.get("/ledger")
async def ledger(user_id: Annotated[str, Depends(get_current_user_id)], limit: int = 50):
    db = get_db()
    cur = db.points_ledger.find({"user_id": user_id}).sort("created_at", -1).limit(limit)
    return {"items": [serialize_doc(d) async for d in cur]}


@router.post("/earn")
async def earn_demo(user_id: Annotated[str, Depends(get_current_user_id)], body: PointsEarnBody):
    db = get_db()
    doc = {
        "user_id": user_id,
        "delta": body.delta,
        "reason": body.reason,
        "created_at": datetime.now(timezone.utc),
    }
    res = await db.points_ledger.insert_one(doc)
    doc["_id"] = res.inserted_id
    return serialize_doc(doc)


@router.post("/redeem")
async def redeem(user_id: Annotated[str, Depends(get_current_user_id)], body: PointsRedeemBody):
    product = PRODUCTS.get(body.product_code.upper())
    if not product:
        raise HTTPException(status_code=404, detail="Unknown product code")
    cost = product["points"]
    db = get_db()
    pipeline = [{"$match": {"user_id": user_id}}, {"$group": {"_id": None, "total": {"$sum": "$delta"}}}]
    cur = await db.points_ledger.aggregate(pipeline).to_list(1)
    current = int(cur[0]["total"]) if cur else 0
    if current < cost:
        raise HTTPException(status_code=400, detail="Insufficient points")
    now = datetime.now(timezone.utc)
    await db.points_ledger.insert_one(
        {
            "user_id": user_id,
            "delta": -cost,
            "reason": f"redeem:{body.product_code}",
            "created_at": now,
        }
    )
    token = f"DISCOUNT-{body.product_code.upper()}-{int(now.timestamp())}"
    return {
        "ok": True,
        "discount_token": token,
        "discount_percent": product["discount_percent"],
        "label": product["label"],
        "points_spent": cost,
    }
