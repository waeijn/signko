# Filipino Sign Language (FSL) Vocabulary & Dataset Reference

This document outlines the official Filipino Sign Language (FSL) dataset supported by the SignKo ecosystem. It defines the mapping between human language input (English and Filipino/Tagalog), normalized database lookup keys, and the corresponding media assets rendered in the mobile application.

---

## Translation Architecture & Media Fallback

SignKo uses a tiered resolution system for Text-to-Sign translation:

1. **Exact Dictionary Match (Video):**
   * The backend queries PostgreSQL for full phrases or words.
   * If an entry is found with `media_type: video`, the app plays the pre-recorded FSL video demonstration (`.mp4`).
2. **Fingerspelling Sequence (Images):**
   * If a word or phrase is not present in the pre-recorded video database, the translation engine falls back to breaking the input into individual characters.
   * Characters are mapped to static fingerspelling image assets (`assets/images/alphabet/{letter}.png`) and displayed as interactive cards.
3. **Punctuation and Space Invariance:**
   * Lookups cross-check raw input, space-normalized phrases without punctuation, and compact alphanumeric strings to ensure seamless matching regardless of user input style (e.g., "Why?", "why", "I'm sorry", "im sorry").

---

## 1. FSL Words and Phrases (30 Items)

Each entry supports both English and Filipino inputs, as well as colloquial and space-condensed variants.

| # | English Term | Filipino / Tagalog Term | Database Query Keys | Target Asset Path |
|---|--------------|-------------------------|---------------------|-------------------|
| 1 | Good Day | Magandang Araw | `good day`, `goodday`, `magandang araw`, `magandangaraw` | `assets/videos/good_day.mp4` |
| 2 | Good Night | Magandang Gabi | `good night`, `goodnight`, `magandang gabi`, `magandanggabi` | `assets/videos/good_night.mp4` |
| 3 | Thank You | Salamat | `thank you`, `thankyou`, `salamat` | `assets/videos/thank_you.mp4` |
| 4 | You're Welcome | Walang anuman | `youre welcome`, `you're welcome`, `yourewelcome`, `walang anuman`, `walanganuman` | `assets/videos/youre_welcome.mp4` |
| 5 | Take Care | Ingat ka | `take care`, `takecare`, `ingat ka`, `ingatka`, `ingat` | `assets/videos/take_care.mp4` |
| 6 | Sick | May sakit | `sick`, `may sakit`, `maysakit` | `assets/videos/sick.mp4` |
| 7 | Invent | Imbento | `invent`, `imbento` | `assets/videos/invent.mp4` |
| 8 | House | Bahay | `house`, `bahay` | `assets/videos/house.mp4` |
| 9 | Read | Basa | `read`, `basa` | `assets/videos/read.mp4` |
| 10 | Again | Ulit | `again`, `ulit` | `assets/videos/again.mp4` |
| 11 | Why? | Bakit? | `why`, `why?`, `bakit`, `bakit?` | `assets/videos/why.mp4` |
| 12 | Where? | Saan? | `where`, `where?`, `saan`, `saan?` | `assets/videos/where.mp4` |
| 13 | Which? | Alin? | `which`, `which?`, `alin`, `alin?` | `assets/videos/which.mp4` |
| 14 | Friend | Kaibigan | `friend`, `kaibigan` | `assets/videos/friend.mp4` |
| 15 | Who? | Sino? | `who`, `who?`, `sino`, `sino?` | `assets/videos/who.mp4` |
| 16 | Sweetheart | Sweetheart | `sweetheart` | `assets/videos/sweetheart.mp4` |
| 17 | Yes | Oo | `yes`, `oo` | `assets/videos/yes.mp4` |
| 18 | No | Hindi | `no`, `hindi` | `assets/videos/no.mp4` |
| 19 | I'm Sorry | Pasensya na | `im sorry`, `i'm sorry`, `imsorry`, `sorry`, `pasensya na`, `pasensyana`, `pasensya` | `assets/videos/sorry.mp4` |
| 20 | When? | Kailan? | `when`, `when?`, `kailan`, `kailan?` | `assets/videos/when.mp4` |
| 21 | I understand | Naiintindihan ko | `i understand`, `iunderstand`, `naiintindihan ko`, `naiintindihanko` | `assets/videos/i_understand.mp4` |
| 22 | I'm going home | Uwi na ako | `im going home`, `i'm going home`, `imgoinghome`, `uwi na ako`, `uwinaako` | `assets/videos/im_going_home.mp4` |
| 23 | I don't understand | Hindi ko naiintindihan | `i dont understand`, `i don't understand`, `idontunderstand`, `hindi ko naiintindihan`, `hindikonaiintindihan` | `assets/videos/i_dont_understand.mp4` |
| 24 | Lecture | Lektyur | `lecture`, `lektyur` | `assets/videos/lecture.mp4` |
| 25 | School | Paaralan | `school`, `paaralan` | `assets/videos/school.mp4` |
| 26 | I don't care | Wala akong pakialam | `i dont care`, `i don't care`, `idontcare`, `wala akong pakialam`, `walaakongpakialam` | `assets/videos/i_dont_care.mp4` |
| 27 | I Love You | Mahal kita | `i love you`, `iloveyou`, `mahal kita`, `mahalkita` | `assets/videos/i_love_you.mp4` |
| 28 | Book | Aklat | `book`, `aklat` | `assets/videos/book.mp4` |
| 29 | I Hate You | Galit ako sayo | `i hate you`, `ihateyou`, `galit ako sayo`, `galitakosayo` | `assets/videos/i_hate_you.mp4` |
| 30 | Please | Paki | `please`, `paki` | `assets/videos/please.mp4` |

---

## 2. FSL Numbers (1 to 10)

Numbers are supported in digit format, English word format, and Filipino/Tagalog word format.

| Number | English Word | Filipino Word | Database Query Keys | Target Asset Path |
|--------|--------------|---------------|---------------------|-------------------|
| 1 | One | Isa | `1`, `one`, `isa` | `assets/videos/number_1.mp4` |
| 2 | Two | Dalawa | `2`, `two`, `dalawa` | `assets/videos/number_2.mp4` |
| 3 | Three | Tatlo | `3`, `three`, `tatlo` | `assets/videos/number_3.mp4` |
| 4 | Four | Apat | `4`, `four`, `apat` | `assets/videos/number_4.mp4` |
| 5 | Five | Lima | `5`, `five`, `lima` | `assets/videos/number_5.mp4` |
| 6 | Six | Anim | `6`, `six`, `anim` | `assets/videos/number_6.mp4` |
| 7 | Seven | Pito | `7`, `seven`, `pito` | `assets/videos/number_7.mp4` |
| 8 | Eight | Walo | `8`, `eight`, `walo` | `assets/videos/number_8.mp4` |
| 9 | Nine | Siyam | `9`, `nine`, `siyam` | `assets/videos/number_9.mp4` |
| 10 | Ten | Sampu | `10`, `ten`, `sampu` | `assets/videos/number_10.mp4` |

---

## 3. FSL Alphabet (Aa to Zz)

Fingerspelling images provide character-by-character visual breakdowns for unmapped words or names.

| Letter | Media Type | Asset Path |
|--------|------------|------------|
| A | Image | `assets/images/alphabet/a.png` |
| B | Image | `assets/images/alphabet/b.png` |
| C | Image | `assets/images/alphabet/c.png` |
| D | Image | `assets/images/alphabet/d.png` |
| E | Image | `assets/images/alphabet/e.png` |
| F | Image | `assets/images/alphabet/f.png` |
| G | Image | `assets/images/alphabet/g.png` |
| H | Image | `assets/images/alphabet/h.png` |
| I | Image | `assets/images/alphabet/i.png` |
| J | Image | `assets/images/alphabet/j.png` |
| K | Image | `assets/images/alphabet/k.png` |
| L | Image | `assets/images/alphabet/l.png` |
| M | Image | `assets/images/alphabet/m.png` |
| N | Image | `assets/images/alphabet/n.png` |
| O | Image | `assets/images/alphabet/o.png` |
| P | Image | `assets/images/alphabet/p.png` |
| Q | Image | `assets/images/alphabet/q.png` |
| R | Image | `assets/images/alphabet/r.png` |
| S | Image | `assets/images/alphabet/s.png` |
| T | Image | `assets/images/alphabet/t.png` |
| U | Image | `assets/images/alphabet/u.png` |
| V | Image | `assets/images/alphabet/v.png` |
| W | Image | `assets/images/alphabet/w.png` |
| X | Image | `assets/images/alphabet/x.png` |
| Y | Image | `assets/images/alphabet/y.png` |
| Z | Image | `assets/images/alphabet/z.png` |

---

## Database Seeding Instructions

To populate or refresh these mappings in the local PostgreSQL database, run:

```powershell
.\seed_db.ps1
```

Or execute directly inside the running backend container:

```bash
docker compose exec backend python app/scripts/seed_dictionary.py
```
