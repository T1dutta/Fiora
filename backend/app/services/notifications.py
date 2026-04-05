"""
Push / outbound notifications.

FCM is not wired in this repo yet: we log and return a structured result so Flutter
can poll GET /alerts. When FIREBASE_SERVER_KEY (or service account) is configured,
extend send_severe_cramps_push to call FCM HTTP v1.
"""

from __future__ import annotations

import logging
from typing import Any

logger = logging.getLogger(__name__)


async def send_severe_cramps_push(
    user_id: str,
    title: str,
    body: str,
    *,
    device_tokens: list[str] | None = None,
) -> dict[str, Any]:
    """
    Attempt to notify the user. Without FCM credentials, only logs.
    """
    # Step: if client registered FCM tokens (future: store in users.fcm_tokens), send here.
    _ = device_tokens
    logger.warning(
        "SEVERE_CRAMPS_PUSH (log-only): user_id=%s title=%r body=%r — "
        "configure FCM to deliver real pushes.",
        user_id,
        title,
        body,
    )
    return {
        "delivered": False,
        "channel": "log",
        "note": "FCM not configured; alert stored in MongoDB for in-app polling.",
    }


def log_emergency_contact_flag(user_id: str, phone: str | None, alert_id: str) -> None:
    """Reserve hook for Twilio / SNS SMS to emergency_contact."""
    logger.info(
        "EMERGENCY_CONTACT_FLAG: user_id=%s alert_id=%s contact=%r — SMS integration pending",
        user_id,
        alert_id,
        phone,
    )
