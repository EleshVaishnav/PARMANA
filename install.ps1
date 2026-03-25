# ─────────────────────────────────────────
#  PARMANA INSTALLER — Windows
#  Har Bar Naya — Free, Local, Limitless AI
#  https://github.com/YOUR_USERNAME/parmana
# ─────────────────────────────────────────

$ErrorActionPreference = "Stop"
$PARMANA_VERSION = "1.0.0"
$REPO_RAW = "https://raw.githubusercontent.com/EleshVaishnav/parmana/main"

# ── Banner ──────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  ██████╗  █████╗ ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗ █████╗ " -ForegroundColor Blue
Write-Host "  ██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗████╗  ██║██╔══██╗" -ForegroundColor Blue
Write-Host "  ██████╔╝███████║██████╔╝██╔████╔██║███████║██╔██╗ ██║███████║" -ForegroundColor Blue
Write-Host "  ██╔═══╝ ██╔══██║██╔══██╗██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║" -ForegroundColor Blue
Write-Host "  ██║     ██║  ██║██║  ██║██║  ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║" -ForegroundColor Blue
Write-Host "  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝      ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝" -ForegroundColor Blue
Write-Host ""
Write-Host "  Har Bar Naya — Free, Local, Limitless AI" -ForegroundColor White
Write-Host "  Version: $PARMANA_VERSION"
Write-Host ""

# ── Step 1: RAM Detect ──────────────────
Write-Host "[1/4] System check ho raha hai..." -ForegroundColor Cyan

$RAM = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum
$TOTAL_RAM_GB = [math]::Round($RAM.Sum / 1GB)

Write-Host "  RAM    : ${TOTAL_RAM_GB}GB detected"
Write-Host "  OS     : Windows"

# ── Step 2: Model Choose ────────────────
Write-Host "[2/4] Best model choose ho raha hai..." -ForegroundColor Cyan

if ($TOTAL_RAM_GB -le 3) {
    $MODEL = "qwen3:0.6b"
    $MODEL_NAME = "Parmana Nano (0.6B)"
    $MODEL_SIZE = "~400MB"
} elseif ($TOTAL_RAM_GB -le 5) {
    $MODEL = "qwen3:2b"
    $MODEL_NAME = "Parmana Mini (2B)"
    $MODEL_SIZE = "~850MB"
} elseif ($TOTAL_RAM_GB -le 7) {
    $MODEL = "qwen3:4b"
    $MODEL_NAME = "Parmana (4B)"
    $MODEL_SIZE = "~1.8GB"
} else {
    $MODEL = "qwen3:8b"
    $MODEL_NAME = "Parmana Pro (8B)"
    $MODEL_SIZE = "~4GB"
}

Write-Host ""
Write-Host "  → $MODEL_NAME selected" -ForegroundColor Green
Write-Host "  Download size: $MODEL_SIZE"
Write-Host "  (Sirf pehli baar — phir hamesha offline)"
Write-Host ""

# ── Step 3: Ollama Install ──────────────
Write-Host "[3/4] Ollama install ho raha hai..." -ForegroundColor Cyan

$ollamaCheck = Get-Command ollama -ErrorAction SilentlyContinue
if ($ollamaCheck) {
    Write-Host "  Ollama already installed — skip" -ForegroundColor Green
} else {
    Write-Host "  Ollama download ho raha hai..."
    $ollamaInstaller = "$env:TEMP\OllamaSetup.exe"
    Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" -OutFile $ollamaInstaller
    Start-Process -FilePath $ollamaInstaller -Args "/S" -Wait
    Write-Host "  Ollama installed!" -ForegroundColor Green

    # PATH refresh
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# ── Step 4: Parmana Setup ───────────────
Write-Host "[4/4] Parmana setup ho raha hai..." -ForegroundColor Cyan
Write-Host "  Model download ho raha hai: $MODEL"
Write-Host "  Yeh kuch minutes le sakta hai..."
Write-Host ""

ollama pull $MODEL

# Modelfile download aur create
$ParmanaDir = "$env:USERPROFILE\.parmana"
New-Item -ItemType Directory -Force -Path $ParmanaDir | Out-Null
$ModelfilePath = "$ParmanaDir\Modelfile"

Invoke-WebRequest -Uri "$REPO_RAW/Modelfile" -OutFile "$ModelfilePath.tmp"

# Model name update karo
(Get-Content "$ModelfilePath.tmp") -replace "FROM qwen3:2b", "FROM $MODEL" | Set-Content $ModelfilePath
Remove-Item "$ModelfilePath.tmp"

ollama create parmana -f $ModelfilePath

# ── Done! ───────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   Parmana taiyaar hai!               ║" -ForegroundColor Green
Write-Host "║   Har Bar Naya.                      ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Shuru karne ke liye type karo:"
Write-Host ""
Write-Host "  ollama run parmana" -ForegroundColor Yellow
Write-Host ""
