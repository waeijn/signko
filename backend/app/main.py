from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import engine
from app.models import translation
from app.api.routes import router

# Auto-create all tables in the database when the app starts
translation.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="SignKo Backend",
    description="Backend API for translating text to Filipino Sign Language videos",
    version="1.0.0"
)

# Set up CORS middleware to restrict access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # In production, restrict this to your mobile app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include our API routes
app.include_router(router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the SignKo Backend API"}
