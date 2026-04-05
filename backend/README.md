# Fiora API (FastAPI + MongoDB Atlas)

Backend for the Fiora women’s health Flutter app. It complements [InsForge](https://docs.insforge.dev/introduction) patterns: see `/insforge` for PostgreSQL schemas and platform mapping. **InsForge MCP `fetch-docs` was not available in this environment**; docs were taken from [docs.insforge.dev/llms.txt](https://docs.insforge.dev/llms.txt).

## Stack

- **FastAPI** — OpenAPI at `/docs` and `/redoc`, async I/O, fits Python ML services.
- **MongoDB Atlas** — Motor driver, collection layout matches the features below.
- **JWT** (`python-jose`) and **Magic.link** (`magic-admin`) for auth.
- **Google Gemini** and **ElevenLabs** (optional) for education and voice.
- **Prometheus** default metrics at `/metrics`; **SlowAPI** rate limits (global + stricter auth routes).
- **Docker** + **docker-compose** at repo root for local API + MongoDB.

## Environment

Copy `.env.example` to `.env` and set at least:

- `MONGODB_URI` — Atlas SRV string or `mongodb://mongo:27017` in compose.
- `JWT_SECRET` — long random string in production.
- `MAGIC_SECRET_KEY` — for `POST /api/v1/auth/magic`.
- `GEMINI_API_KEY`, `ELEVENLABS_API_KEY`, `ELEVENLABS_VOICE_ID` — optional; demo fallbacks apply when unset.
- `FIORA_ML_URL` — optional HTTP endpoint for your trained anomaly model (`POST /analyze` JSON in/out as in `app/services/fiora_ml.py`).

## Run locally

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate   # Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

With Docker from repo root:

```bash
docker compose up --build
```

API base: `http://localhost:8000/api/v1` — interactive docs: `http://localhost:8000/docs`.

## Main endpoints

| Area | Method | Path |
|------|--------|------|
| Register / login / Magic | POST | `/api/v1/auth/register`, `/login`, `/magic` |
| Full signup (profile + health) | POST | `/api/v1/auth/signup` |
| User alerts | GET | `/api/v1/alerts` |
| Period day log (pain + flow) | POST | `/api/v1/periods` |
| Current user (JWT) | GET | `/api/v1/auth/me` |
| Profile + partners | GET, PATCH | `/api/v1/profiles/me` |
| Period entries | GET, POST | `/api/v1/periods/entries` |
| Cycle prediction | GET | `/api/v1/periods/prediction` |
| Wearables (HealthKit / Health Connect shaped) | POST, GET | `/api/v1/wearables/sync`, `/events` |
| Health analysis + Fiora ML hook | POST | `/api/v1/health/analyze` |
| Gemini MCQs | POST | `/api/v1/education/generate-questions` |
| Progress | POST | `/api/v1/education/progress/{topic_id}` |
| Points | GET, POST | `/api/v1/points/balance`, `/ledger`, `/earn`, `/redeem` |
| Exercise ideas | POST | `/api/v1/exercise/recommendations` |
| Chat (WebSocket) | WS | `/api/v1/chat/ws?token=<JWT>` — messages: `{"type":"user_message","text":"..."}` |
| TTS | POST | `/api/v1/chat/tts` — body `{"text":"..."}` |

## Realtime chat (WebSocket)

1. Obtain JWT via register/login/Magic.
2. Connect to `ws://<host>/api/v1/chat/ws?token=<JWT>`.
3. Send JSON: `{"type":"user_message","text":"Your question"}`.
4. Receive `assistant_delta` chunks, then `assistant_done`; optional `assistant_audio` (base64 MP3) if ElevenLabs is configured.

## Tests

```bash
cd backend
pip install -r requirements.txt
pytest -m "not integration"
```

With MongoDB running and `RUN_INTEGRATION=1`:

```bash
pytest -m integration
```

## Deploy (live URL)

This repository does not include cloud credentials. To get a **live link**:

1. Push the `backend` image to your registry (or use Render/Fly/Railway “Dockerfile” deploy).
2. Set environment variables in the host (Atlas URI, `JWT_SECRET`, optional AI keys).
3. Use HTTPS termination at the platform; restrict `CORS_ORIGINS` to your Flutter app.

After deploy, your **live API** is `https://<your-host>` with docs at `https://<your-host>/docs`.

## Security notes

- Never commit `.env`. Rotate `JWT_SECRET` per environment.
- Protect `/metrics` at the edge (allowlist or auth) if exposed publicly.
- Health and chat outputs are **not medical advice**; keep disclaimers in the client.
