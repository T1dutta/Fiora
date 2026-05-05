"""
MongoDB document models (plain dicts — no ODM required).
These describe the shape of documents stored in each collection.
"""

from datetime import datetime, timezone


def make_user(user_id: str, cycle_data: dict) -> dict:
    """Create a new user document."""
    return {
        "user_id": user_id,
        "cycle_data": cycle_data,
        "created_at": datetime.now(timezone.utc),
        "updated_at": datetime.now(timezone.utc),
    }


def make_message(user_id: str, role: str, content: str) -> dict:
    """Create a new chat message document. role must be 'user' or 'assistant'."""
    if role not in ("user", "assistant"):
        raise ValueError(f"role must be 'user' or 'assistant', got: {role!r}")
    return {
        "user_id": user_id,
        "role": role,
        "content": content,
        "ts": datetime.now(timezone.utc),
    }


def make_summary(user_id: str, summary: str) -> dict:
    """Create a new session summary document."""
    return {
        "user_id": user_id,
        "summary": summary,
        "ts": datetime.now(timezone.utc),
    }