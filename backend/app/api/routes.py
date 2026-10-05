from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import get_api_key
from app.models.translation import TranslationRecord
from app.models.dictionary import Dictionary, MediaType
from app.schemas.translation import TranslationRequest, TranslationResponse, TranslationCreate

router = APIRouter()

@router.post("/translate", response_model=TranslationResponse)
def translate_text(request: TranslationRequest, db: Session = Depends(get_db), api_key: str = Depends(get_api_key)):
    # 1. Normalize the text (lowercase and strip spaces)
    text = request.text.lower().strip()
    
    # 2. Query the PostgreSQL dictionary for a matching translation
    record = db.query(Dictionary).filter(Dictionary.word == text).first()
    
    # 3. If found, return the mapped media.
    if record:
        return TranslationResponse(
            original_text=request.text,
            media_path=record.file_path,
            media_type=record.media_type.value
        )
    
    # 4. Fallback: Fingerspelling Sequence
    # We split by spaces to handle multiple words, so they can be on new lines
    words = text.split()
    sequence = []
    
    for word in words:
        clean_word = "".join([c for c in word if c.isalpha()])
        if len(clean_word) > 0:
            sequence.append([f"assets/images/alphabet/{c}.png" for c in clean_word])
            
    if len(sequence) > 0:
        return TranslationResponse(
            original_text=request.text,
            media_type="sequence",
            media_sequence=sequence
        )
        
    # 5. Ultimate fallback if text is empty or non-alphabetical
    return TranslationResponse(
        original_text=request.text,
        media_path="assets/videos/default.mp4",
        media_type="video"
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
        media_path=translation.media_path,
        media_type=translation.media_type
    )
    db.add(new_record)
    db.commit()
    return {"message": f"Successfully added translation for '{new_record.source_text}'!"}
