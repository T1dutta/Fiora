from pydantic import BaseModel, Field
from typing import Optional, List


class ChatRequest(BaseModel):
    user_id: str
    message: str
    use_rag: Optional[bool] = False


class OnboardingRequest(BaseModel):
    user_id: str
    cycle_length: int = Field(..., ge=15, le=60, description="Cycle length in days (15–60)")
    last_period_date: str
    health_goals: List[str]
    concerns: Optional[List[str]] = []
    age: Optional[int] = Field(25, ge=10, le=80)
    bmi: Optional[float] = Field(24.0, ge=10.0, le=70.0)


class CheckinRequest(BaseModel):
    user_id: str
    mood: str
    pain_level: int = Field(..., ge=0, le=10, description="Pain level 0–10")
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
    age: int = Field(..., ge=10, le=80)
    menstrual_irregularity: int = Field(..., ge=0, le=1, description="0 = regular, 1 = irregular")
    chronic_pain_level: float = Field(..., ge=0.0, le=10.0, description="Pain scale 0–10")
    hormone_level_abnormality: int = Field(..., ge=0, le=1)
    infertility: int = Field(..., ge=0, le=1)
    bmi: float = Field(..., ge=10.0, le=70.0)


class PCOSScreeningRequest(BaseModel):
    age: int = Field(..., ge=10, le=80)
    bmi: float = Field(..., ge=10.0, le=70.0)
    menstrual_irregularity: int = Field(..., ge=0, le=1, description="1 = irregular, 0 = regular")
    hirsutism: int = Field(..., ge=0, le=1, description="1 = yes, 0 = no")
    acne: int = Field(..., ge=0, le=1, description="1 = yes, 0 = no")