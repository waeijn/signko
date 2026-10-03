class HistoryModel {
  final int id;
  final String sourceText;
  final String translatedText;
  final String mode;
  final DateTime createdAt;

  HistoryModel({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.mode,
    required this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      sourceText: json['source_text'],
      translatedText: json['translated_text'],
      mode: json['mode'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}
