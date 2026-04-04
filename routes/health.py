from fastapi import APIRouter, HTTPException
from schemas import OnboardingRequest, CheckinRequest
from ai.engine import run_onboarding, run_daily_checkin
from db.mongo import get_user, save_user, save_message, get_session_messages


router = APIRouter()


@router.post("/onboarding")
async def onboarding(req: OnboardingRequest):
    """User onboarding endpoint to capture health profile"""
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


@router.post("/daily-checkin")
async def daily_checkin(req: CheckinRequest):
    """Daily health check-in endpoint"""
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


@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "ok", "bot": "Shakti"}
