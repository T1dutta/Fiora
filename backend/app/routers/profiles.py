from datetime import datetime, timezone
from typing import Annotated

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException

from app.db import get_db
from app.deps import get_current_user_id
from app.models.common import serialize_doc
from app.models.schemas import ProfileUpdate

router = APIRouter()


@router.get("/me")
async def get_me(user_id: Annotated[str, Depends(get_current_user_id)]):
    db = get_db()
    user = await db.users.find_one({"_id": ObjectId(user_id)})
    profile = await db.profiles.find_one({"user_id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    safe_user = {k: v for k, v in user.items() if k != "password_hash"}
    return {
        "user": serialize_doc(safe_user),
        "profile": serialize_doc(profile) if profile else {"user_id": user_id, "partners": []},
    }


@router.patch("/me")
async def patch_me(user_id: Annotated[str, Depends(get_current_user_id)], body: ProfileUpdate):
    db = get_db()
    ufields: dict = {}
    if body.display_name is not None:
        ufields["display_name"] = body.display_name
    if ufields:
        await db.users.update_one({"_id": ObjectId(user_id)}, {"$set": ufields})

    pset: dict = {}
    if body.bio is not None:
        pset["bio"] = body.bio
    if body.partners is not None:
        pset["partners"] = [p.model_dump() for p in body.partners]
    pset["updated_at"] = datetime.now(timezone.utc)
    await db.profiles.update_one(
        {"user_id": user_id},
        {"$set": pset, "$setOnInsert": {"user_id": user_id}},
        upsert=True,
    )
    return {"ok": True}
