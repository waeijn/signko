from pydantic import BaseModel

class TranslationRequest(BaseModel):
    text: str

class TranslationResponse(BaseModel):
    original_text: str
    video_url: str

class TranslationCreate(BaseModel):
    source_text: str
    video_url: str
