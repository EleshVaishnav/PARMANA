# PARMANA INSTALLER — Windows
# Har Bar Naya — Free, Local, Limitless AI

$ErrorActionPreference = "Stop"
$PARMANA_VERSION = "1.0.0"
$REPO_RAW = "https://raw.githubusercontent.com/YOUR_USERNAME/parmana/main"

Clear-Host
Write-Host ""
Write-Host "  ██████╗  █████╗ ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗ █████╗ " -ForegroundColor Blue
Write-Host "  ██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗████╗  ██║██╔══██╗" -ForegroundColor Blue
Write-Host "  ██████╔╝███████║██████╔╝██╔████╔██║███████║██╔██╗ ██║███████║" -ForegroundColor Blue
Write-Host "  ██╔═══╝ ██╔══██║██╔══██╗██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║" -ForegroundColor Blue
Write-Host "  ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║" -ForegroundColor Blue
Write-Host "  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝" -ForegroundColor Blue
Write-Host ""
Write-Host "  Har Bar Naya — Free, Local, Limitless AI" -ForegroundColor White
Write-Host "  Version: $PARMANA_VERSION"
Write-Host ""

# STEP 1: RAM detect
Write-Host "[1/5] System check ho raha hai..." -ForegroundColor Cyan
$RAM = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum
$TOTAL_RAM_GB = [math]::Round($RAM.Sum / 1GB)
Write-Host "  RAM : ${TOTAL_RAM_GB}GB detected"
Write-Host ""

# STEP 2: Model choose
Write-Host "[2/5] Best model choose ho raha hai..." -ForegroundColor Cyan

if ($TOTAL_RAM_GB -le 3) {
    $MODEL = "qwen3:0.6b"; $MODEL_NAME = "Parmana Nano (0.6B)"; $MODEL_SIZE_MB = 400
} elseif ($TOTAL_RAM_GB -le 5) {
    $MODEL = "qwen3:2b"; $MODEL_NAME = "Parmana Mini (2B)"; $MODEL_SIZE_MB = 850
} elseif ($TOTAL_RAM_GB -le 7) {
    $MODEL = "qwen3:4b"; $MODEL_NAME = "Parmana (4B)"; $MODEL_SIZE_MB = 1800
} else {
    $MODEL = "qwen3:8b"; $MODEL_NAME = "Parmana Pro (8B)"; $MODEL_SIZE_MB = 4000
}

if ($MODEL_SIZE_MB -ge 1000) {
    $MODEL_SIZE_DISPLAY = "{0:N1} GB" -f ($MODEL_SIZE_MB / 1000)
} else {
    $MODEL_SIZE_DISPLAY = "$MODEL_SIZE_MB MB"
}

Write-Host "  Model : $MODEL_NAME" -ForegroundColor Green
Write-Host "  Size  : $MODEL_SIZE_DISPLAY (sirf pehli baar download hoga)"
Write-Host ""

# STEP 3: Drive selection
Write-Host "[3/5] Install location choose karo..." -ForegroundColor Cyan
Write-Host ""

$AVAILABLE_DRIVES = Get-PSDrive -PSProvider FileSystem | Where-Object {
    $_.Name -match '^[A-Z]$' -and (Test-Path "$($_.Name):\")
} | ForEach-Object {
    $freeBytes = $_.Free
    $freeGB = [math]::Round($freeBytes / 1GB, 1)
    if ($freeBytes -ge 1GB) {
        $freeDisplay = "{0:N1} GB free" -f $freeGB
    } else {
        $freeDisplay = "{0:N0} MB free" -f ($freeBytes / 1MB)
    }
    [PSCustomObject]@{ Letter = $_.Name; FreeGB = $freeGB; FreeDisplay = $freeDisplay }
}

$i = 1
foreach ($drive in $AVAILABLE_DRIVES) {
    $hasSpace = $drive.FreeGB -ge ($MODEL_SIZE_MB / 1000 + 0.5)
    $tag = if ($hasSpace) { "[OK] " } else { "[LOW]" }
    $col = if ($hasSpace) { "Green" } else { "Red" }
    Write-Host "  $i. $($drive.Letter):\ — $tag — $($drive.FreeDisplay)" -ForegroundColor $col
    $i++
}

Write-Host ""
Write-Host "  Konsa drive chahiye? (number enter karo): " -ForegroundColor Yellow -NoNewline
$CHOICE = Read-Host

$IDX = [int]$CHOICE - 1
if ($IDX -lt 0 -or $IDX -ge $AVAILABLE_DRIVES.Count) {
    Write-Host "  Galat input — C:\ use ho raha hai" -ForegroundColor Red
    $SELECTED_DRIVE = "C"
} else {
    $SELECTED_DRIVE = $AVAILABLE_DRIVES[$IDX].Letter
}

$INSTALL_DIR = "${SELECTED_DRIVE}:\Parmana"
Write-Host ""
Write-Host "  Install location: $INSTALL_DIR" -ForegroundColor Green
Write-Host ""

# STEP 4: Ollama install
Write-Host "[4/5] Ollama install ho raha hai..." -ForegroundColor Cyan

$ollamaCheck = Get-Command ollama -ErrorAction SilentlyContinue
if ($ollamaCheck) {
    Write-Host "  Ollama already installed — skip" -ForegroundColor Green
} else {
    $ollamaInstaller = "$env:TEMP\OllamaSetup.exe"
    Write-Host "  Downloading Ollama..."

    Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" `
    -OutFile $ollamaInstaller `
    -UseBasicParsing

    $ollamaDir = "${SELECTED_DRIVE}:\Ollama"
    Start-Process -FilePath $ollamaInstaller -Args "/S /D=$ollamaDir" -Wait
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "  Ollama installed!" -ForegroundColor Green
}

# STEP 5: Parmana model download
Write-Host "[5/5] Parmana download ho raha hai..." -ForegroundColor Cyan
Write-Host ""
Write-Host "  Model  : $MODEL_NAME"
Write-Host "  Size   : $MODEL_SIZE_DISPLAY"
Write-Host "  Folder : $INSTALL_DIR\models"
Write-Host ""

$env:OLLAMA_MODELS = "$INSTALL_DIR\models"
[System.Environment]::SetEnvironmentVariable("OLLAMA_MODELS", "$INSTALL_DIR\models", "User")
New-Item -ItemType Directory -Force -Path "$INSTALL_DIR\models" | Out-Null

ollama pull $MODEL

# Modelfile setup
$cfgDir = "$INSTALL_DIR\config"
New-Item -ItemType Directory -Force -Path $cfgDir | Out-Null
$mfPath = "$cfgDir\Modelfile"
Invoke-WebRequest -Uri "$REPO_RAW/Modelfile" -OutFile "$mfPath.tmp"
(Get-Content "$mfPath.tmp") -replace "FROM qwen3:2b", "FROM $MODEL" | Set-Content $mfPath
Remove-Item "$mfPath.tmp"
ollama create parmana -f $mfPath

# DONE
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                          ║" -ForegroundColor Green
Write-Host "║   Parmana taiyaar hai!  Har Bar Naya.    ║" -ForegroundColor Green
Write-Host "║                                          ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Ab type karo:" -ForegroundColor White
Write-Host "  ollama run parmana" -ForegroundColor Yellow
Write-Host ""
