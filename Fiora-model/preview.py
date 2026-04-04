from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

print("=== 1. ONBOARDING ===")
onboard_res = client.post("/onboarding", json={
    "user_id": "testUser123",
    "cycle_length": 29,
    "last_period_date": "2026-03-25",
    "health_goals": ["Manage stress", "Understand my body better"],
    "concerns": ["Occasional cramps"]
})
print(f"Status: {onboard_res.status_code}")
print(onboard_res.json().get("reply", onboard_res.text))
print("\n" + "="*40 + "\n")

print("=== 2. CHATTING WITH SHAKTI ===")
chat_res = client.post("/chat", json={
    "user_id": "testUser123",
    "message": "I'm feeling really overwhelmed today and my cramps are starting.",
    "use_rag": False
})
print(f"Status: {chat_res.status_code}")
print(chat_res.json().get("reply", chat_res.text))
print("\n" + "="*40 + "\n")

print("=== 3. LEARNING MODE ===")
learn_res = client.post("/learn", json={
    "user_id": "testUser123",
    "topic": "What is the luteal phase?"
})
print(f"Status: {learn_res.status_code}")
import json
print(json.dumps(learn_res.json().get("learning_content"), indent=2))
