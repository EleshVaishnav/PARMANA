import asyncio
from telegram import Update
from telegram.ext import ApplicationBuilder, MessageHandler, filters, ContextTypes
import ollama
from memory.memory import setup, get_context, consolidate

BOT_TOKEN = "YOUR_BOT_TOKEN"
YOUR_ID = None

user_sessions = {}
setup()

async def handle(update: Update, ctx: ContextTypes.DEFAULT_TYPE):
    if YOUR_ID and update.effective_user.id != YOUR_ID:
        return

    user_id = str(update.effective_user.id)
    user_msg = update.message.text

    if user_id not in user_sessions:
        user_sessions[user_id] = []

    # Memory context lo
    memory_context = get_context(user_id)

    if memory_context:
        system = f"""You are Parmana - a free, local, limitless AI assistant.

IMPORTANT - This is what you remember about this user:
{memory_context}

Use this information naturally in conversation."""
    else:
        system = "You are Parmana - a free, local, limitless AI assistant."

    messages = [{"role": "system", "content": system}]
    messages += user_sessions[user_id][-10:]
    messages.append({"role": "user", "content": user_msg})

    await update.message.reply_text("...")

    response = ollama.chat(model="parmana", messages=messages)
    reply = response["message"]["content"]

    user_sessions[user_id].append({"role": "user", "content": user_msg})
    user_sessions[user_id].append({"role": "assistant", "content": reply})

    # Har 6 messages pe consolidate karo
    if len(user_sessions[user_id]) >= 6:
        consolidate(user_id, user_sessions[user_id])
        user_sessions[user_id] = []

    await update.message.reply_text(reply)

app = ApplicationBuilder().token(BOT_TOKEN).build()
app.add_handler(MessageHandler(filters.TEXT, handle))
print("Parmana bot chal raha hai...")
app.run_polling()
