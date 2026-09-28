from sqlalchemy import Column, Integer, String
from app.core.database import Base

class TranslationRecord(Base):
    __tablename__ = "translations"

    id = Column(Integer, primary_key=True, index=True)
    source_text = Column(String, unique=True, index=True, nullable=False)
    video_url = Column(String, nullable=False)
