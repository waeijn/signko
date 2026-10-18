import os
import sys

# Add the backend directory to Python path so 'app' can be imported
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from app.core.database import SessionLocal
from app.models.dictionary import Dictionary, MediaType

def seed_dictionary():
    db = SessionLocal()
    try:
        # Complete FSL Vocabulary: 30 Words & Phrases (English & Filipino), Numbers 1-10, and Alphabet A-Z
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
            # 8. House (Bahay)
            {"words": ["house", "bahay"], "media_type": MediaType.video, "file_path": "assets/videos/house.mp4"},
            # 9. Read (Basa)
            {"words": ["read", "basa"], "media_type": MediaType.video, "file_path": "assets/videos/read.mp4"},
            # 10. Again (Ulit)
            {"words": ["again", "ulit"], "media_type": MediaType.video, "file_path": "assets/videos/again.mp4"},
            # 11. Why? (Bakit?)
            {"words": ["why", "why?", "bakit", "bakit?"], "media_type": MediaType.video, "file_path": "assets/videos/why.mp4"},
            # 12. Where? (Saan?)
            {"words": ["where", "where?", "saan", "saan?"], "media_type": MediaType.video, "file_path": "assets/videos/where.mp4"},
            # 13. Which? (Alin?)
            {"words": ["which", "which?", "alin", "alin?"], "media_type": MediaType.video, "file_path": "assets/videos/which.mp4"},
            # 14. Friend (Kaibigan)
            {"words": ["friend", "kaibigan"], "media_type": MediaType.video, "file_path": "assets/videos/friend.mp4"},
            # 15. Who? (Sino?)
            {"words": ["who", "who?", "sino", "sino?"], "media_type": MediaType.video, "file_path": "assets/videos/who.mp4"},
            # 16. Sweetheart
            {"words": ["sweetheart"], "media_type": MediaType.video, "file_path": "assets/videos/sweetheart.mp4"},
            # 17. Yes (Oo)
            {"words": ["yes", "oo"], "media_type": MediaType.video, "file_path": "assets/videos/yes.mp4"},
            # 18. No (Hindi)
            {"words": ["no", "hindi"], "media_type": MediaType.video, "file_path": "assets/videos/no.mp4"},
            # 19. I'm Sorry (Pasensya na)
            {"words": ["im sorry", "i'm sorry", "imsorry", "sorry", "pasensya na", "pasensyana", "pasensya"], "media_type": MediaType.video, "file_path": "assets/videos/sorry.mp4"},
            # 20. When? (Kailan?)
            {"words": ["when", "when?", "kailan", "kailan?"], "media_type": MediaType.video, "file_path": "assets/videos/when.mp4"},
            # 21. I understand (Naiintindihan ko)
            {"words": ["i understand", "iunderstand", "naiintindihan ko", "naiintindihanko"], "media_type": MediaType.video, "file_path": "assets/videos/i_understand.mp4"},
            # 22. I'm going home (Uwi na ako)
            {"words": ["im going home", "i'm going home", "imgoinghome", "uwi na ako", "uwinaako"], "media_type": MediaType.video, "file_path": "assets/videos/im_going_home.mp4"},
            # 23. I don't understand (Hindi ko naiintindihan)
            {"words": ["i dont understand", "i don't understand", "idontunderstand", "hindi ko naiintindihan", "hindikonaiintindihan"], "media_type": MediaType.video, "file_path": "assets/videos/i_dont_understand.mp4"},
            # 24. Lecture (Lektyur)
            {"words": ["lecture", "lektyur"], "media_type": MediaType.video, "file_path": "assets/videos/lecture.mp4"},
            # 25. School (Paaralan)
            {"words": ["school", "paaralan"], "media_type": MediaType.video, "file_path": "assets/videos/school.mp4"},
            # 26. I don't care (Wala akong pakialam)
            {"words": ["i dont care", "i don't care", "idontcare", "wala akong pakialam", "walaakongpakialam"], "media_type": MediaType.video, "file_path": "assets/videos/i_dont_care.mp4"},
            # 27. I Love You (Mahal kita)
            {"words": ["i love you", "iloveyou", "mahal kita", "mahalkita"], "media_type": MediaType.video, "file_path": "assets/videos/i_love_you.mp4"},
            # 28. Aklat (Book)
            {"words": ["book", "aklat"], "media_type": MediaType.video, "file_path": "assets/videos/book.mp4"},
            # 29. I Hate You (Galit ako sayo)
            {"words": ["i hate you", "ihateyou", "galit ako sayo", "galitakosayo"], "media_type": MediaType.video, "file_path": "assets/videos/i_hate_you.mp4"},
            # 30. Please (Paki)
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

        for entry in vocabulary_items:
            for word_variant in entry["words"]:
                clean_variant = word_variant.lower().strip()
                existing_word = db.query(Dictionary).filter(Dictionary.word == clean_variant).first()
                if not existing_word:
                    new_mapping = Dictionary(
                        word=clean_variant,
                        media_type=entry["media_type"],
                        file_path=entry["file_path"]
                    )
                    db.add(new_mapping)
                    added_count += 1
                else:
                    existing_word.media_type = entry["media_type"]
                    existing_word.file_path = entry["file_path"]
                    updated_count += 1
        
        db.commit()
        print(f"Dictionary seeding complete. Added: {added_count}, Updated: {updated_count}")
        
    except Exception as e:
        print(f"Error seeding dictionary: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_dictionary()
