from pydantic import BaseModel
from typing import Optional
from app.models.dictionary import MediaType

class DictionaryBase(BaseModel):
    word: str
    media_type: MediaType
    file_path: str

class DictionaryCreate(DictionaryBase):
    pass

class DictionaryResponse(DictionaryBase):
    id: int

    class Config:
        from_attributes = True
