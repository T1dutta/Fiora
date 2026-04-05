from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase

from app.config import settings

_client: AsyncIOMotorClient | None = None


def get_client() -> AsyncIOMotorClient:
    global _client
    if _client is None:
        _client = AsyncIOMotorClient(settings.mongodb_uri)
    return _client


def get_db() -> AsyncIOMotorDatabase:
    return get_client()[settings.mongodb_db]


async def ensure_indexes() -> None:
    db = get_db()
    await db.users.create_index("email", unique=True, sparse=True)
    await db.users.create_index("magic_public_address", sparse=True)
    await db.profiles.create_index("user_id", unique=True)
    await db.period_entries.create_index([("user_id", 1), ("start_date", -1)])
    await db.wearable_events.create_index([("user_id", 1), ("recorded_at", -1)])
    await db.points_ledger.create_index([("user_id", 1), ("created_at", -1)])
    await db.alerts.create_index([("user_id", 1), ("created_at", -1)])
    await db.alerts.create_index([("user_id", 1), ("status", 1)])
