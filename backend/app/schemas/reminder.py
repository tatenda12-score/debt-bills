import uuid
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class ReminderBase(BaseModel):
    days_before: int = Field(ge=0, description="Days before the due date. 0 means on the due date.")
    notification_enabled: bool = True
    alarm_enabled: bool = False
    voice_enabled: bool = False

class ReminderCreate(ReminderBase):
    pass

class ReminderUpdate(BaseModel):
    days_before: Optional[int] = Field(None, ge=0)
    notification_enabled: Optional[bool] = None
    alarm_enabled: Optional[bool] = None
    voice_enabled: Optional[bool] = None

class Reminder(ReminderBase):
    id: uuid.UUID
    financial_record_id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
