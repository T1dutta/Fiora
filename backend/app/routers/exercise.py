from typing import Annotated

from fastapi import APIRouter, Depends

from app.deps import get_current_user_id
from app.models.schemas import ExerciseRecommendBody

router = APIRouter()

# Pain-relief focused suggestions (non-medical; encourage professional advice for pain)
LOW_PAIN = [
    {"id": "walk-10", "title": "Easy 10-minute walk", "tags": ["cardio", "low-impact"]},
    {"id": "stretch-hips", "title": "Hip and glute mobility flow", "tags": ["mobility"]},
]
MID_PAIN = [
    {"id": "breath-box", "title": "Box breathing (4-4-4-4)", "tags": ["relaxation"]},
    {"id": "child-pose", "title": "Supported child's pose", "tags": ["stretch", "rest"]},
]
HIGH_PAIN = [
    {"id": "heat-rest", "title": "Heat pack + rest in comfortable position", "tags": ["comfort"]},
    {"id": "gentle-cat-cow", "title": "Very slow cat-cow on hands and knees", "tags": ["gentle-mobility"]},
]


@router.post("/recommendations")
async def recommendations(
    user_id: Annotated[str, Depends(get_current_user_id)],
    body: ExerciseRecommendBody,
):
    _ = user_id
    if body.pain_level <= 3:
        base = LOW_PAIN
    elif body.pain_level <= 6:
        base = MID_PAIN
    else:
        base = HIGH_PAIN
    note = (
        "These are general comfort ideas, not medical advice. "
        "Seek urgent care for severe or sudden pain, fever, or bleeding concerns."
    )
    cycle_hint = None
    if body.cycle_day_hint is not None:
        if body.cycle_day_hint <= 5:
            cycle_hint = "Early-cycle days: favor gentle movement and recovery."
        elif 12 <= body.cycle_day_hint <= 16:
            cycle_hint = "Mid-cycle: you may tolerate slightly higher effort if it feels good."
    return {"items": base, "cycle_hint": cycle_hint, "disclaimer": note}
