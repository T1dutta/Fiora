from app.security import create_access_token, decode_token, hash_password, verify_password


def test_password_roundtrip():
    h = hash_password("correct horse battery staple")
    assert verify_password("correct horse battery staple", h)
    assert not verify_password("wrong", h)


def test_jwt_roundtrip():
    token = create_access_token("user123", {"email": "a@b.com"})
    data = decode_token(token)
    assert data["sub"] == "user123"
    assert data["email"] == "a@b.com"
