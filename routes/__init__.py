from .chat import router as chat_router
from .health import router as health_router
from .insights import router as insights_router
from .screening import router as screening_router

__all__ = ["chat_router", "health_router", "insights_router", "screening_router"]
