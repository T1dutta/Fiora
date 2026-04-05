import random
import time
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import uvicorn

app = FastAPI()

@app.get("/")
def home():
    """
    Renders the simple UI with a Simulate button.
    Does not require any authentication or credentials!
    """
    html_content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Fiora Smartwatch Simulator</title>
        <style>
            body { font-family: -apple-system, system-ui, sans-serif; text-align: center; padding: 50px; background: #f4f3f1; }
            button { background: #4F6B52; color: white; border: none; padding: 15px 30px; font-size: 18px; border-radius: 40px; cursor: pointer; transition: background 0.2s;}
            button:hover { background: #3c543e; }
            #data-container { margin-top: 30px; background: white; padding: 20px; border-radius: 12px; display: none; text-align: left; max-width: 500px; margin-left: auto; margin-right: auto; box-shadow: 0 4px 6px rgba(0,0,0,0.05);}
            pre { background: #eee; padding: 15px; border-radius: 8px; overflow-x: auto; font-size: 14px; }
            .loading { opacity: 0.5; pointer-events: none; }
        </style>
    </head>
    <body>
        <h1>Fiora Health Mock Demo</h1>
        <p>This demo securely simulates incoming smartwatch metrics for your Hackathon presentation, bypassing Google Fit OAuth.</p>
        
        <button id="sim-btn" onclick="fetchMockData()">Simulate Smartwatch Data</button>
        
        <div id="data-container">
            <h3 style="color: #4F6B52;">📡 Data Synchronized Successfully!</h3>
            <p><strong>Captured AI Metrics:</strong></p>
            <pre id="fit-data">Waiting for sync...</pre>
        </div>

        <script>
            function fetchMockData() {
                const btn = document.getElementById('sim-btn');
                const container = document.getElementById('data-container');
                const dataBlock = document.getElementById('fit-data');
                
                btn.classList.add('loading');
                btn.innerText = "Syncing with Watch...";
                
                // Fetch the mock data from our backend
                fetch('/mock-data')
                    .then(res => res.json())
                    .then(data => {
                        setTimeout(() => { // Artificial delay to make simulation feel real
                            btn.classList.remove('loading');
                            btn.style.display = 'none';
                            
                            container.style.display = 'block';
                            dataBlock.innerText = JSON.stringify(data, null, 2);
                        }, 800);
                    })
                    .catch(err => {
                        btn.classList.remove('loading');
                        btn.innerText = "Sync Failed";
                        alert('Error fetching data: ' + err);
                    });
            }
        </script>
    </body>
    </html>
    """
    return HTMLResponse(content=html_content)


@app.get("/mock-data")
async def get_mock_data():
    """Generates realistic mock health data instantly."""
    
    # Generate realistic health bounds
    heart_rate = random.randint(62, 108)
    sleep_duration_hours = round(random.uniform(5.5, 8.5), 1)
    steps = random.randint(3500, 12500)
    stress_level = random.choice(["Low", "Normal", "Elevated", "High"])
    hrv = random.randint(35, 75)
    
    # Send simulated JSON matching what the app's AI expects
    return {
        "status": "success",
        "sync_timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "device": "Fiora Virtual Watch",
        "metrics": {
            "heart_rate_bpm": heart_rate,
            "steps_today": steps,
            "sleep_duration_hours": sleep_duration_hours,
            "stress_monitor": stress_level,
            "heart_rate_variability_ms": hrv
        },
        "ai_insight": f"Your resting heart rate is {heart_rate} bpm and you slept {sleep_duration_hours} hrs. Perfect condition for today's forecast!"
    }


if __name__ == "__main__":
    print("\\n🚀 Starting Hackathon Mock Server on port 8001...")
    print("👉 Open http://localhost:8001 in your browser!")
    uvicorn.run(app, host="127.0.0.1", port=8001)

