import os
import sys

# Add the backend directory to Python path so 'app' can be imported
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from app.core.database import SessionLocal
from app.models.dictionary import Dictionary, MediaType

def seed_dictionary():
    db = SessionLocal()
    try:
        # Initial mock dictionary mappings
        initial_words = [
            {"word": "hello", "media_type": MediaType.video, "file_path": "assets/videos/hello.mp4"},
            {"word": "world", "media_type": MediaType.video, "file_path": "assets/videos/world.mp4"},
            {"word": "thankyou", "media_type": MediaType.video, "file_path": "assets/videos/thank_you.mp4"},
            {"word": "please", "media_type": MediaType.video, "file_path": "assets/videos/please.mp4"},
            {"word": "sorry", "media_type": MediaType.video, "file_path": "assets/videos/sorry.mp4"},
        ]

        print("Seeding FSL Dictionary...")
        for entry in initial_words:
            existing_word = db.query(Dictionary).filter(Dictionary.word == entry["word"]).first()
            if not existing_word:
                new_mapping = Dictionary(
                    word=entry["word"],
                    media_type=entry["media_type"],
                    file_path=entry["file_path"]
                )
                db.add(new_mapping)
                print(f"Added mapping for '{entry['word']}'")
            else:
                print(f"Mapping for '{entry['word']}' already exists.")
        
        db.commit()
        print("Dictionary seeding complete!")
        
    except Exception as e:
        print(f"Error seeding dictionary: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_dictionary()
