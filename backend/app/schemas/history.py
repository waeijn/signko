from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class HistoryCreate(BaseModel):
    source_text: str
    translated_text: str
    mode: str

class HistoryResponse(BaseModel):
    id: int
    source_text: str
    translated_text: str
    mode: str
    created_at: datetime

    class Config:
        from_attributes = True
