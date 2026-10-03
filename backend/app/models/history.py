from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base

class HistoryRecord(Base):
    __tablename__ = "history_records"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    source_text = Column(String, nullable=False)
    translated_text = Column(String, nullable=False)
    mode = Column(String, nullable=False) # e.g., 'Text to Sign' or 'Sign to Text'
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Establish relationship back to User (Requires adding relationship in User model too, but SQLAlchemy can work without it if we just query HistoryRecord)
