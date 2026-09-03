import uuid
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.api import dependencies
from app.db.models.user import User
from app.db.models.financial_record import FinancialRecord as DBFinancialRecord
from app.db.models.reminder import Reminder as DBReminder
from app.schemas.reminder import ReminderCreate, ReminderUpdate, Reminder

router = APIRouter()

@router.post("/financial-records/{record_id}/reminders", response_model=Reminder, status_code=status.HTTP_201_CREATED)
def create_reminder(
    *,
    db: Session = Depends(dependencies.get_db),
    record_id: uuid.UUID,
    reminder_in: ReminderCreate,
    current_user: User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Create a new reminder for a financial record.
    """
    # Verify ownership of financial record
    record = db.query(DBFinancialRecord).filter(DBFinancialRecord.id == record_id, DBFinancialRecord.user_id == current_user.id).first()
    if not record:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Financial record not found")
        
    db_reminder = DBReminder(
        **reminder_in.model_dump(),
        financial_record_id=record_id,
        user_id=current_user.id
    )
    db.add(db_reminder)
    db.commit()
    db.refresh(db_reminder)
    return db_reminder

@router.get("/financial-records/{record_id}/reminders", response_model=list[Reminder])
def read_reminders(
    *,
    db: Session = Depends(dependencies.get_db),
    record_id: uuid.UUID,
    skip: int = 0,
    limit: int = Query(100, le=100),
    current_user: User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Retrieve reminders for a specific financial record.
    """
    # Verify ownership of financial record
    record = db.query(DBFinancialRecord).filter(DBFinancialRecord.id == record_id, DBFinancialRecord.user_id == current_user.id).first()
    if not record:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Financial record not found")
        
    reminders = db.query(DBReminder).filter(
        DBReminder.financial_record_id == record_id,
        DBReminder.user_id == current_user.id
    ).offset(skip).limit(limit).all()
    
    return reminders

@router.patch("/reminders/{id}", response_model=Reminder)
def update_reminder(
    *,
    db: Session = Depends(dependencies.get_db),
    id: uuid.UUID,
    reminder_in: ReminderUpdate,
    current_user: User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Update a reminder.
    """
    reminder = db.query(DBReminder).filter(DBReminder.id == id, DBReminder.user_id == current_user.id).first()
    if not reminder:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Reminder not found")
    
    update_data = reminder_in.model_dump(exclude_unset=True)
    non_nullable_fields = {"days_before", "notification_enabled", "alarm_enabled", "voice_enabled"}
    for field, value in update_data.items():
        if field in non_nullable_fields and value is None:
            raise HTTPException(status_code=422, detail=f"{field} cannot be null")
        setattr(reminder, field, value)
        
    db.add(reminder)
    db.commit()
    db.refresh(reminder)
    return reminder

@router.delete("/reminders/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_reminder(
    *,
    db: Session = Depends(dependencies.get_db),
    id: uuid.UUID,
    current_user: User = Depends(dependencies.get_current_user),
) -> None:
    """
    Delete a reminder.
    """
    reminder = db.query(DBReminder).filter(DBReminder.id == id, DBReminder.user_id == current_user.id).first()
    if not reminder:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Reminder not found")
    
    db.delete(reminder)
    db.commit()
    return None
