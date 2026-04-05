from datetime import date

from app.services.cramps_detection import detect_severe_cramps


def test_pain_ge_8():
    r = detect_severe_cramps({"pain_level": 8, "start_date": date.today()}, None, None)
    assert r["is_severe"] is True
    assert "8" in r["reason"]


def test_hr_spike_with_pain():
    entry = {"pain_level": 6}
    wearable = {"heart_rate": 100, "baseline_hr": 70}
    r = detect_severe_cramps(entry, wearable, None)
    assert r["is_severe"] is True


def test_endo_and_pain_5():
    profile = {"known_conditions": ["Endometriosis"]}
    r = detect_severe_cramps({"pain_level": 5}, None, profile)
    assert r["is_severe"] is True


def test_below_threshold():
    r = detect_severe_cramps({"pain_level": 4}, {"heart_rate": 90, "baseline_hr": 70}, None)
    assert r["is_severe"] is False


def test_cramps_symptom_and_pain_6():
    r = detect_severe_cramps({"pain_level": 6, "symptoms": ["everything is fine", "Cramps"]}, None, None)
    assert r["is_severe"] is True
    assert "cramp symptom" in r["reason"]


def test_severe_cramps_symptom_ignores_pain():
    r = detect_severe_cramps({"pain_level": 2, "symptoms": ["severe cramps", "headache"]}, None, None)
    assert r["is_severe"] is True
    assert "explicit severe-cramp marker" in r["reason"]
