import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from app.core.database import SessionLocal, engine
from app.models.user import User, Base
from app.core.security import get_password_hash

def seed_default_user():
    print("Creating tables if they don't exist...")
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        email = "dev@signko.com"
        print(f"Checking if user {email} exists...")
        user = db.query(User).filter(User.email == email).first()
        
        if user:
            print("Default dev user already exists.")
            return
            
        print("Creating default dev user...")
        new_user = User(
            email=email,
            name="Developer User",
            hashed_password=get_password_hash("password")
        )
        db.add(new_user)
        db.commit()
        print("Successfully created default user!")
        print(f"Email: {email}")
        print("Password: password")
    except Exception as e:
        print(f"Error seeding user: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_default_user()
