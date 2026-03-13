import asyncio
import os
import logging
from aiogram import Bot, Dispatcher, types
from aiogram.filters import CommandStart, Command
from aiogram.types import Message
from dotenv import load_dotenv

# Database imports
from sqlalchemy.orm import Session
import models, database

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")

if not BOT_TOKEN:
    raise ValueError("BOT_TOKEN is missing in .env file")

logging.basicConfig(level=logging.INFO)

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Bot handlers
@dp.message(CommandStart())
async def command_start_handler(message: Message) -> None:
    text = (
        f"Salom, {message.from_user.full_name}! MyLife botiga xush kelibsiz.\n\n"
        "Mavjud buyruqlar:\n"
        "/tasks - Barcha faol vazifalarni ko'rish\n"
        "/addtask <vazifa nomi> - Yangi vazifa qo'shish\n"
        "/done <vazifa raqami> - Vazifani bajarildi deb belgilash\n"
        "/habits - Odatlarni ko'rish\n"
        "/addhabit <odat nomi> - Yangi odat qo'shish"
    )
    await message.answer(text)

@dp.message(Command("addtask"))
async def add_task_handler(message: Message) -> None:
    command_parts = message.text.split(maxsplit=1)
    if len(command_parts) < 2:
        await message.answer("Iltimos, vazifa nomini kiriting. Masalan: /addtask Kitob o'qish")
        return
    
    task_title = command_parts[1]
    
    db = next(get_db())
    new_task = models.Task(title=task_title)
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    db.close()
    
    await message.answer(f"✅ Vazifa qo'shildi! Raqami: {new_task.id}\nNomi: {task_title}")

@dp.message(Command("tasks"))
async def list_tasks_handler(message: Message) -> None:
    db = next(get_db())
    tasks = db.query(models.Task).filter(models.Task.is_completed == False).all()
    db.close()
    
    if not tasks:
        await message.answer("🎉 Sizda faol vazifalar yo'q. Zo'r!")
        return
        
    response = "📝 Faol vazifalar:\n\n"
    for task in tasks:
        response += f"🆔 {task.id}. ▫️ {task.title}\n"
    
    response += "\nBajarilgan vazifani yopish uchun: /done <vazifa_raqami>"
    await message.answer(response)

@dp.message(Command("done"))
async def done_task_handler(message: Message) -> None:
    command_parts = message.text.split(maxsplit=1)
    if len(command_parts) < 2 or not command_parts[1].isdigit():
        await message.answer("Iltimos, vazifa raqamini to'g'ri kiriting. Masalan: /done 1")
        return
    
    task_id = int(command_parts[1])
    db = next(get_db())
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    
    if not db_task:
        await message.answer("❌ Bunday raqamli vazifa topilmadi.")
        db.close()
        return
        
    if db_task.is_completed:
        await message.answer("✅ Bu vazifa allaqachon bajarilgan.")
        db.close()
        return

    db_task.is_completed = True
    db.commit()
    db.refresh(db_task)
    db.close()
    
    await message.answer(f"🎉 Barakalla! Vazifa bajarildi: {db_task.title}")

@dp.message(Command("addhabit"))
async def add_habit_handler(message: Message) -> None:
    command_parts = message.text.split(maxsplit=1)
    if len(command_parts) < 2:
        await message.answer("Iltimos, odat nomini kiriting. Masalan: /addhabit Ertalabki yugurish")
        return
    
    habit_title = command_parts[1]
    
    db = next(get_db())
    new_habit = models.Habit(title=habit_title)
    db.add(new_habit)
    db.commit()
    db.refresh(new_habit)
    db.close()
    
    await message.answer(f"✅ Yangi odat tizimga qo'shildi: {habit_title}")

@dp.message(Command("habits"))
async def list_habits_handler(message: Message) -> None:
    db = next(get_db())
    habits = db.query(models.Habit).all()
    db.close()
    
    if not habits:
        await message.answer("🌱 Hali odatlar qo'shilmagan.")
        return
        
    response = "🌱 Sizning Odatlaringiz:\n\n"
    for habit in habits:
        response += f"▫️ {habit.title} ({habit.frequency})\n"
        
    await message.answer(response)

async def main() -> None:
    # Ensure tables exist
    models.Base.metadata.create_all(bind=database.engine)
    # Start bot
    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
