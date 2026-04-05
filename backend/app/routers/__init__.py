from fastapi import APIRouter

from app.routers import (
    alerts,
    auth,
    chat,
    education,
    exercise,
    health_analysis,
    periods,
    points,
    profiles,
    wearables,
)

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(alerts.router, prefix="/alerts", tags=["alerts"])
api_router.include_router(profiles.router, prefix="/profiles", tags=["profiles"])
api_router.include_router(periods.router, prefix="/periods", tags=["periods"])
api_router.include_router(wearables.router, prefix="/wearables", tags=["wearables"])
api_router.include_router(health_analysis.router, prefix="/health", tags=["health"])
api_router.include_router(education.router, prefix="/education", tags=["education"])
api_router.include_router(points.router, prefix="/points", tags=["points"])
api_router.include_router(exercise.router, prefix="/exercise", tags=["exercise"])
api_router.include_router(chat.router, prefix="/chat", tags=["chat"])
