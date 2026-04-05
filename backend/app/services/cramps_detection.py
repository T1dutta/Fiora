"""
Severe cramps / pain escalation rules for period + wearable context.

Rules (from product spec):
- pain_level >= 8 → severe
- OR pain_level >= 6 AND heart_rate > baseline + 15 (when both HR and baseline exist)
- OR user has a high-risk condition (e.g. endometriosis, PCOS) AND pain_level >= 5

FIX — Rule 4 (new):
- OR the symptoms list contains "severe cramps" (case-insensitive) regardless of
  the pain slider value.  This closes the disconnect where a user could explicitly
  describe severe cramps in words but the slider stayed low and no alert fired.

FIX — Rule 5 (new):
- OR the symptoms list contains "cramps" AND pain_level >= 6.
  Previously the cramps symptom chip was completely ignored by this function;
  only the pain slider was checked. Now both signals are combined so that a
  user who selects "Cramps" AND drags the slider to 6+ will trigger an alert
  even without wearable heart-rate data.
"""

from __future__ import annotations

from typing import Any


# Normalized substrings for condition matching (case-insensitive).
HIGH_RISK_CONDITION_MARKERS = (
    "endometriosis",
    "pcos",
    "polycystic",
    "adenomyosis",
)

# FIX: symptom strings that escalate alert regardless of pain slider.
SEVERE_CRAMP_SYMPTOM_MARKERS = (
    "severe cramps",
    "severe cramping",
    "extreme cramps",
)

# FIX: symptom strings that combine with pain_level for a lower threshold.
CRAMP_SYMPTOM_MARKERS = (
    "cramps",
    "cramping",
    "abdominal pain",
)

# FIX: pain threshold when a cramp symptom is present (lower than the
# standalone pain threshold of 8 because the symptom tag is a corroborating
# signal).
CRAMP_SYMPTOM_PAIN_THRESHOLD = 6


def _pain_level(entry: dict[str, Any]) -> int:
    raw = entry.get("pain_level")
    if raw is None:
        return 0
    try:
        return int(raw)
    except (TypeError, ValueError):
        return 0


def _has_high_risk_condition(profile: dict[str, Any] | None) -> bool:
    if not profile:
        return False
    conds = profile.get("known_conditions") or []
    for c in conds:
        if not isinstance(c, str):
            continue
        low = c.lower()
        for marker in HIGH_RISK_CONDITION_MARKERS:
            if marker in low:
                return True
    return False


def _symptom_strings(entry: dict[str, Any]) -> list[str]:
    """Return the symptoms list as lowercase strings (safe, no crash)."""
    raw = entry.get("symptoms") or []
    return [s.lower().strip() for s in raw if isinstance(s, str)]


def _has_severe_cramp_symptom(symptoms_lower: list[str]) -> bool:
    """True if any symptom string matches an explicit severe-cramp marker."""
    for s in symptoms_lower:
        for marker in SEVERE_CRAMP_SYMPTOM_MARKERS:
            if marker in s:
                return True
    return False


def _has_cramp_symptom(symptoms_lower: list[str]) -> bool:
    """True if any symptom string matches a general cramp marker."""
    for s in symptoms_lower:
        for marker in CRAMP_SYMPTOM_MARKERS:
            if marker in s:
                return True
    return False


def detect_severe_cramps(
    period_entry: dict[str, Any],
    wearable_data: dict[str, Any] | None,
    profile: dict[str, Any] | None,
) -> dict[str, Any]:
    """
    Evaluate whether this log should raise a severe-cramps alert.

    wearable_data may include:
      - heart_rate: latest or session HR
      - baseline_hr: user's typical resting / recent average
    """
    pain = _pain_level(period_entry)
    wearable_data = wearable_data or {}
    hr = wearable_data.get("heart_rate")
    baseline = wearable_data.get("baseline_hr")
    symptoms_lower = _symptom_strings(period_entry)

    reasons: list[str] = []

    # Rule 1: very high pain
    if pain >= 8:
        reasons.append(f"pain_level {pain} >= 8")

    # Rule 2: elevated pain + tachycardia vs baseline
    if pain >= 6 and hr is not None and baseline is not None:
        try:
            if float(hr) > float(baseline) + 15:
                reasons.append(
                    f"pain_level {pain} >= 6 and heart_rate {hr} > baseline {baseline} + 15"
                )
        except (TypeError, ValueError):
            pass

    # Rule 3: known conditions + moderate–high pain
    if _has_high_risk_condition(profile) and pain >= 5:
        reasons.append("high_risk_condition and pain_level >= 5")

    # ── FIX: Rule 4 ──────────────────────────────────────────────────────────
    # Explicit "severe cramps" or "extreme cramps" text in the symptoms list
    # fires the alert regardless of the pain slider.  This means a user who
    # selects a severe-cramp chip (if the frontend ever adds one) or who types
    # a note containing those words will always be captured.
    if _has_severe_cramp_symptom(symptoms_lower):
        reasons.append("symptom list contains explicit severe-cramp marker")

    # ── FIX: Rule 5 ──────────────────────────────────────────────────────────
    # "Cramps" chip selected AND pain_level >= 6.
    #
    # Before this fix, selecting the "Cramps" chip had zero effect on alert
    # triggering.  The backend only checked the pain slider, so a user who
    # reported cramps but kept the slider at 3 (reasonable for moderate cramps)
    # never triggered the alert.
    #
    # The combined threshold is intentionally LOWER than the standalone Rule 1
    # threshold (8) because the symptom tag is a corroborating signal — the
    # two together are more confident than the slider alone.
    if _has_cramp_symptom(symptoms_lower) and pain >= CRAMP_SYMPTOM_PAIN_THRESHOLD:
        reasons.append(
            f"cramp symptom selected and pain_level {pain} >= {CRAMP_SYMPTOM_PAIN_THRESHOLD}"
        )

    is_severe = len(reasons) > 0
    return {
        "is_severe": is_severe,
        "reason": "; ".join(reasons) if reasons else "below thresholds",
        "pain_level_evaluated": pain,
    }
