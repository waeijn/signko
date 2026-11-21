import os
import sys

# Add the backend directory to Python path so 'app' can be imported
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from app.core.database import SessionLocal
from app.models.dictionary import Dictionary, MediaType

def seed_dictionary():
    db = SessionLocal()
    try:
        # Complete FSL Vocabulary: 20 Words & Phrases (English & Filipino), Numbers 1-10, and Alphabet A-Z (56 Total Entries)
        vocabulary_items = [
            # 1. Good Day (Magandang Araw)
            {"words": ["good day", "goodday", "magandang araw", "magandangaraw"], "media_type": MediaType.video, "file_path": "assets/videos/good_day.mp4"},
            # 2. Good Night (Magandang Gabi)
            {"words": ["good night", "goodnight", "magandang gabi", "magandanggabi"], "media_type": MediaType.video, "file_path": "assets/videos/good_night.mp4"},
            # 3. Thank You (Salamat)
            {"words": ["thank you", "thankyou", "salamat"], "media_type": MediaType.video, "file_path": "assets/videos/thank_you.mp4"},
            # 4. You're Welcome (Walang anuman)
            {"words": ["youre welcome", "you're welcome", "yourewelcome", "walang anuman", "walanganuman"], "media_type": MediaType.video, "file_path": "assets/videos/youre_welcome.mp4"},
            # 5. Take Care (Ingat ka)
            {"words": ["take care", "takecare", "ingat ka", "ingatka", "ingat"], "media_type": MediaType.video, "file_path": "assets/videos/take_care.mp4"},
            # 6. Sick (May sakit)
            {"words": ["sick", "may sakit", "maysakit"], "media_type": MediaType.video, "file_path": "assets/videos/sick.mp4"},
            # 7. Invent (Imbento)
            {"words": ["invent", "imbento"], "media_type": MediaType.video, "file_path": "assets/videos/invent.mp4"},
            # 8. Read (Basa)
            {"words": ["read", "basa"], "media_type": MediaType.video, "file_path": "assets/videos/read.mp4"},
            # 9. Again (Ulit)
            {"words": ["again", "ulit"], "media_type": MediaType.video, "file_path": "assets/videos/again.mp4"},
            # 10. Why? (Bakit?)
            {"words": ["why", "why?", "bakit", "bakit?"], "media_type": MediaType.video, "file_path": "assets/videos/why.mp4"},
            # 11. Where? (Saan?)
            {"words": ["where", "where?", "saan", "saan?"], "media_type": MediaType.video, "file_path": "assets/videos/where.mp4"},
            # 12. Which? (Alin?)
            {"words": ["which", "which?", "alin", "alin?"], "media_type": MediaType.video, "file_path": "assets/videos/which.mp4"},
            # 13. Yes (Oo)
            {"words": ["yes", "oo"], "media_type": MediaType.video, "file_path": "assets/videos/yes.mp4"},
            # 14. No (Hindi)
            {"words": ["no", "hindi"], "media_type": MediaType.video, "file_path": "assets/videos/no.mp4"},
            # 15. I'm Sorry (Pasensya na)
            {"words": ["im sorry", "i'm sorry", "imsorry", "sorry", "pasensya na", "pasensyana", "pasensya"], "media_type": MediaType.video, "file_path": "assets/videos/sorry.mp4"},
            # 16. I understand (Naiintindihan ko)
            {"words": ["i understand", "iunderstand", "naiintindihan ko", "naiintindihanko"], "media_type": MediaType.video, "file_path": "assets/videos/i_understand.mp4"},
            # 17. I don't understand (Hindi ko naiintindihan)
            {"words": ["i dont understand", "i don't understand", "idontunderstand", "hindi ko naiintindihan", "hindikonaiintindihan"], "media_type": MediaType.video, "file_path": "assets/videos/i_dont_understand.mp4"},
            # 18. I Love You (Mahal kita)
            {"words": ["i love you", "iloveyou", "mahal kita", "mahalkita"], "media_type": MediaType.video, "file_path": "assets/videos/i_love_you.mp4"},
            # 19. Book (Aklat)
            {"words": ["book", "aklat"], "media_type": MediaType.video, "file_path": "assets/videos/book.mp4"},
            # 20. Please (Paki)
            {"words": ["please", "paki"], "media_type": MediaType.video, "file_path": "assets/videos/please.mp4"},

            # FSL Numbers 1 to 10
            {"words": ["1", "one", "isa"], "media_type": MediaType.video, "file_path": "assets/videos/number_1.mp4"},
            {"words": ["2", "two", "dalawa"], "media_type": MediaType.video, "file_path": "assets/videos/number_2.mp4"},
            {"words": ["3", "three", "tatlo"], "media_type": MediaType.video, "file_path": "assets/videos/number_3.mp4"},
            {"words": ["4", "four", "apat"], "media_type": MediaType.video, "file_path": "assets/videos/number_4.mp4"},
            {"words": ["5", "five", "lima"], "media_type": MediaType.video, "file_path": "assets/videos/number_5.mp4"},
            {"words": ["6", "six", "anim"], "media_type": MediaType.video, "file_path": "assets/videos/number_6.mp4"},
            {"words": ["7", "seven", "pito"], "media_type": MediaType.video, "file_path": "assets/videos/number_7.mp4"},
            {"words": ["8", "eight", "walo"], "media_type": MediaType.video, "file_path": "assets/videos/number_8.mp4"},
            {"words": ["9", "nine", "siyam"], "media_type": MediaType.video, "file_path": "assets/videos/number_9.mp4"},
            {"words": ["10", "ten", "sampu"], "media_type": MediaType.video, "file_path": "assets/videos/number_10.mp4"},
        ]

        # FSL Alphabet A-Z (Images)
        for letter in "abcdefghijklmnopqrstuvwxyz":
            vocabulary_items.append({
                "words": [letter],
                "media_type": MediaType.image,
                "file_path": f"assets/images/alphabet/{letter}.png"
            })

        print("Seeding FSL Dictionary...")
        added_count = 0
        updated_count = 0

        for item in vocabulary_items:
            for word in item["words"]:
                normalized_word = word.strip().lower()
                existing = db.query(Dictionary).filter(Dictionary.word == normalized_word).first()
                if existing:
                    existing.media_type = item["media_type"]
                    existing.file_path = item["file_path"]
                    updated_count += 1
                else:
                    new_entry = Dictionary(
                        word=normalized_word,
                        media_type=item["media_type"],
                        file_path=item["file_path"]
                    )
                    db.add(new_entry)
                    added_count += 1

        db.commit()
        print(f"Dictionary seeding completed! Added: {added_count}, Updated: {updated_count}")

    except Exception as e:
        print(f"Error seeding dictionary: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_dictionary()
