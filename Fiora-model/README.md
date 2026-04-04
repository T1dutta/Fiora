# Shakti AI Women's Health Companion

Shakti is a FastAPI-based women's health AI/ML backend that provides:
- Gemini-powered conversational support
- Retrieval-augmented health context (RAG)
- Voice chat (speech-to-text + text-to-speech)
- Endometriosis risk screening with trained ML model
- PCOS risk screening with trained ML model
- MongoDB persistence with in-memory fallback

This is a pure AI/ML backend - no frontend or blockchain components included.

## What Is Implemented

- Core chat with cycle-aware context: `POST /chat`
- Voice chat upload + transcript + synthesized reply: `POST /voice-chat`
- User onboarding with cycle profile storage: `POST /onboarding`
- Daily emotional/symptom check-ins: `POST /daily-checkin`
- Pattern insights from recent history: `POST /pattern-insight`
- Learning content (flashcards + quiz JSON): `POST /learn`
- Proactive stress alert messaging: `POST /alert`
- Session summarization with stored summaries: `POST /summarize-session`
- Endometriosis model training: `POST /train-endometriosis-model`
- Endometriosis screening prediction: `POST /endometriosis-screening`
- PCOS model training: `POST /train-pcos-model`
- PCOS screening prediction: `POST /pcos-screening`
- Model readiness check: `GET /model-status`
- Service health check: `GET /health`

## Project Structure

```text
shakti-app/
|-- main.py
|-- requirements.txt
|-- run.ps1
|-- cleanup.py
|-- README.md
|-- structured_endometriosis_data.csv
|-- pcos_prediction_dataset.csv
|-- FedCycleData071012 (2).csv
|-- data/
|   `-- health_kb.txt
|-- ai/
|   |-- engine.py
|   |-- rag.py
|   |-- voice.py
|   |-- endometriosis_model.py
|   |-- pcos_model.py
|   `-- telemetry.py
|-- db/
|   |-- mongo.py
|   `-- models.py
|-- tests/
|   `-- test_api.py
`-- test_endpoints.py
```

## Setup

### 1. Create and activate a virtual environment

Windows PowerShell:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### 2. Install dependencies

```powershell
pip install -r requirements.txt
```

### 3. Configure environment variables

Create `.env` in the project root.

```env
# Required for AI chat and STT
GEMINI_API_KEY=your_gemini_api_key

# Optional: database
MONGODB_URI=mongodb://localhost:27017/

# Optional: premium TTS (falls back to gTTS if missing)
ELEVENLABS_API_KEY=your_elevenlabs_api_key
ELEVENLABS_VOICE_ID=21m00Tcm4TlvDq8ikWAM
```

## Run

### Option A: PowerShell helper script

```powershell
.\run.ps1 -Reload
```

### Option B: Uvicorn directly

```powershell
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

App URLs:
- API root: `http://localhost:8000/`
- Swagger: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Quick Reference

### `GET /health`
Returns:

```json
{
  "status": "ok",
  "bot": "Shakti"
}
```

### `POST /onboarding`
Request:

```json
{
  "user_id": "user_1",
  "cycle_length": 28,
  "last_period_date": "2026-03-20",
  "health_goals": ["reduce cramps", "track mood"],
  "concerns": ["irregular cycles"]
}
```

Returns:

```json
{
  "reply": "...",
  "message": "Onboarding complete"
}
```

### `POST /chat`
Request:

```json
{
  "user_id": "user_1",
  "message": "What helps period cramps?",
  "use_rag": true
}
```

Returns:

```json
{
  "reply": "...",
  "user_id": "user_1"
}
```

### `POST /voice-chat`
`multipart/form-data` with:
- `audio`: uploaded audio file
- query param: `user_id`

Returns:

```json
{
  "transcript": "...",
  "reply": "...",
  "audio_url": "<base64-encoded-audio>"
}
```

### `POST /daily-checkin`
Request:

```json
{
  "user_id": "user_1",
  "mood": "tired",
  "pain_level": 5,
  "symptoms": ["bloating", "headache"]
}
```

Returns:

```json
{
  "reply": "..."
}
```

### `POST /pattern-insight`
Request:

```json
{
  "user_id": "user_1"
}
```

Returns:

```json
{
  "insight": "..."
}
```

### `POST /learn`
Request:

```json
{
  "user_id": "user_1",
  "topic": "PCOS basics"
}
```

Returns:

```json
{
  "learning_content": {
    "flashcards": [
      {"front": "...", "back": "..."}
    ],
    "quiz": {
      "question": "...",
      "options": ["...", "..."],
      "answer": "..."
    }
  }
}
```

### `POST /alert`
Request:

```json
{
  "user_id": "user_1",
  "stress_level": "high",
  "context": "Elevated metrics detected"
}
```

Returns:

```json
{
  "proactive_message": "..."
}
```

### `POST /summarize-session`
Request:

```json
{
  "user_id": "user_1"
}
```

Returns:

```json
{
  "summary": "..."
}
```

or (if no history):

```json
{
  "message": "No history to summarize."
}
```

### `POST /train-endometriosis-model`
Returns training status, accuracy, and feature importance.

### `POST /endometriosis-screening`
Request:

```json
{
  "age": 28,
  "menstrual_irregularity": 1,
  "chronic_pain_level": 7.5,
  "hormone_level_abnormality": 0,
  "infertility": 0,
  "bmi": 24.5
}
```

Returns:

```json
{
  "prediction": {
    "prediction": 1,
    "diagnosis": "Endometriosis Risk",
    "probability_no_risk": 0.21,
    "probability_endometriosis": 0.79,
    "risk_level": "High",
    "risk_percentage": "79.0%"
  },
  "personalized_advice": "...",
  "disclaimer": "This is a screening tool, not a medical diagnosis. Always consult with healthcare professionals."
}
```

### `GET /model-status`
Returns `ready` if model/scaler are loadable; otherwise `not_trained`.

## Testing

### Unit/integration-style API tests (mocked external services)

```powershell
pytest tests/test_api.py
```

### Full endpoint smoke test (requires running API server)

```powershell
python test_endpoints.py
```

## Notes

- `db/mongo.py` falls back to in-memory storage when MongoDB is unavailable.
- `ai/voice.py` returns base64 audio content in `audio_url` (name kept for compatibility).
- This project is an assistive/educational tool and not a diagnostic medical device.
- Frontend and blockchain components have been removed - this is a pure AI/ML backend.
