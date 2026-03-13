from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    due_date: Optional[datetime] = None

class TaskCreate(TaskBase):
    pass

class Task(TaskBase):
    id: int
    is_completed: bool
    created_at: datetime

    model_config = {"from_attributes": True}

class HabitBase(BaseModel):
    title: str
    frequency: str = "daily"

class HabitCreate(HabitBase):
    pass

class Habit(HabitBase):
    id: int
    created_at: datetime

    model_config = {"from_attributes": True}

class SuccessResponse(BaseModel):
    success: bool
    message: str
