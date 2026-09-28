from pydantic import BaseModel
from typing import List, Optional

class TranslationRequest(BaseModel):
    text: str

class TranslationResponse(BaseModel):
    original_text: str
    media_path: Optional[str] = None
    media_type: str
    media_sequence: Optional[List[List[str]]] = None

class TranslationCreate(BaseModel):
    source_text: str
    media_path: str
    media_type: str = "video"
