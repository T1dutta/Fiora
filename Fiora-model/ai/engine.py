import google.generativeai as genai
import os
import json
from pydantic import BaseModel
from typing import List
from dotenv import load_dotenv

from ai.telemetry import track_interaction

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

SYSTEM_PROMPT = """
You are Shakti, an AI women's health companion. You are warm, non-judgmental,
medically informed, and deeply empathetic.

Your capabilities:
- Answer questions about menstrual health, cycle phases, PMS, PCOS, endometriosis
- Suggest phase-appropriate exercises and nutrition
- Explain physical and emotional patterns in simple, clear language
- Teach via flashcards and quizzes when asked
- Recommend when to see a doctor — you never diagnose

Rules you always follow:
- Never diagnose any medical condition
- End responses about serious symptoms with: "Please consult a gynecologist for personal advice."
- Use inclusive, body-positive, non-judgmental language
- Keep responses under 150 words unless the user asks to elaborate
- When a user seems distressed: lead with empathy, information comes second
- You remember the user's current cycle phase and refer to it naturally
"""

class SymptomExtraction(BaseModel):
    abdominal_pain: bool
    irregular_periods: bool
    acne: bool
    hirsutism_or_excess_hair: bool
    infertility_concerns: bool
    hormone_abnormality: bool

def _build_history(history: list) -> list:
    """Convert MongoDB message docs to Gemini history format."""
    formatted = []
    for msg in history:
        role = "user" if msg["role"] == "user" else "model"
        formatted.append({"role": role, "parts": [msg["content"]]})
    return formatted

def _inject_cycle_context(cycle_data: dict) -> str:
    if not cycle_data:
        return ""
    return (
        f"\n\n[CONTEXT — inject naturally, do not quote directly]\n"
        f"Cycle length: {cycle_data.get('cycle_length', 28)} days\n"
        f"Last period: {cycle_data.get('last_period_date', 'unknown')}\n"
        f"Health goals: {', '.join(cycle_data.get('health_goals', []))}\n"
        f"Known concerns: {', '.join(cycle_data.get('concerns', []))}\n"
    )


def _safe_generate_text(model, prompt: str, fallback_text: str) -> str:
    """Return model output text or a deterministic fallback if the provider fails."""
    try:
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        print(f"Gemini call failed, using fallback response: {e}")
        return fallback_text

def get_chat_response(
    user_message: str,
    history: list,
    cycle_data: dict,
    rag_context: str = "",
) -> str:
    with track_interaction("chat", "gemini-2.5-flash") as metrics:
        model = genai.GenerativeModel(
            model_name="gemini-2.5-flash",
            system_instruction=SYSTEM_PROMPT + _inject_cycle_context(cycle_data),
        )

        full_message = user_message
        if rag_context:
            full_message = (
                f"Relevant health information:\n{rag_context}\n\n"
                f"User question: {user_message}"
            )
            metrics["used_rag"] = True

        try:
            chat = model.start_chat(history=_build_history(history))
            response = chat.send_message(full_message)
            metrics["response_length"] = len(response.text)
            return response.text
        except Exception as e:
            print(f"Gemini chat failed, using fallback response: {e}")
            fallback = (
                "I am here with you. I am having trouble reaching my AI service right now, "
                "so I can only give general guidance: stay hydrated, rest, and monitor your symptoms. "
                "Please consult a gynecologist for personal advice."
            )
            metrics["response_length"] = len(fallback)
            return fallback

def run_onboarding(user_id: str, cycle_data: dict) -> str:
    model = genai.GenerativeModel(
        model_name="gemini-2.5-flash",
        system_instruction=SYSTEM_PROMPT,
    )
    prompt = (
        f"A new user just completed onboarding with these details:\n"
        f"Cycle length: {cycle_data['cycle_length']} days\n"
        f"Goals: {', '.join(cycle_data['health_goals'])}\n"
        f"Concerns: {', '.join(cycle_data.get('concerns', []))}\n\n"
        "Greet them warmly as Shakti, acknowledge their goals, "
        "and give one encouraging, personalised first tip."
    )
    return _safe_generate_text(
        model,
        prompt,
        "Welcome to Shakti. I am glad you are here. We will track your cycle and support your goals step by step.",
    )

def run_daily_checkin(
    mood: str,
    pain_level: int,
    symptoms: list,
    cycle_data: dict,
) -> str:
    model = genai.GenerativeModel(
        model_name="gemini-2.5-flash",
        system_instruction=SYSTEM_PROMPT + _inject_cycle_context(cycle_data),
    )
    prompt = (
        f"Daily check-in from user:\n"
        f"Mood: {mood}\n"
        f"Pain level: {pain_level}/10\n"
        f"Symptoms today: {', '.join(symptoms) if symptoms else 'none'}\n\n"
        "Respond warmly. If pain >= 7 or mood is very low, show extra care. "
        "Give one short, practical tip for today based on their cycle phase."
    )
    return _safe_generate_text(
        model,
        prompt,
        "Thank you for checking in. Please rest, hydrate, and use a warm compress if needed. Please consult a gynecologist for personal advice.",
    )

def generate_pattern_insight(cycle_data: dict, recent_logs: list) -> str:
    model = genai.GenerativeModel(
        model_name="gemini-2.5-flash",
        system_instruction=SYSTEM_PROMPT + _inject_cycle_context(cycle_data),
    )
    prompt = (
        f"The user has requested a pattern insight over their recent logs.\n"
        f"Recent Logs (moods, symptoms, etc): {recent_logs}\n\n"
        "Analyze these logs in the context of their cycle. Provide a warm, easy-to-understand "
        "human-readable insight about physical or emotional patterns. Remind them you are not a doctor."
    )
    return _safe_generate_text(
        model,
        prompt,
        "I am unable to generate a detailed pattern insight right now. Continue logging mood, pain, and symptoms daily so we can detect trends.",
    )

def extract_symptoms_from_chat(user_message: str) -> dict:
    """Uses Gemini to rapidly parse casual text and extract medical symptoms for invisible ML triggers."""
    prompt = f"""
    You are a medical parser. The user is chatting with an AI companion.
    Extract whether the user explicitly mentioned experiencing any of the following symptoms.
    Respond with a JSON structure indicating true or false for each.
    
    User message: "{user_message}"
    """
    try:
        model = genai.GenerativeModel(model_name="gemini-2.5-flash")
        response = model.generate_content(
            prompt,
            generation_config=genai.GenerationConfig(
                response_mime_type="application/json",
                response_schema=SymptomExtraction
            )
        )
        import json
        return json.loads(response.text)
    except Exception:
        return {
            "abdominal_pain": False,
            "irregular_periods": False,
            "acne": False,
            "hirsutism_or_excess_hair": False,
            "infertility_concerns": False,
            "hormone_abnormality": False
        }

class Flashcard(BaseModel):
    front: str
    back: str

class Quiz(BaseModel):
    question: str
    options: List[str]
    answer: str

class LearningContentResponse(BaseModel):
    flashcards: List[Flashcard]
    quiz: Quiz

def generate_learning_content(topic: str) -> str:
    with track_interaction("learning_content", "gemini-2.5-flash") as metrics:
        model = genai.GenerativeModel(
            model_name="gemini-2.5-flash",
            system_instruction="You are Shakti, an educational AI. Generate flashcards and quizzes.",
        )
        prompt = (
            f"The user wants to learn about: '{topic}'.\n"
            "Generate 3 short flashcards (Front and Back) and a 1-question multiple choice quiz.\n"
        )
        try:
            response = model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    response_mime_type="application/json",
                    response_schema=LearningContentResponse
                )
            )
            result_text = response.text
        except Exception as e:
            print(f"Gemini learning content failed, using fallback response: {e}")
            result_text = json.dumps(
                {
                    "flashcards": [
                        {"front": f"What is {topic}?", "back": f"{topic} is a health topic where tracking symptoms and cycle patterns can help."},
                        {"front": "One practical tip", "back": "Keep a daily symptom log including pain, mood, and sleep."},
                        {"front": "When to seek care", "back": "Seek care for severe pain, prolonged irregular bleeding, or persistent symptoms."}
                    ],
                    "quiz": {
                        "question": "Which habit helps improve health tracking accuracy?",
                        "options": ["Log symptoms daily", "Ignore cycle dates", "Only track once a month"],
                        "answer": "Log symptoms daily"
                    }
                }
            )

        metrics["topic"] = topic
        return result_text

def generate_proactive_alert(alert_data: dict) -> str:
    model = genai.GenerativeModel(
        model_name="gemini-2.5-flash",
        system_instruction=SYSTEM_PROMPT,
    )
    stress_level = alert_data.get("stress_level", "high")
    context = alert_data.get("context", "elevated heart rate detected")
    prompt = (
        f"An external trigger ('Presage' flow) reported an alert for the user.\n"
        f"Alert: Stress level is {stress_level}. Context: {context}.\n\n"
        "Proactively message the user with calming advice. Show deep empathy, "
        "suggest a quick grounding exercise or breathing technique, and remind them you are there for support. Keep it short."
    )
    return _safe_generate_text(
        model,
        prompt,
        "I noticed signs of high stress. Please pause for 60 seconds of slow breathing and drink water. I am here with you.",
    )

def generate_session_summary(history: list) -> str:
    model = genai.GenerativeModel(
        model_name="gemini-2.5-flash",
        system_instruction="You are an AI assistant tasked with summarizing a conversation between a user and a women's health bot.",
    )
    prompt = f"Summarize the key health concerns, cycle notes, and advice given in the following session history: {history}. Keep it under 50 words."
    return _safe_generate_text(
        model,
        prompt,
        "Session summary: You discussed cycle-related symptoms and received general self-care guidance and follow-up suggestions.",
    )