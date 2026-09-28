from sqlalchemy import Column, Integer, String
from app.core.database import Base

class TranslationRecord(Base):
    __tablename__ = "translations"

    id = Column(Integer, primary_key=True, index=True)
    source_text = Column(String, unique=True, index=True, nullable=False)
    media_path = Column(String, nullable=False)
    media_type = Column(String, nullable=False, default="video") # "video" or "image"
