from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.history import HistoryRecord
from app.models.user import User
from app.schemas.history import HistoryCreate, HistoryResponse
from app.api.auth import get_current_user

router = APIRouter(prefix="/history", tags=["History"])

@router.get("/", response_model=List[HistoryResponse])
def get_user_history(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Fetch all translation history for the authenticated user, ordered by newest first.
    """
    records = db.query(HistoryRecord).filter(HistoryRecord.user_id == current_user.id).order_by(HistoryRecord.created_at.desc()).all()
    return records

@router.post("/", response_model=HistoryResponse)
def add_history(item: HistoryCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Save a new translation history record for the user.
    """
    new_record = HistoryRecord(
        user_id=current_user.id,
        source_text=item.source_text,
        translated_text=item.translated_text,
        mode=item.mode
    )
    db.add(new_record)
    db.commit()
    db.refresh(new_record)
    return new_record

@router.delete("/")
def clear_history(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Clear all history for the authenticated user.
    """
    db.query(HistoryRecord).filter(HistoryRecord.user_id == current_user.id).delete()
    db.commit()
    return {"message": "History cleared successfully"}
