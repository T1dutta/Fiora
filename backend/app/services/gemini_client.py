import asyncio
from typing import AsyncIterator

from app.config import settings


async def generate_education_questions(topic: str, difficulty: str, count: int) -> list[dict]:
    if not settings.gemini_api_key:
        return [
            {
                "question": f"[demo] What is an important aspect of {topic}?",
                "choices": ["A", "B", "C", "D"],
                "answer_index": 0,
            }
        ]

    def _run():
        import google.generativeai as genai

        genai.configure(api_key=settings.gemini_api_key)
        model = genai.GenerativeModel(settings.gemini_model)
        prompt = (
            f"You are a women's health educator. Generate exactly {count} multiple-choice "
            f"questions about '{topic}' at {difficulty} level. "
            "Respond with JSON only: "
            '{"questions":[{"question":str,"choices":[str,str,str,str],"answer_index":0-3}]}'
        )
        resp = model.generate_content(prompt)
        text = (resp.text or "").strip()
        import json
        import re

        m = re.search(r"\{[\s\S]*\}", text)
        if not m:
            raise ValueError("Model did not return JSON")
        data = json.loads(m.group())
        return data.get("questions", [])

    return await asyncio.to_thread(_run)


async def stream_chat_reply(user_text: str) -> AsyncIterator[str]:
    if not settings.gemini_api_key:
        msg = (
            "I'm running in demo mode. Configure GEMINI_API_KEY for live answers. "
            "For menstrual health, track cycles consistently and contact a clinician for concerning symptoms."
        )
        for i in range(0, len(msg), 96):
            yield msg[i : i + 96]
        return

    def _full_text() -> str:
        import google.generativeai as genai

        genai.configure(api_key=settings.gemini_api_key)
        model = genai.GenerativeModel(settings.gemini_model)
        chat = model.start_chat(
            history=[
                {
                    "role": "user",
                    "parts": [
                        "You are Fiora, a supportive women's health assistant. "
                        "Give concise, non-diagnostic guidance and encourage professional care when appropriate."
                    ],
                },
                {"role": "model", "parts": ["Understood. How can I help today?"]},
            ]
        )
        resp = chat.send_message(user_text)
        return (resp.text or "").strip() or "I could not generate a reply. Please try again."

    text = await asyncio.to_thread(_full_text)
    for i in range(0, len(text), 96):
        yield text[i : i + 96]
