from pydantic import BaseModel

class TranslationRequest(BaseModel):
    text: str

class TranslationResponse(BaseModel):
    original_text: str
    media_path: str
    media_type: str

class TranslationCreate(BaseModel):
    source_text: str
    media_path: str
    media_type: str = "video"
