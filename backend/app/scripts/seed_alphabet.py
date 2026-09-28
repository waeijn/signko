import urllib.request
import json

# The API URL and Key
API_URL = "http://127.0.0.1:8000/seed"
API_KEY = "signko_dev_api_key_998877"

# Alphabet A-Z
alphabet = "abcdefghijklmnopqrstuvwxyz"

for letter in alphabet:
    data = {
        "source_text": letter,
        "media_path": f"assets/images/alphabet/{letter}.png",
        "media_type": "image"
    }
    
    req = urllib.request.Request(API_URL, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("X-API-Key", API_KEY)
    
    try:
        response = urllib.request.urlopen(req, data=json.dumps(data).encode("utf-8"))
        print(f"[SUCCESS] Successfully seeded: {letter.upper()}")
    except urllib.error.HTTPError as e:
        if e.code == 400:
            print(f"[WARNING] {letter.upper()} already exists in database.")
        else:
            print(f"[ERROR] Failed to seed {letter.upper()}: {e}")
