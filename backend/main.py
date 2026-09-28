from fastapi import FastAPI, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
import models
from database import engine, get_db

# Auto-create all tables in the database when the app starts
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="SignKo Backend",
    description="Backend API for translating text to Filipino Sign Language videos",
    version="1.0.0"
)

class TranslationRequest(BaseModel):
    text: str

class TranslationResponse(BaseModel):
    original_text: str
    video_url: str

@app.get("/")
def read_root():
    return {"message": "Welcome to the SignKo Backend API"}

@app.post("/translate", response_model=TranslationResponse)
def translate_text(request: TranslationRequest, db: Session = Depends(get_db)):
    # 1. Normalize the text (e.g., lowercase)
    text = request.text.lower().strip()
    
    # 2. Query the PostgreSQL database for a matching translation
    record = db.query(models.TranslationRecord).filter(models.TranslationRecord.source_text == text).first()
    
    # 3. If found, return the mapped video. Otherwise, fallback to a default video.
    video_url = record.video_url if record else "https://www.w3schools.com/html/mov_bbb.mp4"
    
    return TranslationResponse(
        original_text=request.text,
        video_url=video_url
    )
