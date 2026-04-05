from datetime import date, timedelta
from statistics import mean
from typing import Any


def predict_next_period(period_starts: list[date]) -> dict[str, Any]:
    """
    Lightweight cycle prediction from historical period start dates.
    Replace with your ML service by setting FIORA_ML_URL or importing a joblib model.
    """
    if len(period_starts) < 2:
        return {
            "next_period_start": None,
            "confidence": 0.2,
            "method": "insufficient_data",
            "message": "Log at least two cycles for a prediction.",
        }
    sorted_starts = sorted(period_starts)
    gaps = [(sorted_starts[i] - sorted_starts[i - 1]).days for i in range(1, len(sorted_starts))]
    gaps = [g for g in gaps if 15 <= g <= 45]
    if not gaps:
        return {
            "next_period_start": None,
            "confidence": 0.25,
            "method": "no_valid_gaps",
            "message": "Cycle lengths look unusual; confirm dates with your clinician.",
        }
    avg = mean(gaps)
    last = sorted_starts[-1]
    predicted = last + timedelta(days=round(avg))
    confidence = min(0.95, 0.45 + 0.05 * len(gaps))
    return {
        "next_period_start": predicted.isoformat(),
        "estimated_cycle_length_days": round(avg, 1),
        "confidence": round(confidence, 3),
        "method": "moving_average",
    }
