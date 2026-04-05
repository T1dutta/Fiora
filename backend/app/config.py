from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "Fiora Women's Health API"
    mongodb_uri: str = "mongodb://localhost:27017"
    mongodb_db: str = "fiora"

    jwt_secret: str = "change-me-in-production-use-openssl-rand-hex-32"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24 * 7

    magic_secret_key: str | None = None

    gemini_api_key: str | None = None
    gemini_model: str = "gemini-2.0-flash"

    elevenlabs_api_key: str | None = None
    elevenlabs_voice_id: str | None = None

    fiora_ml_url: str | None = None
    fiora_ml_api_key: str | None = None

    cors_origins: str = "*"

    rate_limit_default: str = "200/minute"


settings = Settings()
