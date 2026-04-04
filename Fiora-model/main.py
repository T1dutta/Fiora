from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import os
from dotenv import load_dotenv

from ai.engine import (
    get_chat_response, run_onboarding, run_daily_checkin,
    generate_pattern_insight, generate_learning_content, generate_proactive_alert,
    generate_session_summary, extract_symptoms_from_chat
)
from ai.voice import transcribe_audio, text_to_speech
from ai.rag import query_rag
from ai.endometriosis_model import EndometriosisModel
from ai.pcos_model import PCOSModel
from db.mongo import get_user, save_message, get_session_messages, save_user, save_summary, get_summaries

load_dotenv()
app = FastAPI(title="Shakti AI Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    user_id: str
    message: str
    use_rag: Optional[bool] = False

class OnboardingRequest(BaseModel):
    user_id: str
    cycle_length: int
    last_period_date: str
    health_goals: List[str]
    concerns: Optional[List[str]] = []
    age: Optional[int] = 25
    bmi: Optional[float] = 24.0

class CheckinRequest(BaseModel):
    user_id: str
    mood: str
    pain_level: int
    symptoms: Optional[List[str]] = []

class InsightRequest(BaseModel):
    user_id: str

class LearnRequest(BaseModel):
    user_id: str
    topic: str

class AlertRequest(BaseModel):
    user_id: str
    stress_level: str
    context: Optional[str] = "Elevated metrics detected"

class EndometriosisScreeningRequest(BaseModel):
    age: int
    menstrual_irregularity: int  # 0 or 1
    chronic_pain_level: float  # 0-10
    hormone_level_abnormality: int  # 0 or 1
    infertility: int  # 0 or 1
    bmi: float

class PCOSScreeningRequest(BaseModel):
    age: int
    bmi: float
    menstrual_irregularity: int  # 1 for irregular, 0 for regular
    hirsutism: int  # 1 for Yes, 0 for No
    acne: int  # 1 for Yes, 0 for No

@app.get("/")
async def root():
    """API root endpoint"""
    return {"message": "Shakti AI Backend Running. Visit /docs for API documentation."}

@app.post("/chat")
async def chat(req: ChatRequest):
    user = get_user(req.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found. Complete onboarding first.")

    history = get_session_messages(req.user_id, limit=20)
    past_summaries = get_summaries(req.user_id, limit=3)
    
    rag_context = ""
    if req.use_rag:
        rag_context = query_rag(req.message)
    
    if past_summaries:
        rag_context = "Past Session Summaries:\n" + "\n".join(past_summaries) + "\n\n" + rag_context

    reply = get_chat_response(
        user_message=req.message,
        history=history,
        cycle_data=user.get("cycle_data", {}),
        rag_context=rag_context,
    )

    # --- HIDDEN ML TRIGGER ---
    try:
        symptoms = extract_symptoms_from_chat(req.message)
        
        # Pull defaults if missing from cycle_data
        cd = user.get("cycle_data", {})
        age = cd.get("age", 25)
        bmi = cd.get("bmi", 24.0)
        
        pcos_risk = False
        if symptoms.get("irregular_periods") or symptoms.get("acne") or symptoms.get("hirsutism_or_excess_hair"):
            pcos_model = PCOSModel()
            features = {
                'Age': age, 'BMI': bmi,
                'Menstrual_Irregularity': 1 if symptoms.get("irregular_periods") else 0,
                'Hirsutism_or_Hair_Growth': 1 if symptoms.get("hirsutism_or_excess_hair") else 0,
                'Acne': 1 if symptoms.get("acne") else 0
            }
            if pcos_model.load_model():
                pred = pcos_model.predict(features)
                if pred['prediction'] == 1: pcos_risk = True

        endo_risk = False
        if symptoms.get("abdominal_pain") or symptoms.get("irregular_periods"):
            endo_model = EndometriosisModel()
            e_features = {
                'Age': age, 'Menstrual_Irregularity': 1 if symptoms.get("irregular_periods") else 0,
                'Chronic_Pain_Level': 8.0 if symptoms.get("abdominal_pain") else 0.0,
                'Hormone_Level_Abnormality': 1 if symptoms.get("hormone_abnormality") else 0,
                'Infertility': 1 if symptoms.get("infertility_concerns") else 0,
                'BMI': bmi
            }
            if endo_model.load_model():
                e_pred = endo_model.predict(e_features)
                if e_pred == 1: endo_risk = True

        if pcos_risk or endo_risk:
            reply += "\n\n*(Proactive Alert: Based on your recent symptoms, my background AI screening detects a potential match for " + ("PCOS" if pcos_risk else "Endometriosis") + " patterns. Please take our detailed Health Screener for a personalized report!)*"

    except Exception as e:
        print(f"Hidden ML trigger failed silently: {e}")

    save_message(req.user_id, "user", req.message)
    save_message(req.user_id, "assistant", reply)

    return {"reply": reply, "user_id": req.user_id}

@app.post("/voice-chat")
async def voice_chat(user_id: str, audio: UploadFile = File(...)):
    user = get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    audio_bytes = await audio.read()
    transcript = transcribe_audio(audio_bytes)

    history = get_session_messages(user_id, limit=20)
    reply = get_chat_response(
        user_message=transcript,
        history=history,
        cycle_data=user.get("cycle_data", {}),
    )

    audio_url = text_to_speech(reply)

    save_message(user_id, "user", transcript)
    save_message(user_id, "assistant", reply)

    return {"transcript": transcript, "reply": reply, "audio_url": audio_url}

@app.post("/onboarding")
async def onboarding(req: OnboardingRequest):
    cycle_data = {
        "cycle_length": req.cycle_length,
        "last_period_date": req.last_period_date,
        "health_goals": req.health_goals,
        "concerns": req.concerns,
        "age": req.age,
        "bmi": req.bmi
    }
    save_user(req.user_id, cycle_data)
    reply = run_onboarding(req.user_id, cycle_data)
    return {"reply": reply, "message": "Onboarding complete"}

@app.post("/daily-checkin")
async def daily_checkin(req: CheckinRequest):
    user = get_user(req.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    reply = run_daily_checkin(
        mood=req.mood,
        pain_level=req.pain_level,
        symptoms=req.symptoms,
        cycle_data=user.get("cycle_data", {}),
    )
    return {"reply": reply}

@app.post("/pattern-insight")
async def pattern_insight(req: InsightRequest):
    user = get_user(req.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")
    
    # In a real app we'd fetch actual specific metrics. Here we use the session history.
    history = get_session_messages(req.user_id, limit=30)
    
    reply = generate_pattern_insight(
        cycle_data=user.get("cycle_data", {}),
        recent_logs=history
    )
    return {"insight": reply}

@app.post("/learn")
async def learn_topic(req: LearnRequest):
    import json
    reply = generate_learning_content(req.topic)
    try:
        # Strip code formatting if Gemini adds it
        cleaned = reply.replace("```json", "").replace("```", "").strip()
        parsed_reply = json.loads(cleaned)
    except Exception:
        parsed_reply = {"raw": reply}
    
    return {"learning_content": parsed_reply}

@app.post("/alert")
async def proactive_alert(req: AlertRequest):
    user = get_user(req.user_id)
    
    alert_data = {
        "stress_level": req.stress_level,
        "context": req.context
    }
    
    reply = generate_proactive_alert(alert_data)
    
    # Save the proactive alert to history
    if user:
        save_message(req.user_id, "assistant", reply)
        
    return {"proactive_message": reply}

@app.post("/summarize-session")
async def summarize_session(req: InsightRequest):
    user = get_user(req.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")
        
    history = get_session_messages(req.user_id, limit=20)
    if not history:
        return {"message": "No history to summarize."}
    
    summary = generate_session_summary(history)
    save_summary(req.user_id, summary)
    
    return {"summary": summary}
    
@app.get("/health")
async def health_check():
    return {"status": "ok", "bot": "Shakti"}

@app.post("/train-endometriosis-model")
async def train_endometriosis_model_endpoint():
    """Train the endometriosis risk prediction model using the CSV data"""
    try:
        model = EndometriosisModel()
        results = model.train_model("structured_endometriosis_data.csv")
        return {
            "status": "success",
            "message": "Model trained successfully",
            "accuracy": results['accuracy'],
            "feature_importance": results['feature_importance']
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Training failed: {str(e)}")

@app.post("/endometriosis-screening")
async def endometriosis_screening(req: EndometriosisScreeningRequest):
    """
    Screen for endometriosis risk based on patient symptoms and characteristics
    """
    try:
        # Initialize model and load pre-trained weights
        model = EndometriosisModel()
        
        # Prepare features
        features = {
            'Age': req.age,
            'Menstrual_Irregularity': req.menstrual_irregularity,
            'Chronic_Pain_Level': req.chronic_pain_level,
            'Hormone_Level_Abnormality': req.hormone_level_abnormality,
            'Infertility': req.infertility,
            'BMI': req.bmi
        }
        
        # Get prediction
        prediction = model.predict(features)
        
        # Get personalized advice
        advice = model.get_personalized_advice(prediction, features)
        
        return {
            "prediction": prediction,
            "personalized_advice": advice,
            "disclaimer": "This is a screening tool, not a medical diagnosis. Always consult with healthcare professionals."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Screening failed: {str(e)}")

@app.get("/model-status")
async def model_status():
    """Check if the endometriosis model is trained and ready"""
    model = EndometriosisModel()
    is_loaded = model.load_model()
    
    if is_loaded:
        return {
            "status": "ready",
            "message": "Endometriosis model is loaded and ready for predictions",
            "features": model.feature_names
        }
    else:
        return {
            "status": "not_trained",
            "message": "Model needs to be trained. Call /train-endometriosis-model first",
            "features": model.feature_names
        }

@app.post("/train-pcos-model")
async def train_pcos_model_endpoint():
    try:
        model = PCOSModel()
        results = model.train_model()
        return {
            "status": "success",
            "message": "PCOS Model trained successfully",
            "accuracy": results['accuracy']
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Training failed: {str(e)}")

@app.post("/pcos-screening")
async def pcos_screening(req: PCOSScreeningRequest):
    try:
        model = PCOSModel()
        
        # Mapped to feature_names in PCOSModel: ['Age', 'BMI', 'Menstrual_Irregularity', 'Hirsutism_or_Hair_Growth', 'Acne']
        features = {
            'Age': req.age,
            'BMI': req.bmi,
            'Menstrual_Irregularity': req.menstrual_irregularity,
            'Hirsutism_or_Hair_Growth': req.hirsutism,
            'Acne': req.acne
        }
        
        prediction = model.predict(features)
        
        return {
            "prediction": prediction,
            "disclaimer": "This is a machine learning screening tool, not a medical diagnosis. Always consult with healthcare professionals."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"PCOS Screening failed: {str(e)}")