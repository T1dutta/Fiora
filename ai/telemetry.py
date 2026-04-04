import json
import time
import os
from datetime import datetime

TELEMETRY_LOG_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), "telemetry.log")

def track_interaction(feature_name: str, model_name: str):
    """
    Decorator/context manager to track AI interactions.
    Usage:
        with track_interaction("chat", "gemini-2.5-flash") as tracker:
            response = ...
            tracker["success"] = True
            tracker["response_length"] = len(response)
    """
    class TelemetryContext:
        def __init__(self):
            self.start_time = time.time()
            self.data = {
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "feature": feature_name,
                "model": model_name,
                "latency_ms": 0,
                "success": False,
                "error": None,
                "metrics": {} # For prompt versions or other details
            }
            
        def __enter__(self):
            return self.data["metrics"]
            
        def __exit__(self, exc_type, exc_value, traceback):
            self.data["latency_ms"] = int((time.time() - self.start_time) * 1000)
            if exc_type is None:
                self.data["success"] = True
            else:
                self.data["success"] = False
                self.data["error"] = str(exc_value)
                
            # Append to log file
            try:
                with open(TELEMETRY_LOG_FILE, "a", encoding="utf-8") as f:
                    f.write(json.dumps(self.data) + "\n")
            except Exception as e:
                print(f"Failed to write telemetry: {e}")
                
    return TelemetryContext()
