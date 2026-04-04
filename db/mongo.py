from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
from datetime import datetime, timezone
import os
from dotenv import load_dotenv

load_dotenv()

_db = None
_in_memory_users = {}
_in_memory_messages = []

# Try to connect to MongoDB, fallback to in-memory if it fails
try:
    uri = os.getenv("MONGODB_URI")
    if uri:
        _client = MongoClient(uri, serverSelectionTimeoutMS=2000)
        _client.admin.command('ping') # Trigger a connection test
        _db = _client["shaktidb"]
        print("Connected to MongoDB.")
    else:
        print("MONGODB_URI not set. Using in-memory fallback database.")
except (ConnectionFailure, ServerSelectionTimeoutError, Exception) as e:
    print(f"Failed to connect to MongoDB: {e}. Using in-memory fallback database.")

def get_user(user_id: str) -> dict | None:
    if _db is not None:
        return _db.users.find_one({"user_id": user_id}, {"_id": 0})
    return _in_memory_users.get(user_id)

def save_user(user_id: str, cycle_data: dict):
    if _db is not None:
        _db.users.update_one(
            {"user_id": user_id},
            {"$set": {"user_id": user_id, "cycle_data": cycle_data,
                      "updated_at": datetime.now(timezone.utc)}},
            upsert=True,
        )
    else:
        _in_memory_users[user_id] = {
            "user_id": user_id,
            "cycle_data": cycle_data,
            "updated_at": datetime.now(timezone.utc).isoformat()
        }

def save_message(user_id: str, role: str, content: str):
    if _db is not None:
        _db.messages.insert_one({
            "user_id": user_id,
            "role": role,
            "content": content,
            "ts": datetime.now(timezone.utc),
        })
    else:
        _in_memory_messages.append({
            "user_id": user_id,
            "role": role,
            "content": content,
            "ts": datetime.now(timezone.utc).isoformat(),
        })

def get_session_messages(user_id: str, limit: int = 20) -> list:
    if _db is not None:
        cursor = _db.messages.find(
            {"user_id": user_id},
            {"_id": 0, "role": 1, "content": 1}
        ).sort("ts", -1).limit(limit)
        return list(reversed(list(cursor)))
    
    # In-memory retrieval
    msgs = [m for m in _in_memory_messages if m["user_id"] == user_id]
    # sort by ts desc
    msgs.sort(key=lambda x: x["ts"], reverse=True)
    msgs = msgs[:limit]
    # strip ts and user_id to match mongo structure
    return list(reversed([{"role": m["role"], "content": m["content"]} for m in msgs]))

_in_memory_summaries = []

def save_summary(user_id: str, summary: str):
    if _db is not None:
        _db.summaries.insert_one({
            "user_id": user_id,
            "summary": summary,
            "ts": datetime.now(timezone.utc),
        })
    else:
        _in_memory_summaries.append({
            "user_id": user_id,
            "summary": summary,
            "ts": datetime.now(timezone.utc).isoformat(),
        })

def get_summaries(user_id: str, limit: int = 5) -> list:
    if _db is not None:
        cursor = _db.summaries.find(
            {"user_id": user_id},
            {"_id": 0, "summary": 1}
        ).sort("ts", -1).limit(limit)
        return [doc["summary"] for doc in cursor]
    
    msgs = [m for m in _in_memory_summaries if m["user_id"] == user_id]
    msgs.sort(key=lambda x: x["ts"], reverse=True)
    return [m["summary"] for m in msgs[:limit]]