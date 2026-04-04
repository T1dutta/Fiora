import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from main import app

client = TestClient(app)
TEST_USER = "test_user_shakti_001"

@pytest.fixture(autouse=True)
def mock_external():
    """Mock all external services so tests run offline and deterministically."""
    mock_user = {
        "user_id": TEST_USER,
        "cycle_data": {
            "cycle_length": 28,
            "last_period_date": "2025-03-20",
            "health_goals": ["reduce cramps", "track mood"],
            "concerns": ["irregular cycles"],
        },
    }

    def _get_user(user_id: str):
        return mock_user if user_id == TEST_USER else None

    with patch("main.get_user", side_effect=_get_user), \
         patch("main.get_session_messages", return_value=[]), \
         patch("main.get_summaries", return_value=[]), \
         patch("main.save_message"), \
         patch("main.save_user"), \
         patch("main.run_onboarding", return_value="Onboarding complete"), \
         patch("main.run_daily_checkin", return_value="Take care today"), \
         patch("main.get_chat_response", return_value="I'm Shakti, your health companion."), \
         patch("main.query_rag", return_value="RAG context"):
        yield

def test_health_check():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["bot"] == "Shakti"

def test_chat_basic():
    r = client.post("/chat", json={
        "user_id": TEST_USER,
        "message": "What should I eat during my period?",
    })
    assert r.status_code == 200
    assert "reply" in r.json()
    assert len(r.json()["reply"]) > 0

def test_chat_with_rag():
    r = client.post("/chat", json={
        "user_id": TEST_USER,
        "message": "Tell me about PCOS",
        "use_rag": True,
    })
    assert r.status_code == 200
    assert "reply" in r.json()

def test_chat_unknown_user():
    r = client.post("/chat", json={
        "user_id": "ghost_user_xyz",
        "message": "Hello",
    })
    assert r.status_code == 404

def test_onboarding():
    r = client.post("/onboarding", json={
        "user_id": TEST_USER,
        "cycle_length": 28,
        "last_period_date": "2025-03-20",
        "health_goals": ["track mood", "reduce pain"],
        "concerns": ["PCOS"],
    })
    assert r.status_code == 200
    assert "reply" in r.json()

def test_daily_checkin():
    r = client.post("/daily-checkin", json={
        "user_id": TEST_USER,
        "mood": "tired",
        "pain_level": 6,
        "symptoms": ["bloating", "headache"],
    })
    assert r.status_code == 200
    assert "reply" in r.json()

def test_context_length_limit():
    """Verify history is capped at 20 messages."""
    from db.mongo import get_session_messages
    with patch("db.mongo._db") as mock_db:
        mock_db.messages.find.return_value.sort.return_value.limit.return_value = (
            [{"role": "user", "content": f"msg{i}"} for i in range(20)]
        )
        history = get_session_messages(TEST_USER, limit=20)
        assert len(history) <= 20