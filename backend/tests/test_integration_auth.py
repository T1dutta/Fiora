import os
import uuid

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient


pytestmark = [pytest.mark.asyncio, pytest.mark.integration]


@pytest_asyncio.fixture
async def client():
    if os.getenv("RUN_INTEGRATION") != "1":
        pytest.skip("Set RUN_INTEGRATION=1 and start MongoDB")
    from app.main import app

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


async def test_register_login_me_flow(client):
    email = f"u_{uuid.uuid4().hex[:8]}@example.com"
    password = "longpassword123"
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": email, "password": password, "display_name": "Test"},
    )
    assert reg.status_code == 200, reg.text
    token = reg.json()["access_token"]

    me = await client.get("/api/v1/profiles/me", headers={"Authorization": f"Bearer {token}"})
    assert me.status_code == 200
    assert me.json()["user"]["email"] == email

    login = await client.post("/api/v1/auth/login", json={"email": email, "password": password})
    assert login.status_code == 200
