from fastapi import APIRouter, UploadFile, File, HTTPException
from schemas import ChatRequest
from ai.engine import (
    get_chat_response, extract_symptoms_from_chat
)
from ai.voice import transcribe_audio, text_to_speech
from ai.rag import query_rag
from ai.pcos_model import PCOSModel
from ai.endometriosis_model import EndometriosisModel
from db.mongo import get_user, save_message, get_session_messages, get_summaries


router = APIRouter()


@router.post("/chat")
async def chat(req: ChatRequest):
    """Main chat endpoint with hidden ML risk screening"""
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


@router.post("/voice-chat")
async def voice_chat(user_id: str, audio: UploadFile = File(...)):
    """Voice chat endpoint - transcribe audio and respond with audio"""
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
