from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends

from app.db import get_db
from app.deps import get_current_user_id
from app.models.schemas import EducationGenerateBody
from app.services.gemini_client import generate_education_questions

router = APIRouter()


@router.post("/generate-questions")
async def generate_questions(
    user_id: Annotated[str, Depends(get_current_user_id)],
    body: EducationGenerateBody,
):
    questions = await generate_education_questions(body.topic, body.difficulty, body.count)
    db = get_db()
    await db.education_generations.insert_one(
        {
            "user_id": user_id,
            "topic": body.topic,
            "difficulty": body.difficulty,
            "created_at": datetime.now(timezone.utc),
            "question_count": len(questions),
        }
    )
    return {"topic": body.topic, "questions": questions}


@router.post("/progress/{topic_id}")
async def mark_progress(user_id: Annotated[str, Depends(get_current_user_id)], topic_id: str):
    db = get_db()
    await db.education_progress.update_one(
        {"user_id": user_id, "topic_id": topic_id},
        {"$set": {"completed": True, "updated_at": datetime.now(timezone.utc)}},
        upsert=True,
    )
    return {"ok": True}
