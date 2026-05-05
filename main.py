from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from dotenv import load_dotenv

from routes import chat_router, health_router, insights_router, screening_router

load_dotenv()
app = FastAPI(title="Shakti AI Backend", version="1.0.0")


ALLOWED_ORIGINS = os.getenv(
    "ALLOWED_ORIGINS",
    "http://localhost:3000,http://localhost:8080"
).split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[o.strip() for o in ALLOWED_ORIGINS],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# ─────────────────────────────────────────────────────────────────────────────

# Mount frontend static files
if os.path.isdir("frontend"):
    app.mount("/ui", StaticFiles(directory="frontend", html=True), name="frontend")

# Include routers
app.include_router(chat_router, tags=["chat"])
app.include_router(health_router, tags=["health"])
app.include_router(insights_router, tags=["insights"])
app.include_router(screening_router, tags=["screening"])


@app.get("/")
async def root():
    """API root endpoint"""
    return {"message": "Shakti AI Backend Running. Visit /docs for API documentation."}