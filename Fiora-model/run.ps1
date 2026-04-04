param(
    [switch]$Reload,
    [int]$Port = 8000
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "Starting Shakti app..." -ForegroundColor Cyan

$activateScript = Join-Path $PSScriptRoot ".venv\Scripts\Activate.ps1"
if (-not (Test-Path $activateScript)) {
    Write-Error ".venv not found. Create it first, then install requirements."
    exit 1
}

# Stop any stale uvicorn processes serving main:app to avoid route/version conflicts.
Get-CimInstance Win32_Process |
    Where-Object { $_.CommandLine -like '*uvicorn*main:app*' } |
    ForEach-Object {
        try {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction Stop
            Write-Host "Stopped old server process: $($_.ProcessId)" -ForegroundColor Yellow
        } catch {
            Write-Host "Could not stop process $($_.ProcessId): $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    }

& $activateScript

$uvicornArgs = @("-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "$Port")
if ($Reload) {
    $uvicornArgs += "--reload"
}

Write-Host "Running: python $($uvicornArgs -join ' ')" -ForegroundColor Green
python @uvicornArgs
