import asyncio
from telegram import Update
from telegram.ext import ApplicationBuilder, MessageHandler, filters, ContextTypes
import ollama
from memory.memory import setup, get_context, consolidate

BOT_TOKEN = "YOUR_BOT_TOKEN"
YOUR_ID = None  # Tumhara Telegram ID

# Har user ki conversation history
user_sessions = {}

setup()

async def handle(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    if YOUR_ID and update.effective_user.id != YOUR_ID:
        return

    user_id = str(update.effective_user.id)
    user_msg = update.message.text

    # User ka session lo ya banao
    if user_id not in user_sessions:
        user_sessions[user_id] = []

    # Memory se context lo
    memory_context = get_context()

    # System prompt + memory
    memory_context = get_context()

if memory_context:
    system = f"""You are Parmana - a free, local, limitless AI assistant.

IMPORTANT - This is what you remember about this user:
{memory_context}

Use this information naturally in conversation."""
else:
    system = "You are Parmana - a free, local, limitless AI assistant."

    # Messages banao
    messages = [{"role": "system", "content": system}]
    messages += user_sessions[user_id][-10:]  # Last 10 messages
    messages.append({"role": "user", "content": user_msg})

    await update.message.reply_text("...")

    response = ollama.chat(model="parmana", messages=messages)
    reply = response["message"]["content"]

    # Session mein add karo
    user_sessions[user_id].append({"role": "user", "content": user_msg})
    user_sessions[user_id].append({"role": "assistant", "content": reply})

    # Har 10 messages pe memory consolidate karo
    if len(user_sessions[user_id]) >= 10:
        consolidate(user_sessions[user_id])
        user_sessions[user_id] = []  # Reset session

    await update.message.reply_text(reply)

app = ApplicationBuilder().token(BOT_TOKEN).build()
app.add_handler(MessageHandler(filters.TEXT, handle))
print("Parmana bot memory ke saath chal raha hai...")
app.run_polling()
