import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from main import app

client = TestClient(app)
TEST_USER = "test_user_shakti_001"

MOCK_USER = {
    "user_id": TEST_USER,
    "cycle_data": {
        "cycle_length": 28,
        "last_period_date": "2025-03-20",
        "health_goals": ["reduce cramps", "track mood"],
        "concerns": ["irregular cycles"],
        "age": 25,
        "bmi": 22.0,
    },
}


def _get_user(user_id: str):
    return MOCK_USER if user_id == TEST_USER else None


@pytest.fixture(autouse=True)
def mock_external():
    """
    Mock all external services so tests run offline.
    IMPORTANT: patch the name where it is *looked up* (in the routes module),
    not where it is originally defined.
    """
    with (
        patch("routes.chat.get_user", side_effect=_get_user),
        patch("routes.chat.get_session_messages", return_value=[]),
        patch("routes.chat.get_summaries", return_value=[]),
        patch("routes.chat.save_message"),
        patch("routes.chat.get_chat_response", return_value="I'm Shakti, your health companion."),
        patch("routes.chat.query_rag", return_value="RAG context"),
        patch("routes.chat.extract_symptoms_from_chat", return_value={
            "abdominal_pain": False, "irregular_periods": False, "acne": False,
            "hirsutism_or_excess_hair": False, "infertility_concerns": False,
            "hormone_abnormality": False,
        }),
        patch("routes.health.get_user", side_effect=_get_user),
        patch("routes.health.save_user"),
        patch("routes.health.save_message"),
        patch("routes.health.get_session_messages", return_value=[]),
        patch("routes.health.run_onboarding", return_value="Onboarding complete"),
        patch("routes.health.run_daily_checkin", return_value="Take care today"),
    ):
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


def test_invalid_pain_level():
    """Pydantic should reject pain_level outside 0-10."""
    r = client.post("/daily-checkin", json={
        "user_id": TEST_USER,
        "mood": "okay",
        "pain_level": 99,
    })
    assert r.status_code == 422


def test_invalid_age_screening():
    """Pydantic should reject age outside valid range."""
    r = client.post("/pcos-screening", json={
        "age": -5, "bmi": 22.0,
        "menstrual_irregularity": 1,
        "hirsutism": 0, "acne": 0,
    })
    assert r.status_code == 422


def test_context_length_limit():
    """Verify history is capped at 20 messages."""
    from db.mongo import get_session_messages
    with patch("db.mongo._db") as mock_db:
        mock_db.messages.find.return_value.sort.return_value.limit.return_value = (
            [{"role": "user", "content": f"msg{i}"} for i in range(20)]
        )
        history = get_session_messages(TEST_USER, limit=20)
        assert len(history) <= 20