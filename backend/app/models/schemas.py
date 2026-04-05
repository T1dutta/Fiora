import re
from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel, EmailStr, Field, field_validator


class RegisterBody(BaseModel):
    """Legacy minimal registration (unchanged for existing clients)."""

    email: EmailStr
    password: str = Field(min_length=8)
    display_name: str | None = None


class SignupBody(BaseModel):
    """Full signup: credentials on user document; health fields on profile."""

    name: str = Field(min_length=1, max_length=100)
    age: int = Field(ge=13, le=120)
    email: EmailStr
    password: str = Field(min_length=8)
    cycle_length: int | None = Field(default=None, ge=21, le=45)
    avg_period_length: int = Field(ge=1, le=14)
    known_conditions: list[str] = Field(default_factory=list)
    emergency_contact: str = Field(min_length=7, max_length=32)

    @field_validator("known_conditions")
    @classmethod
    def strip_conditions(cls, v: list[str]) -> list[str]:
        return [c.strip() for c in v if c and str(c).strip()]

    @field_validator("emergency_contact")
    @classmethod
    def phone_basic(cls, v: str) -> str:
        s = v.strip()
        if not re.match(r"^[\d\s\-+().]{7,32}$", s):
            raise ValueError("Invalid emergency contact phone format")
        return s


class LoginBody(BaseModel):
    email: EmailStr
    password: str


class MagicLoginBody(BaseModel):
    did_token: str


class MagicSignupBody(BaseModel):
    """POST /auth/magic_signup — DID token + full health profile fields."""

    did_token: str
    name: str = Field(min_length=1, max_length=100)
    age: int = Field(ge=13, le=120)
    cycle_length: int | None = Field(default=None, ge=21, le=45)
    avg_period_length: int = Field(ge=1, le=14)
    known_conditions: list[str] = Field(default_factory=list)
    emergency_contact: str = Field(min_length=7, max_length=32)

    @field_validator("known_conditions")
    @classmethod
    def strip_conditions(cls, v: list[str]) -> list[str]:
        return [c.strip() for c in v if c and str(c).strip()]

    @field_validator("emergency_contact")
    @classmethod
    def phone_basic(cls, v: str) -> str:
        s = v.strip()
        if not re.match(r"^[\d\s\-+().]{7,32}$", s):
            raise ValueError("Invalid emergency contact phone format")
        return s


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class PartnerContact(BaseModel):
    name: str
    phone: str | None = None
    email: EmailStr | None = None
    relationship: str | None = None


class ProfileUpdate(BaseModel):
    """
    PATCH /profiles/me — all fields optional.

    FIX: The original ProfileUpdate only had display_name, bio, and partners.
    InfoPage sends health data (height, weight, last_period_date, flow_rating,
    mood, initial_symptoms) which the backend silently ignored because those
    keys were not declared here.  They are now accepted and stored on the
    profile document.
    """

    # Original fields — unchanged
    display_name: str | None = None
    bio: str | None = None
    partners: list[PartnerContact] | None = None

    # FIX: new fields sent by InfoPage after signup
    height_cm: float | None = Field(default=None, ge=50, le=300)
    weight_kg: float | None = Field(default=None, ge=20, le=500)
    last_period_date: date | None = None
    flow_rating: int | None = Field(default=None, ge=1, le=10)
    mood: str | None = Field(default=None, max_length=50)
    initial_symptoms: list[str] | None = None


class PeriodEntryCreate(BaseModel):
    """Original period log shape (still supported)."""

    start_date: date
    end_date: date | None = None
    flow_intensity: Literal["light", "medium", "heavy"] | None = None
    # Optional extensions for pain / flow label (backward compatible).
    flow: str | None = Field(default=None, max_length=32)
    symptoms: list[str] = Field(default_factory=list)
    pain_level: int | None = Field(default=None, ge=0, le=10)
    notes: str | None = None


class PeriodDayLogBody(BaseModel):
    """POST /periods — single-day log with explicit pain and flow labels."""

    date: date
    flow: str = Field(min_length=1, max_length=32)
    symptoms: list[str] = Field(default_factory=list)
    pain_level: int = Field(ge=0, le=10)


class WearableIngest(BaseModel):
    source: Literal["healthkit", "health_connect"]
    metric_type: str
    value: float
    unit: str | None = None
    recorded_at: datetime
    metadata: dict | None = None


class HealthAnalyzeBody(BaseModel):
    window_days: int = Field(default=90, ge=7, le=365)


class EducationGenerateBody(BaseModel):
    topic: str
    difficulty: Literal["beginner", "intermediate", "advanced"] = "beginner"
    count: int = Field(default=5, ge=1, le=20)


class PointsRedeemBody(BaseModel):
    product_code: str
    points_cost: int = Field(ge=1)


class ExerciseRecommendBody(BaseModel):
    pain_level: int = Field(ge=0, le=10)
    cycle_day_hint: int | None = Field(default=None, ge=1, le=45)


class TTSBody(BaseModel):
    text: str = Field(max_length=5000)


class PointsEarnBody(BaseModel):
    delta: int = Field(ge=1, le=50_000)
    reason: str = Field(min_length=1, max_length=200)
