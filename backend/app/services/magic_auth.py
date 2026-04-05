from fastapi import HTTPException, status

from app.config import settings


def validate_magic_did_token(did_token: str) -> str:
    if not settings.magic_secret_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Magic.link is not configured (set MAGIC_SECRET_KEY)",
        )
    try:
        from magic_admin import Magic

        magic = Magic(api_secret_key=settings.magic_secret_key)
        magic.Token.validate(did_token)
        return magic.Token.get_public_address(did_token)
    except ImportError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="magic-admin package unavailable",
        ) from e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid Magic DID token: {e!s}",
        ) from e
