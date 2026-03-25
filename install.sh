#!/bin/sh
# ─────────────────────────────────────────
#  PARMANA INSTALLER
#  Har Bar Naya — Free, Local, Limitless AI
#  https://github.com/YOUR_USERNAME/parmana
# ─────────────────────────────────────────

set -e

PARMANA_VERSION="1.0.0"
REPO_RAW="https://raw.githubusercontent.com/YOUR_USERNAME/parmana/main"

# ── Colors ──────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Banner ──────────────────────────────
echo ""
echo "${BOLD}${BLUE}"
echo "  ██████╗  █████╗ ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗ █████╗ "
echo "  ██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔══██╗████╗  ██║██╔══██╗"
echo "  ██████╔╝███████║██████╔╝██╔████╔██║███████║██╔██╗ ██║███████║"
echo "  ██╔═══╝ ██╔══██║██╔══██╗██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║"
echo "  ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║"
echo "  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝"
echo "${RESET}"
echo "  ${BOLD}Har Bar Naya${RESET} — Free, Local, Limitless AI"
echo "  Version: ${PARMANA_VERSION}"
echo ""

# ── Step 1: OS Detect ───────────────────
echo "${BLUE}[1/5] System check ho raha hai...${RESET}"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux*)  PLATFORM="linux" ;;
  Darwin*) PLATFORM="mac" ;;
  *)
    echo "${RED}Error: Unsupported OS — $OS${RESET}"
    exit 1
    ;;
esac

echo "  OS     : $OS ($ARCH)"

# ── Step 2: RAM Detect ──────────────────
echo "${BLUE}[2/5] RAM check ho rahi hai...${RESET}"

if [ "$PLATFORM" = "linux" ]; then
  TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))
elif [ "$PLATFORM" = "mac" ]; then
  TOTAL_RAM_BYTES=$(sysctl -n hw.memsize)
  TOTAL_RAM_GB=$((TOTAL_RAM_BYTES / 1024 / 1024 / 1024))
fi

echo "  RAM    : ${TOTAL_RAM_GB}GB detected"

# ── Step 3: Model Choose ────────────────
echo "${BLUE}[3/5] Best model choose ho raha hai...${RESET}"

if [ "$TOTAL_RAM_GB" -le 3 ]; then
  MODEL="qwen3:0.6b"
  MODEL_NAME="Parmana Nano (0.6B)"
  MODEL_SIZE="~400MB"
elif [ "$TOTAL_RAM_GB" -le 5 ]; then
  MODEL="qwen3:2b"
  MODEL_NAME="Parmana Mini (2B)"
  MODEL_SIZE="~850MB"
elif [ "$TOTAL_RAM_GB" -le 7 ]; then
  MODEL="qwen3:4b"
  MODEL_NAME="Parmana (4B)"
  MODEL_SIZE="~1.8GB"
else
  MODEL="qwen3:8b"
  MODEL_NAME="Parmana Pro (8B)"
  MODEL_SIZE="~4GB"
fi

echo ""
echo "  ${GREEN}${BOLD}→ $MODEL_NAME selected${RESET}"
echo "  Download size: $MODEL_SIZE"
echo "  (Sirf pehli baar — phir hamesha offline)"
echo ""

# ── Step 4: Ollama Install ──────────────
echo "${BLUE}[4/5] Ollama install ho raha hai...${RESET}"

if command -v ollama > /dev/null 2>&1; then
  echo "  ${GREEN}Ollama already installed — skip${RESET}"
else
  echo "  Ollama download ho raha hai..."
  curl -fsSL https://ollama.com/install.sh | sh
  echo "  ${GREEN}Ollama installed!${RESET}"
fi

# ── Step 5: Parmana Setup ───────────────
echo "${BLUE}[5/5] Parmana setup ho raha hai...${RESET}"

echo "  Model download ho raha hai: $MODEL"
echo "  Yeh kuch minutes le sakta hai..."
echo ""

ollama pull "$MODEL"

# Download Modelfile aur create karo
MODELFILE_PATH="$HOME/.parmana/Modelfile"
mkdir -p "$HOME/.parmana"

curl -fsSL "$REPO_RAW/Modelfile" -o "$MODELFILE_PATH.tmp"

# Model name update karo Modelfile mein
sed "s|FROM qwen3:2b|FROM $MODEL|g" "$MODELFILE_PATH.tmp" > "$MODELFILE_PATH"
rm "$MODELFILE_PATH.tmp"

ollama create parmana -f "$MODELFILE_PATH"

# ── Done! ───────────────────────────────
echo ""
echo "${GREEN}${BOLD}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║   Parmana taiyaar hai!               ║"
echo "  ║   Har Bar Naya.                      ║"
echo "  ╚══════════════════════════════════════╝"
echo "${RESET}"
echo "  Shuru karne ke liye type karo:"
echo ""
echo "  ${BOLD}ollama run parmana${RESET}"
echo ""
