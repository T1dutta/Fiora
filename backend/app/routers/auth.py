from datetime import datetime, timezone
from typing import Annotated

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException, Request, status

from app.db import get_db
from app.deps import get_current_user_id
from app.limiter import limiter
from app.models.schemas import LoginBody, MagicLoginBody, MagicSignupBody, RegisterBody, SignupBody, TokenResponse
from app.security import create_access_token, hash_password, verify_password
from app.services.magic_auth import validate_magic_did_token

router = APIRouter()


@router.post("/register", response_model=TokenResponse)
@limiter.limit("20/minute")
async def register(request: Request, body: RegisterBody):
    db = get_db()
    existing = await db.users.find_one({"email": body.email.lower()})
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")
    now = datetime.now(timezone.utc)
    doc = {
        "email": body.email.lower(),
        "password_hash": hash_password(body.password),
        "display_name": body.display_name,
        "created_at": now,
        "magic_public_address": None,
    }
    res = await db.users.insert_one(doc)
    uid = str(res.inserted_id)
    await db.profiles.update_one(
        {"user_id": uid},
        {"$setOnInsert": {"user_id": uid, "partners": [], "bio": None}},
        upsert=True,
    )
    token = create_access_token(uid, {"email": body.email.lower()})
    return TokenResponse(access_token=token)


@router.post("/signup", response_model=TokenResponse)
@limiter.limit("20/minute")
async def signup(request: Request, body: SignupBody):
    """
    Full signup: minimal user row + linked profile with health / emergency fields.
    """
    db = get_db()
    email_lower = body.email.lower()
    existing = await db.users.find_one({"email": email_lower})
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

    now = datetime.now(timezone.utc)
    # Step: persist auth identity only on users (no PII beyond email).
    user_doc = {
        "email": email_lower,
        "password_hash": hash_password(body.password),
        "created_at": now,
        "magic_public_address": None,
    }
    res = await db.users.insert_one(user_doc)
    uid = str(res.inserted_id)

    # Step: linked profile document for app-specific data.
    profile_doc = {
        "user_id": uid,
        "name": body.name,
        "age": body.age,
        "cycle_length": body.cycle_length,
        "avg_period_length": body.avg_period_length,
        "known_conditions": body.known_conditions,
        "emergency_contact": body.emergency_contact,
        "created_at": now,
        "partners": [],
        "bio": None,
    }
    await db.profiles.update_one(
        {"user_id": uid},
        {"$set": profile_doc},
        upsert=True,
    )

    token = create_access_token(uid, {"email": email_lower})
    return TokenResponse(access_token=token)


@router.post("/login", response_model=TokenResponse)
@limiter.limit("30/minute")
async def login(request: Request, body: LoginBody):
    db = get_db()
    user = await db.users.find_one({"email": body.email.lower()})
    if not user or not user.get("password_hash"):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    if not verify_password(body.password, user["password_hash"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    uid = str(user["_id"])
    token = create_access_token(uid, {"email": user.get("email")})
    return TokenResponse(access_token=token)


@router.post("/magic", response_model=TokenResponse)
@limiter.limit("30/minute")
async def magic_login(request: Request, body: MagicLoginBody):
    public_address = validate_magic_did_token(body.did_token)
    db = get_db()
    user = await db.users.find_one({"magic_public_address": public_address})
    now = datetime.now(timezone.utc)
    if not user:
        doc = {
            "email": None,
            "password_hash": None,
            "display_name": None,
            "created_at": now,
            "magic_public_address": public_address,
        }
        res = await db.users.insert_one(doc)
        uid = str(res.inserted_id)
        await db.profiles.update_one(
            {"user_id": uid},
            {"$setOnInsert": {"user_id": uid, "partners": [], "bio": None}},
            upsert=True,
        )
    else:
        uid = str(user["_id"])
    token = create_access_token(uid, {"magic": public_address})
    return TokenResponse(access_token=token)


@router.post("/magic_signup", response_model=TokenResponse)
@limiter.limit("20/minute")
async def magic_signup(request: Request, body: MagicSignupBody):
    """
    Registration via Magic.link.
    Flutter sends the DID token (obtained after email OTP) together with
    the full health-profile fields.  The backend:
      1. Validates the DID token using MAGIC_SECRET_KEY → gets public_address.
      2. Rejects if already registered.
      3. Creates a user document (no password stored — Magic handles auth).
      4. Creates the linked profile with all health fields.
      5. Returns a Fiora JWT.
    """
    public_address = validate_magic_did_token(body.did_token)
    db = get_db()
    now = datetime.now(timezone.utc)

    existing = await db.users.find_one({"magic_public_address": public_address})
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Magic account already registered — use /auth/magic to log in",
        )

    user_doc = {
        "email": None,
        "password_hash": None,
        "created_at": now,
        "magic_public_address": public_address,
    }
    res = await db.users.insert_one(user_doc)
    uid = str(res.inserted_id)

    profile_doc = {
        "user_id": uid,
        "name": body.name,
        "age": body.age,
        "cycle_length": body.cycle_length,
        "avg_period_length": body.avg_period_length,
        "known_conditions": body.known_conditions,
        "emergency_contact": body.emergency_contact,
        "created_at": now,
        "partners": [],
        "bio": None,
    }
    await db.profiles.update_one(
        {"user_id": uid},
        {"$set": profile_doc},
        upsert=True,
    )

    token = create_access_token(uid, {"magic": public_address})
    return TokenResponse(access_token=token)


@router.get("/me")
async def me(user_id: Annotated[str, Depends(get_current_user_id)]):
    """Current user summary (JWT)."""
    db = get_db()
    user = await db.users.find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=404, detail="Not found")
    return {
        "id": str(user["_id"]),
        "email": user.get("email"),
        "display_name": user.get("display_name"),
        "magic_public_address": user.get("magic_public_address"),
    }
