from fastapi import FastAPI
from pydantic import BaseModel

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
def translate_text(request: TranslationRequest):
    # TODO: Implement actual NLP processing and database lookup here
    # For now, we return a mock video URL for testing the frontend
    text = request.text
    
    return TranslationResponse(
        original_text=text,
        video_url="https://www.w3schools.com/html/mov_bbb.mp4" # Sample MP4 video
    )
