import google.generativeai as genai
from elevenlabs.client import ElevenLabs
from elevenlabs import VoiceSettings
from gtts import gTTS
import os
import base64
import io
from dotenv import load_dotenv

load_dotenv()
_elevenlabs = None
elevenlabs_key = os.getenv("ELEVENLABS_API_KEY")
if elevenlabs_key:
    _elevenlabs = ElevenLabs(api_key=elevenlabs_key)

def transcribe_audio(audio_bytes: bytes, mime_type: str = "audio/webm") -> str:
    """Uses Gemini 1.5 Flash natively for incredibly fast, free Speech-to-Text."""
    model = genai.GenerativeModel("gemini-2.5-flash")
    prompt = "Transcribe this audio precisely. Return only the transcription without any extra conversational text."
    
    try:
        response = model.generate_content([
            {"mime_type": mime_type, "data": audio_bytes},
            prompt
        ])
        return response.text.strip()
    except Exception as e:
        print(f"STT Error (Gemini): {e}")
        return ""

def text_to_speech(text: str) -> str:
    """
    Returns base64-encoded audio string.
    Tries ElevenLabs first. If no key or out of credits, falls back to entirely free gTTS.
    """
    if _elevenlabs:
        try:
            audio_generator = _elevenlabs.text_to_speech.convert(
                voice_id=os.getenv("ELEVENLABS_VOICE_ID", "21m00Tcm4TlvDq8ikWAM"),
                text=text,
                model_id="eleven_multilingual_v2",
                voice_settings=VoiceSettings(
                    stability=0.6,
                    similarity_boost=0.8,
                    style=0.3,
                    use_speaker_boost=True,
                ),
            )
            audio_bytes = b"".join(audio_generator)
            return base64.b64encode(audio_bytes).decode("utf-8")
        except Exception as e:
            print(f"ElevenLabs TTS failed. Falling back to gTTS. Error: {e}")
            pass # proceed to fallback

    # Fallback to gTTS (100% free)
    try:
        tts = gTTS(text=text, lang='en', tld='co.in', slow=False)
        fp = io.BytesIO()
        tts.write_to_fp(fp)
        fp.seek(0)
        return base64.b64encode(fp.read()).decode("utf-8")
    except Exception as e:
        print(f"gTTS failed: {e}")
        return ""