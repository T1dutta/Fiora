# Shakti AI Women's Health Companion

Shakti is an AI/ML backend for women's health support and risk screening.

It combines:
- conversational AI (Gemini)
- retrieval-augmented answers (RAG)
- speech input/output
- ML screening models for PCOS and Endometriosis
- MongoDB persistence with in-memory fallback

Architecture document: [ARCHITECTURE.md](ARCHITECTURE.md)

## 1) Tech Stack

| Layer | Technology | Why it is used | Where it is used |
|---|---|---|---|
| API framework | FastAPI | Fast async API development, automatic docs, request validation | `main.py` |
| ASGI server | Uvicorn | Runs FastAPI app in development/production | `run.ps1`, CLI command in setup |
| Data validation | Pydantic | Typed request/response schemas and safer API contracts | `main.py` request models |
| LLM provider | Google Gemini (`google-generativeai`) | Chat responses, symptom extraction, educational content, summaries, STT prompt-based transcription | `ai/engine.py`, `ai/voice.py` |
| RAG embeddings | Sentence Transformers (`all-MiniLM-L6-v2`) | Converts chunks into semantic vectors for similarity search | `ai/rag.py` |
| Vector search | FAISS (`faiss-cpu`) | Efficient nearest-neighbor retrieval over embeddings | `ai/rag.py` |
| RAG fallback | Lexical overlap scoring | Keeps retrieval available if FAISS/embeddings are unavailable | `ai/rag.py` |
| ML library | scikit-learn | Classical ML models, train/test split, scaling, metrics | `ai/pcos_model.py`, `ai/endometriosis_model.py` |
| Data handling | pandas, numpy | Dataset loading, feature engineering, numeric transforms | `ai/pcos_model.py`, `ai/endometriosis_model.py`, `ai/rag.py` |
| Model serialization | joblib (`.pkl`) | Persist trained models/scalers for runtime inference | `ai/pcos_model.py`, `ai/endometriosis_model.py`, `data/*.pkl` |
| Database | MongoDB + PyMongo | Persistent users/messages/summaries | `db/mongo.py` |
| Offline fallback store | In-memory Python dict/list | App still works when MongoDB is unavailable | `db/mongo.py` |
| Env config | python-dotenv | Loads API keys and connection strings from `.env` | `main.py`, `db/mongo.py`, `ai/voice.py`, `ai/engine.py` |
| Voice output (premium) | ElevenLabs | Higher-quality TTS when API key exists | `ai/voice.py` |
| Voice output (fallback) | gTTS | Free TTS fallback to avoid hard dependency on paid API | `ai/voice.py` |
| Testing | pytest, httpx, FastAPI TestClient | Endpoint and integration-style API testing | `tests/test_api.py`, `test_endpoints.py` |

## 2) Algorithms and Methods

### 2.1 PCOS Risk Model

| Algorithm / Method | Why it is used | Where it is used |
|---|---|---|
| Random Forest Classifier | Robust on mixed/tabular features, handles non-linear interactions, low feature-prep burden | `ai/pcos_model.py` in `train_model()` |
| Stratified train/test split | Preserves class balance during evaluation | `ai/pcos_model.py` in `train_model()` |
| StandardScaler | Normalizes feature ranges for stable training/inference pipeline consistency | `ai/pcos_model.py` in `train_model()` and `predict()` |
| Class-weight balancing | Mitigates class imbalance by penalizing minority-class errors more | `ai/pcos_model.py` (`class_weight='balanced'`) |
| Feature mapping/encoding | Converts user-friendly categorical medical fields into numeric model features | `ai/pcos_model.py` (`_prepare_csv_data`, `_prepare_xlsx_data`) |

### 2.2 Endometriosis Risk Model

| Algorithm / Method | Why it is used | Where it is used |
|---|---|---|
| Random Forest Classifier | Good baseline for tabular symptom/risk features and interpretable feature importance | `ai/endometriosis_model.py` in `train_model()` |
| Stratified train/test split | Keeps diagnosis ratio stable in train/test evaluation | `ai/endometriosis_model.py` in `train_model()` |
| StandardScaler | Ensures stable feature magnitudes and consistent inference path | `ai/endometriosis_model.py` in `train_model()` and `predict()` |
| Class-weight balancing | Improves minority-class handling for medical-risk prediction | `ai/endometriosis_model.py` (`class_weight='balanced'`) |
| Multi-source dataset loading | Allows training from structured CSV + synthetic CSV/PKL | `ai/endometriosis_model.py` (`_resolve_data_paths`, `_read_dataset`, `load_data`) |
| Synthetic feature engineering | Maps symptom-heavy synthetic schema to model feature set (pain/irregularity/hormone/infertility) | `ai/endometriosis_model.py` (`_prepare_synthetic_data`) |
| Classification report + confusion matrix | Provides detailed evaluation beyond simple accuracy | `ai/endometriosis_model.py` in `train_model()` |
| Feature importance ranking | Explains which inputs most influenced model predictions | `ai/endometriosis_model.py` in `train_model()` |

### 2.3 Retrieval-Augmented Generation (RAG)

| Algorithm / Method | Why it is used | Where it is used |
|---|---|---|
| Sentence embedding (`all-MiniLM-L6-v2`) | Semantic similarity search over health knowledge and dataset summaries | `ai/rag.py` (`_model`, `_load_kb`) |
| Vector normalization + cosine-like scoring | Improves similarity quality when using inner-product index | `ai/rag.py` (`_load_kb`, `query_rag`) |
| FAISS IndexFlatIP search | Fast top-k retrieval for relevant chunks | `ai/rag.py` (`_index.search`) |
| Lexical overlap fallback retrieval | Keeps system resilient if embedding stack is unavailable | `ai/rag.py` (`query_rag`) |
| Structured-to-text chunking | Makes CSV data retrievable in natural language form | `ai/rag.py` (`_build_endometriosis_chunks`, `_build_cycle_chunks`) |

### 2.4 Conversational AI and Routing Logic

| Method | Why it is used | Where it is used |
|---|---|---|
| Gemini chat completion | Empathetic medical-support responses with cycle context | `ai/engine.py` (`get_chat_response`) |
| Prompt-injected cycle context | Personalizes responses using known user profile and cycle metadata | `ai/engine.py` (`_inject_cycle_context`) |
| Symptom extraction JSON schema | Converts free-text chat into structured symptom flags for hidden ML trigger | `ai/engine.py` (`extract_symptoms_from_chat`) |
| Provider failure fallback responses | Keeps UX stable during API outages | `ai/engine.py` (`_safe_generate_text`, chat exception fallback) |
| Telemetry timing/logging | Monitors latency/success for AI features | `ai/telemetry.py`, calls in `ai/engine.py` |

### 2.5 Speech Pipeline

| Method | Why it is used | Where it is used |
|---|---|---|
| Gemini audio transcription | Fast transcription without adding separate ASR stack | `ai/voice.py` (`transcribe_audio`) |
| ElevenLabs primary TTS | Higher quality natural voice output | `ai/voice.py` (`text_to_speech`) |
| gTTS fallback | Zero-cost fallback if ElevenLabs key/credits are unavailable | `ai/voice.py` (`text_to_speech`) |
| Base64 audio transport | Simple API-safe transport for generated audio bytes | `ai/voice.py` |

## 3) Where Models Are Trained and Used in API

- Train Endometriosis model: `POST /train-endometriosis-model` in `main.py`
- Predict Endometriosis risk: `POST /endometriosis-screening` in `main.py`
- Train PCOS model: `POST /train-pcos-model` in `main.py`
- Predict PCOS risk: `POST /pcos-screening` in `main.py`
- Conversational hidden-risk trigger (PCOS/Endometriosis): `POST /chat` in `main.py`

## 4) Artifacts and Data Files

- Endometriosis model artifact: `data/endometriosis_model.pkl`
- Endometriosis scaler artifact: `data/scaler.pkl`
- PCOS model artifact: `data/pcos_model.pkl`
- PCOS scaler artifact: `data/pcos_scaler.pkl`
- Synthetic endometriosis dataset artifact: `data/endometriosis_synthetic.pkl`
- Main structured datasets: `structured_endometriosis_data.csv`, `pcos_prediction_dataset.csv`, `FedCycleData071012 (2).csv`

## 5) Environment Variables

Create `.env` in project root:

```env
GEMINI_API_KEY=your_gemini_api_key
MONGODB_URI=mongodb://localhost:27017/
ELEVENLABS_API_KEY=your_elevenlabs_api_key
ELEVENLABS_VOICE_ID=21m00Tcm4TlvDq8ikWAM
```

## 6) Run

```powershell
.venv\Scripts\Activate.ps1
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Docs:
- `http://localhost:8000/docs`
- `http://localhost:8000/redoc`
