from datetime import date, timedelta

from app.services.cycle_prediction import predict_next_period


def test_predict_insufficient_data():
    out = predict_next_period([date(2025, 1, 1)])
    assert out["next_period_start"] is None
    assert out["method"] == "insufficient_data"


def test_predict_moving_average():
    starts = [date(2025, 1, 1), date(2025, 1, 29), date(2025, 2, 26)]
    out = predict_next_period(starts)
    assert out["method"] == "moving_average"
    assert out["next_period_start"] is not None
    expected = starts[-1] + timedelta(days=28)
    assert out["next_period_start"] == expected.isoformat()
