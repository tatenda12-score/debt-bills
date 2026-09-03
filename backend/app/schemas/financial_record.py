import uuid
from pydantic import BaseModel, Field
from datetime import datetime, date
from decimal import Decimal
from typing import Optional
from app.db.models.financial_record import DirectionEnum, CategoryEnum, StatusEnum, RecurrenceTypeEnum

class FinancialRecordBase(BaseModel):
    direction: DirectionEnum
    title: str = Field(min_length=1)
    description: Optional[str] = None
    person_or_organization: Optional[str] = None
    amount: Decimal = Field(gt=0, decimal_places=2)
    currency: str = Field(default="USD", min_length=3, max_length=3)
    category: CategoryEnum = CategoryEnum.OTHER
    due_date: Optional[date] = None
    status: StatusEnum = StatusEnum.PENDING
    recurrence_type: RecurrenceTypeEnum = RecurrenceTypeEnum.NONE
    recurrence_interval: Optional[str] = None

class FinancialRecordCreate(FinancialRecordBase):
    pass

class FinancialRecordUpdate(BaseModel):
    direction: Optional[DirectionEnum] = None
    title: Optional[str] = Field(None, min_length=1)
    description: Optional[str] = None
    person_or_organization: Optional[str] = None
    amount: Optional[Decimal] = Field(None, gt=0, decimal_places=2)
    currency: Optional[str] = Field(None, min_length=3, max_length=3)
    category: Optional[CategoryEnum] = None
    due_date: Optional[date] = None
    status: Optional[StatusEnum] = None
    recurrence_type: Optional[RecurrenceTypeEnum] = None
    recurrence_interval: Optional[str] = None

class FinancialRecord(FinancialRecordBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
