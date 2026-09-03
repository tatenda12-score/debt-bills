import uuid
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.api import dependencies
from app.db.models.user import User
from app.db.models.financial_record import FinancialRecord as DBFinancialRecord, DirectionEnum, StatusEnum, CategoryEnum
from app.schemas.financial_record import FinancialRecordCreate, FinancialRecordUpdate, FinancialRecord

router = APIRouter()

@router.post("/", response_model=FinancialRecord, status_code=status.HTTP_201_CREATED)
def create_financial_record(
    *,
    db: Session = Depends(dependencies.get_db),
    record_in: FinancialRecordCreate,
    current_user: User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Create a new financial record.
    """
    db_record = DBFinancialRecord(**record_in.model_dump(), user_id=current_user.id)
    db.add(db_record)
    db.commit()
    db.refresh(db_record)
    return db_record

@router.get("/", response_model=list[FinancialRecord])
def read_financial_records(
    db: Session = Depends(dependencies.get_db),
    skip: int = 0,
    limit: int = Query(100, le=100),
    direction: DirectionEnum | None = None,
    status_filter: StatusEnum | None = Query(None, alias="status"),
    category: CategoryEnum | None = None,
    current_user: User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Retrieve financial records.
    """
    query = db.query(DBFinancialRecord).filter(DBFinancialRecord.user_id == current_user.id)
    
    if direction:
        query = query.filter(DBFinancialRecord.direction == direction)
    if status_filter:
        query = query.filter(DBFinancialRecord.status == status_filter)
    if category:
        query = query.filter(DBFinancialRecord.category == category)
        
    records = query.offset(skip).limit(limit).all()
    return records

@router.get("/{id}", response_model=FinancialRecord)
def read_financial_record(
    *,
    db: Session = Depends(dependencies.get_db),
    id: uuid.UUID,
    current_user: User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Get financial record by ID.
    """
    record = db.query(DBFinancialRecord).filter(DBFinancialRecord.id == id, DBFinancialRecord.user_id == current_user.id).first()
    if not record:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Financial record not found")
    return record

@router.patch("/{id}", response_model=FinancialRecord)
def update_financial_record(
    *,
    db: Session = Depends(dependencies.get_db),
    id: uuid.UUID,
    record_in: FinancialRecordUpdate,
    current_user: User = Depends(dependencies.get_current_user),
) -> Any:
    """
    Update a financial record.
    """
    record = db.query(DBFinancialRecord).filter(DBFinancialRecord.id == id, DBFinancialRecord.user_id == current_user.id).first()
    if not record:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Financial record not found")
    
    update_data = record_in.model_dump(exclude_unset=True)
    non_nullable_fields = {"direction", "title", "amount", "currency", "category", "status", "recurrence_type"}
    for field, value in update_data.items():
        if field in non_nullable_fields and value is None:
            raise HTTPException(status_code=422, detail=f"{field} cannot be null")
        setattr(record, field, value)
        
    db.add(record)
    db.commit()
    db.refresh(record)
    return record

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_financial_record(
    *,
    db: Session = Depends(dependencies.get_db),
    id: uuid.UUID,
    current_user: User = Depends(dependencies.get_current_user),
) -> None:
    """
    Delete a financial record.
    """
    record = db.query(DBFinancialRecord).filter(DBFinancialRecord.id == id, DBFinancialRecord.user_id == current_user.id).first()
    if not record:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Financial record not found")
    
    db.delete(record)
    db.commit()
    return None
