from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.dictionary import Dictionary
from app.schemas.dictionary import DictionaryResponse, DictionaryCreate
from typing import List

router = APIRouter()

@router.get("/{word}", response_model=DictionaryResponse)
def get_word_mapping(word: str, db: Session = Depends(get_db)):
    # Normalize word: lowercase and strictly alphanumeric
    clean_word = "".join(c for c in word.lower() if c.isalnum())
    
    db_word = db.query(Dictionary).filter(Dictionary.word == clean_word).first()
    if db_word is None:
        raise HTTPException(status_code=404, detail="Word not found in dictionary")
    return db_word

@router.get("/", response_model=List[DictionaryResponse])
def get_all_mappings(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Retrieve the entire dictionary mapping for offline caching on the client."""
    return db.query(Dictionary).offset(skip).limit(limit).all()

@router.post("/", response_model=DictionaryResponse, status_code=status.HTTP_201_CREATED)
def create_word_mapping(mapping: DictionaryCreate, db: Session = Depends(get_db)):
    """Admin route to seed or update the dictionary mappings."""
    clean_word = "".join(c for c in mapping.word.lower() if c.isalnum())
    
    db_word = db.query(Dictionary).filter(Dictionary.word == clean_word).first()
    if db_word:
        # Update existing mapping
        db_word.media_type = mapping.media_type
        db_word.file_path = mapping.file_path
        db.commit()
        db.refresh(db_word)
        return db_word
    else:
        new_word = Dictionary(
            word=clean_word,
            media_type=mapping.media_type,
            file_path=mapping.file_path
        )
        db.add(new_word)
        db.commit()
        db.refresh(new_word)
        return new_word
