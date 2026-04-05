import json
from typing import Annotated

from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from fastapi.responses import Response

from app.deps import get_current_user_id
from app.models.schemas import TTSBody
from app.security import decode_token
from app.services.elevenlabs_client import synthesize_speech
from app.services.gemini_client import stream_chat_reply

router = APIRouter()


@router.websocket("/ws")
async def chat_ws(websocket: WebSocket):
    token = websocket.query_params.get("token")
    if not token:
        await websocket.close(code=4401)
        return
    try:
        decode_token(token)
    except Exception:
        await websocket.close(code=4401)
        return
    await websocket.accept()
    try:
        while True:
            raw = await websocket.receive_text()
            try:
                msg = json.loads(raw)
            except json.JSONDecodeError:
                await websocket.send_json({"type": "error", "detail": "invalid_json"})
                continue
            if msg.get("type") != "user_message":
                await websocket.send_json({"type": "error", "detail": "expected user_message"})
                continue
            text = (msg.get("text") or "").strip()
            if not text:
                await websocket.send_json({"type": "error", "detail": "empty_text"})
                continue
            await websocket.send_json({"type": "assistant_start"})
            full = []
            async for chunk in stream_chat_reply(text):
                full.append(chunk)
                await websocket.send_json({"type": "assistant_delta", "text": chunk})
            combined = "".join(full)
            await websocket.send_json({"type": "assistant_done", "text": combined})
            audio = await synthesize_speech(combined[:1200])
            if audio:
                import base64

                await websocket.send_json(
                    {
                        "type": "assistant_audio",
                        "format": "audio/mpeg",
                        "base64": base64.b64encode(audio).decode("ascii"),
                    }
                )
    except WebSocketDisconnect:
        return


@router.post("/tts")
async def text_to_speech(
    user_id: Annotated[str, Depends(get_current_user_id)],
    body: TTSBody,
):
    _ = user_id
    audio = await synthesize_speech(body.text)
    if not audio:
        return Response(status_code=503, content=b"", media_type="audio/mpeg")
    return Response(content=audio, media_type="audio/mpeg")
