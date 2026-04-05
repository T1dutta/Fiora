import pytest
from httpx import ASGITransport, AsyncClient


@pytest.mark.asyncio
async def test_openapi_json(mock_indexes):
    from app.main import app

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        r = await ac.get("/openapi.json")
    assert r.status_code == 200
    assert "openapi" in r.json()


@pytest.mark.asyncio
async def test_health(mock_indexes):
    from app.main import app

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        r = await ac.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
