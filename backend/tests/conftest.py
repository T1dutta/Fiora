from unittest.mock import AsyncMock

import pytest


@pytest.fixture
def mock_indexes(monkeypatch):
    monkeypatch.setattr("app.db.ensure_indexes", AsyncMock())
