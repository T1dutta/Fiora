import asyncio

import httpx

from app.config import settings


async def synthesize_speech(text: str) -> bytes:
    if not settings.elevenlabs_api_key or not settings.elevenlabs_voice_id:
        return b""

    url = f"https://api.elevenlabs.io/v1/text-to-speech/{settings.elevenlabs_voice_id}"
    headers = {
        "xi-api-key": settings.elevenlabs_api_key,
        "Accept": "audio/mpeg",
        "Content-Type": "application/json",
    }
    body = {
        "text": text[:2500],
        "model_id": "eleven_multilingual_v2",
    }

    async with httpx.AsyncClient(timeout=60.0) as client:
        r = await client.post(url, json=body, headers=headers)
        r.raise_for_status()
        return r.content
