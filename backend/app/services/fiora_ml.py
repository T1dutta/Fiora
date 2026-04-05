from typing import Any

import httpx

from app.config import settings


async def anomaly_score(payload: dict[str, Any]) -> dict[str, Any]:
    """
    Calls external Fiora ML service when configured; otherwise uses simple heuristics.
    """
    if settings.fiora_ml_url:
        headers = {}
        if settings.fiora_ml_api_key:
            headers["Authorization"] = f"Bearer {settings.fiora_ml_api_key}"
        async with httpx.AsyncClient(timeout=30.0) as client:
            r = await client.post(settings.fiora_ml_url.rstrip("/") + "/analyze", json=payload)
            r.raise_for_status()
            return r.json()

    # Heuristic fallback (non-diagnostic)
    symptoms = payload.get("recent_symptoms") or []
    score = min(1.0, 0.1 + 0.07 * len(symptoms))
    return {
        "anomaly_score": round(score, 3),
        "severity": "elevated" if score > 0.5 else "typical",
        "model": "heuristic_stub",
        "note": "Connect FIORA_ML_URL to your trained Fiora model for clinical-grade signals.",
    }
