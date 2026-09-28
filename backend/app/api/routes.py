from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import get_api_key
from app.models.translation import TranslationRecord
from app.schemas.translation import TranslationRequest, TranslationResponse, TranslationCreate

router = APIRouter()

@router.post("/translate", response_model=TranslationResponse)
def translate_text(request: TranslationRequest, db: Session = Depends(get_db), api_key: str = Depends(get_api_key)):
    # 1. Normalize the text (lowercase and strip spaces)
    text = request.text.lower().strip()
    
    # 2. Query the PostgreSQL database for a matching translation
    record = db.query(TranslationRecord).filter(TranslationRecord.source_text == text).first()
    
    # 3. If found, return the mapped video. Otherwise, fallback to a default video.
    video_url = record.video_url if record else "assets/videos/default.mp4"
    
    return TranslationResponse(
        original_text=request.text,
        video_url=video_url
    )

@router.post("/seed", response_model=dict)
def add_translation(translation: TranslationCreate, db: Session = Depends(get_db), api_key: str = Depends(get_api_key)):
    """
    Endpoint to easily add new words and videos to the database via Swagger UI.
    """
    # Check if it already exists
    existing = db.query(TranslationRecord).filter(TranslationRecord.source_text == translation.source_text.lower().strip()).first()
    if existing:
        raise HTTPException(status_code=400, detail="Translation already exists")

    new_record = TranslationRecord(
        source_text=translation.source_text.lower().strip(),
        video_url=translation.video_url
    )
    db.add(new_record)
    db.commit()
    return {"message": f"Successfully added translation for '{new_record.source_text}'!"}
