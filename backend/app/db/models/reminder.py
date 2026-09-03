import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, Integer, Boolean, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db.database import Base

class Reminder(Base):
    __tablename__ = "reminders"
    __table_args__ = (
        UniqueConstraint('financial_record_id', 'days_before', name='uq_record_days_before'),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    financial_record_id = Column(UUID(as_uuid=True), ForeignKey("financial_records.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    days_before = Column(Integer, nullable=False, default=0) # 0 means on the due date
    
    notification_enabled = Column(Boolean, default=True)
    alarm_enabled = Column(Boolean, default=False)
    voice_enabled = Column(Boolean, default=False)
    
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    financial_record = relationship("FinancialRecord", back_populates="reminders")
