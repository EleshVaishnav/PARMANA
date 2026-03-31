import json
import ollama
from datetime import datetime
from pathlib import Path

MEMORY_DIR = Path("E:/Parmana/data")
MEMORY_FILE = MEMORY_DIR / "MEMORY.md"
HISTORY_FILE = MEMORY_DIR / "HISTORY.md"

def setup():
    MEMORY_DIR.mkdir(exist_ok=True)

def read_memory():
    if MEMORY_FILE.exists():
        return MEMORY_FILE.read_text(encoding="utf-8")
    return ""

def write_memory(content):
    MEMORY_FILE.write_text(content, encoding="utf-8")

def append_history(entry):
    with open(HISTORY_FILE, "a", encoding="utf-8") as f:
        f.write(entry.strip() + "\n\n")

def get_context():
    memory = read_memory()
    return f"## What I remember about you:\n{memory}" if memory else ""

def consolidate(conversation):
    if not conversation:
        return

    current_memory = read_memory()
    chat_text = "\n".join([
        f"{m['role'].upper()}: {m['content']}"
        for m in conversation
        if m.get("content")
    ])

    prompt = f"""You are Parmana's memory system - NOT Parmana itself.
Extract facts about the USER only.

## Current Memory:
{current_memory or "(empty)"}

## Conversation:
{chat_text}

Respond in JSON only:
{{
    "history_entry": "[{datetime.now().strftime('%Y-%m-%d %H:%M')}] one line summary",
    "memory_update": "updated full memory as markdown"
}}"""

    try:
        response = ollama.chat(
            model="parmana",
            messages=[{"role": "user", "content": prompt}]
        )
        content = response["message"]["content"]
        start = content.find("{")
        end = content.rfind("}") + 1
        data = json.loads(content[start:end])
        append_history(data["history_entry"])
        if data["memory_update"] != current_memory:
            write_memory(data["memory_update"])
        print("Memory saved!")
    except Exception as e:
        print(f"Memory error: {e}")
        ts = datetime.now().strftime("%Y-%m-%d %H:%M")
        append_history(f"[{ts}] [RAW] {chat_text[:200]}")
