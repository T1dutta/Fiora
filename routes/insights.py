from fastapi import APIRouter, HTTPException
import json
from schemas import InsightRequest, LearnRequest, AlertRequest
from ai.engine import (
    generate_pattern_insight, generate_learning_content,
    generate_proactive_alert, generate_session_summary
)
from db.mongo import get_user, save_message, get_session_messages, save_summary


router = APIRouter()


@router.post("/pattern-insight")
async def pattern_insight(req: InsightRequest):
    """Generate pattern insights based on user history"""
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


@router.post("/learn")
async def learn_topic(req: LearnRequest):
    """Generate learning content for a topic"""
    reply = generate_learning_content(req.topic)
    try:
        # Strip code formatting if Gemini adds it
        cleaned = reply.replace("```json", "").replace("```", "").strip()
        parsed_reply = json.loads(cleaned)
    except Exception:
        parsed_reply = {"raw": reply}
    
    return {"learning_content": parsed_reply}


@router.post("/alert")
async def proactive_alert(req: AlertRequest):
    """Generate proactive alert"""
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


@router.post("/summarize-session")
async def summarize_session(req: InsightRequest):
    """Summarize the current session"""
    user = get_user(req.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")
        
    history = get_session_messages(req.user_id, limit=20)
    if not history:
        return {"message": "No history to summarize."}
    
    summary = generate_session_summary(history)
    save_summary(req.user_id, summary)
    
    return {"summary": summary}
