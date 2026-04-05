import requests
import json
import time
import urllib.request

__test__ = False

BASE_URL = "http://127.0.0.1:8000"
USER_ID = "test_feature_user"

def call_endpoint(name, method, path, json_data=None):
    url = f"{BASE_URL}{path}"
    print(f"Testing {name}...", end=" ")
    try:
        if method == "GET":
            response = requests.get(url)
        else:
            response = requests.post(url, json=json_data)
        
        if response.status_code == 200:
            print(f"✅ OK ({response.elapsed.total_seconds():.2f}s)")
            return response.json()
        elif response.status_code == 500 and "model" in name.lower():
            print(f"⚠️ Warning ({response.status_code}): {response.text}")
            return None
        else:
            print(f"❌ FAILED ({response.status_code})")
            print(f"   Response: {response.text}")
            return None
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")
        return None

def run_tests():
    print(f"--- Starting Full Feature Test for Shakti AI ---")
    
    # 1. Health
    call_endpoint("Health Check", "GET", "/health")
    
    # 2. Endometriosis Model Status
    status = call_endpoint("Endometriosis Model Status", "GET", "/model-status")
    
    if status and status.get("status") == "not_trained":
        print("   -> Training model first...")
        call_endpoint("Train Endometriosis Model", "POST", "/train-endometriosis-model")
    
    # 3. Endometriosis Screening
    call_endpoint("Endometriosis Screening", "POST", "/endometriosis-screening", {
        "age": 28,
        "menstrual_irregularity": 1,
        "chronic_pain_level": 7.5,
        "hormone_level_abnormality": 0,
        "infertility": 0,
        "bmi": 24.5
    })
    
    # 3b. PCOS Screening (NEW)
    pcos_response = call_endpoint("PCOS Screening", "POST", "/pcos-screening", {
        "age": 25,
        "bmi": 29.5,
        "menstrual_irregularity": 1,
        "hirsutism": 1,
        "acne": 1
    })

    if pcos_response is None:
        print("   -> Training PCOS model first...")
        call_endpoint("Train PCOS Model", "POST", "/train-pcos-model")
        call_endpoint("PCOS Screening (Retry)", "POST", "/pcos-screening", {
            "age": 25,
            "bmi": 29.5,
            "menstrual_irregularity": 1,
            "hirsutism": 1,
            "acne": 1
        })
    
    # 4. Onboarding
    call_endpoint("Onboarding", "POST", "/onboarding", {
        "user_id": USER_ID,
        "cycle_length": 28,
        "last_period_date": "2024-03-01",
        "health_goals": ["reduce stress", "track cycles"],
        "concerns": ["cramps"]
    })
    
    # 5. Hidden ML Trigger via Chat (NEW)
    print("\n--- Testing Conversational ML Trigger ---")
    req_chat_ml = urllib.request.Request(
        f"{BASE_URL}/chat", 
        data=json.dumps({"user_id": USER_ID, "message": "My periods have been super irregular lately and my acne is awful."}).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    try:
        with urllib.request.urlopen(req_chat_ml) as response:
            res_data = json.loads(response.read().decode())
            print(f"✅ Conversational ML Trigger: {response.getcode()}")
            print(f"Shakti Response Snippet: {res_data.get('reply', '')[:150]}...")
            if "(Proactive Alert:" in res_data.get('reply', ''):
                print("   -> Success! Hidden ML Trigger correctly appended the Risk Warning!")
            else:
                print("   -> No ML Risk Warning appended.")
    except Exception as e:
        print(f"❌ Conversational ML Trigger Failed: {e}")
        
    # 5. Chat without RAG
    call_endpoint("Chat (Basic)", "POST", "/chat", {
        "user_id": USER_ID,
        "message": "Hello, how are you?",
        "use_rag": False
    })
    
    # 6. Chat with RAG
    call_endpoint("Chat (RAG Knowledgebase)", "POST", "/chat", {
        "user_id": USER_ID,
        "message": "What foods help with menstrual cramps?",
        "use_rag": True
    })
    
    # 7. Daily Checkin
    call_endpoint("Daily Checkin", "POST", "/daily-checkin", {
        "user_id": USER_ID,
        "mood": "tired",
        "pain_level": 5,
        "symptoms": ["headache"]
    })
    
    # 8. Pattern Insight
    call_endpoint("Pattern Insight", "POST", "/pattern-insight", {
        "user_id": USER_ID
    })
    
    # 9. Learn (Educational Content)
    call_endpoint("Learn (Flashcards/Quiz)", "POST", "/learn", {
        "user_id": USER_ID,
        "topic": "PCOS basics"
    })
    
    # 10. Proactive Alert
    call_endpoint("Proactive Alert", "POST", "/alert", {
        "user_id": USER_ID,
        "stress_level": "high",
        "context": "Simulated elevated heart rate overnight"
    })
    
    # 11. Summarize Session
    call_endpoint("Summarize Session", "POST", "/summarize-session", {
        "user_id": USER_ID
    })
    
    print("--- Full Feature Test Complete ---")

if __name__ == "__main__":
    run_tests()
