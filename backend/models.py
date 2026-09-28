from sqlalchemy import Column, Integer, String
from database import Base

class TranslationRecord(Base):
    """
    A database table that maps a specific word or sentence to a video file.
    """
    __tablename__ = "translations"

    id = Column(Integer, primary_key=True, index=True)
    source_text = Column(String, unique=True, index=True, nullable=False)
    video_url = Column(String, nullable=False)
