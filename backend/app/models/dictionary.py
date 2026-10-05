from sqlalchemy import Column, Integer, String, Enum
from app.core.database import Base
import enum

class MediaType(str, enum.Enum):
    video = "video"
    image = "image"

class Dictionary(Base):
    __tablename__ = "dictionary"

    id = Column(Integer, primary_key=True, index=True)
    word = Column(String, unique=True, index=True, nullable=False)
    media_type = Column(Enum(MediaType), default=MediaType.video)
    file_path = Column(String, nullable=False)
