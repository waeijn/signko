class LocalTranslationResult {
  final String? mediaPath;
  final String mediaType;
  final List<List<String>>? mediaSequence;

  const LocalTranslationResult({
    this.mediaPath,
    required this.mediaType,
    this.mediaSequence,
  });
}

/// Offline-first local FSL dictionary engine.
/// Provides deterministic zero-latency translation across all 56 predefined vocabulary items
/// (20 bilingual phrases, 10 numbers, and 26 alphabet fingerspelling characters) without
/// requiring an active network connection or external database container.
class LocalFslDictionary {
  static final Map<String, String> _phraseToVideo = {
    // 1. Good Day (Magandang Araw)
    'good day': 'assets/videos/good_day.mp4',
    'goodday': 'assets/videos/good_day.mp4',
    'magandang araw': 'assets/videos/good_day.mp4',
    'magandangaraw': 'assets/videos/good_day.mp4',

    // 2. Good Night (Magandang Gabi)
    'good night': 'assets/videos/good_night.mp4',
    'goodnight': 'assets/videos/good_night.mp4',
    'magandang gabi': 'assets/videos/good_night.mp4',
    'magandanggabi': 'assets/videos/good_night.mp4',

    // 3. Thank You (Salamat)
    'thank you': 'assets/videos/thank_you.mp4',
    'thankyou': 'assets/videos/thank_you.mp4',
    'salamat': 'assets/videos/thank_you.mp4',

    // 4. You're Welcome (Walang anuman)
    'youre welcome': 'assets/videos/youre_welcome.mp4',
    "you're welcome": 'assets/videos/youre_welcome.mp4',
    'yourewelcome': 'assets/videos/youre_welcome.mp4',
    'walang anuman': 'assets/videos/youre_welcome.mp4',
    'walanganuman': 'assets/videos/youre_welcome.mp4',

    // 5. Take Care (Ingat ka)
    'take care': 'assets/videos/take_care.mp4',
    'takecare': 'assets/videos/take_care.mp4',
    'ingat ka': 'assets/videos/take_care.mp4',
    'ingatka': 'assets/videos/take_care.mp4',
    'ingat': 'assets/videos/take_care.mp4',

    // 6. Sick (May sakit)
    'sick': 'assets/videos/sick.mp4',
    'may sakit': 'assets/videos/sick.mp4',
    'maysakit': 'assets/videos/sick.mp4',

    // 7. Invent (Imbento)
    'invent': 'assets/videos/invent.mp4',
    'imbento': 'assets/videos/invent.mp4',

    // 8. Read (Basa)
    'read': 'assets/videos/read.mp4',
    'basa': 'assets/videos/read.mp4',

    // 9. Again (Ulit)
    'again': 'assets/videos/again.mp4',
    'ulit': 'assets/videos/again.mp4',

    // 10. Why? (Bakit?)
    'why': 'assets/videos/why.mp4',
    'bakit': 'assets/videos/why.mp4',

    // 11. Where? (Saan?)
    'where': 'assets/videos/where.mp4',
    'saan': 'assets/videos/where.mp4',

    // 12. Which? (Alin?)
    'which': 'assets/videos/which.mp4',
    'alin': 'assets/videos/which.mp4',

    // 13. Yes (Oo)
    'yes': 'assets/videos/yes.mp4',
    'oo': 'assets/videos/yes.mp4',

    // 14. No (Hindi)
    'no': 'assets/videos/no.mp4',
    'hindi': 'assets/videos/no.mp4',

    // 15. I'm Sorry (Pasensya na)
    'im sorry': 'assets/videos/sorry.mp4',
    "i'm sorry": 'assets/videos/sorry.mp4',
    'imsorry': 'assets/videos/sorry.mp4',
    'sorry': 'assets/videos/sorry.mp4',
    'pasensya na': 'assets/videos/sorry.mp4',
    'pasensyana': 'assets/videos/sorry.mp4',
    'pasensya': 'assets/videos/sorry.mp4',

    // 16. I understand (Naiintindihan ko)
    'i understand': 'assets/videos/i_understand.mp4',
    'iunderstand': 'assets/videos/i_understand.mp4',
    'naiintindihan ko': 'assets/videos/i_understand.mp4',
    'naiintindihanko': 'assets/videos/i_understand.mp4',

    // 17. I don't understand (Hindi ko naiintindihan)
    'i dont understand': 'assets/videos/i_dont_understand.mp4',
    "i don't understand": 'assets/videos/i_dont_understand.mp4',
    'idontunderstand': 'assets/videos/i_dont_understand.mp4',
    'hindi ko naiintindihan': 'assets/videos/i_dont_understand.mp4',
    'hindikonaiintindihan': 'assets/videos/i_dont_understand.mp4',

    // 18. I Love You (Mahal kita)
    'i love you': 'assets/videos/i_love_you.mp4',
    'iloveyou': 'assets/videos/i_love_you.mp4',
    'mahal kita': 'assets/videos/i_love_you.mp4',
    'mahalkita': 'assets/videos/i_love_you.mp4',

    // 19. Book (Aklat)
    'book': 'assets/videos/book.mp4',
    'aklat': 'assets/videos/book.mp4',

    // 20. Please (Paki)
    'please': 'assets/videos/please.mp4',
    'paki': 'assets/videos/please.mp4',

    // Numbers 1 to 10
    '1': 'assets/videos/number_1.mp4',
    'one': 'assets/videos/number_1.mp4',
    'isa': 'assets/videos/number_1.mp4',
    '2': 'assets/videos/number_2.mp4',
    'two': 'assets/videos/number_2.mp4',
    'dalawa': 'assets/videos/number_2.mp4',
    '3': 'assets/videos/number_3.mp4',
    'three': 'assets/videos/number_3.mp4',
    'tatlo': 'assets/videos/number_3.mp4',
    '4': 'assets/videos/number_4.mp4',
    'four': 'assets/videos/number_4.mp4',
    'apat': 'assets/videos/number_4.mp4',
    '5': 'assets/videos/number_5.mp4',
    'five': 'assets/videos/number_5.mp4',
    'lima': 'assets/videos/number_5.mp4',
    '6': 'assets/videos/number_6.mp4',
    'six': 'assets/videos/number_6.mp4',
    'anim': 'assets/videos/number_6.mp4',
    '7': 'assets/videos/number_7.mp4',
    'seven': 'assets/videos/number_7.mp4',
    'pito': 'assets/videos/number_7.mp4',
    '8': 'assets/videos/number_8.mp4',
    'eight': 'assets/videos/number_8.mp4',
    'walo': 'assets/videos/number_8.mp4',
    '9': 'assets/videos/number_9.mp4',
    'nine': 'assets/videos/number_9.mp4',
    'siyam': 'assets/videos/number_9.mp4',
    '10': 'assets/videos/number_10.mp4',
    'ten': 'assets/videos/number_10.mp4',
    'sampu': 'assets/videos/number_10.mp4',
  };

  /// Translates input text into either an exact FSL video asset path or a fingerspelling sequence.
  static LocalTranslationResult translate(String rawInput) {
    final rawText = rawInput.toLowerCase().trim();
    if (rawText.isEmpty) {
      return const LocalTranslationResult(
        mediaPath: 'assets/videos/default.mp4',
        mediaType: 'video',
      );
    }

    // Normalization matching backend logic
    final cleanAlphanumeric = rawText.replaceAll(RegExp(r'[^a-z0-9]'), '');
    final normalizedPhrase = rawText
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 1. Exact match check
    if (_phraseToVideo.containsKey(rawText)) {
      return LocalTranslationResult(
        mediaPath: _phraseToVideo[rawText],
        mediaType: 'video',
      );
    }
    if (_phraseToVideo.containsKey(normalizedPhrase)) {
      return LocalTranslationResult(
        mediaPath: _phraseToVideo[normalizedPhrase],
        mediaType: 'video',
      );
    }
    if (_phraseToVideo.containsKey(cleanAlphanumeric)) {
      return LocalTranslationResult(
        mediaPath: _phraseToVideo[cleanAlphanumeric],
        mediaType: 'video',
      );
    }

    // 2. Fallback: Fingerspelling Sequence
    final words = rawText.split(RegExp(r'\s+'));
    final List<List<String>> sequence = [];

    for (final word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^a-z]'), '');
      if (cleanWord.isNotEmpty) {
        sequence.add(cleanWord.split('').map((c) => 'assets/images/alphabet/$c.png').toList());
      }
    }

    if (sequence.isNotEmpty) {
      return LocalTranslationResult(
        mediaType: 'sequence',
        mediaSequence: sequence,
      );
    }

    // 3. Fallback for non-alphabetic characters
    return const LocalTranslationResult(
      mediaPath: 'assets/videos/default.mp4',
      mediaType: 'video',
    );
  }

  /// Set of all supported dynamic words/phrases for UI chip filtering
  static Set<String> get supportedVocabulary => _phraseToVideo.keys.toSet();
}
