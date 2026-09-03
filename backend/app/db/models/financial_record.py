import uuid
import enum
from datetime import datetime, timezone
from sqlalchemy import Column, String, Numeric, Enum as SQLEnum, DateTime, ForeignKey, Date
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.database import Base

class DirectionEnum(str, enum.Enum):
    OWED_TO_ME = "OWED_TO_ME"
    I_OWE = "I_OWE"

class CategoryEnum(str, enum.Enum):
    RENT = "RENT"
    SCHOOL_FEES = "SCHOOL_FEES"
    SALARY = "SALARY"
    LOAN = "LOAN"
    MAINTENANCE = "MAINTENANCE"
    UTILITIES = "UTILITIES"
    SUBSCRIPTION = "SUBSCRIPTION"
    PERSONAL = "PERSONAL"
    BUSINESS = "BUSINESS"
    OTHER = "OTHER"

class StatusEnum(str, enum.Enum):
    PENDING = "PENDING"
    PAID = "PAID"
    CANCELLED = "CANCELLED"
    OVERDUE = "OVERDUE"

class RecurrenceTypeEnum(str, enum.Enum):
    NONE = "NONE"
    DAILY = "DAILY"
    WEEKLY = "WEEKLY"
    MONTHLY = "MONTHLY"
    YEARLY = "YEARLY"
    CUSTOM = "CUSTOM"

class FinancialRecord(Base):
    __tablename__ = "financial_records"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    direction = Column(SQLEnum(DirectionEnum), nullable=False, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    person_or_organization = Column(String, nullable=True)
    
    amount = Column(Numeric(14, 2), nullable=False)
    currency = Column(String, nullable=False, default="USD")
    
    category = Column(SQLEnum(CategoryEnum), nullable=False, default=CategoryEnum.OTHER)
    
    due_date = Column(Date, nullable=True, index=True)
    status = Column(SQLEnum(StatusEnum), nullable=False, default=StatusEnum.PENDING, index=True)
    
    recurrence_type = Column(SQLEnum(RecurrenceTypeEnum), nullable=False, default=RecurrenceTypeEnum.NONE)
    recurrence_interval = Column(String, nullable=True) # e.g. details for custom recurrence
    
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
    
    user = relationship("User")
    reminders = relationship("Reminder", back_populates="financial_record", cascade="all, delete-orphan")
