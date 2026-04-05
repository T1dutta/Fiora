from pydantic import BaseModel
from typing import Optional, List


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
