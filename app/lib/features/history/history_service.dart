import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationHistoryItem {
  final String text;
  final String mode; // 'Text to Sign' or 'Sign to Text'
  final DateTime timestamp;

  TranslationHistoryItem({
    required this.text,
    required this.mode,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'mode': mode,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TranslationHistoryItem.fromJson(Map<String, dynamic> json) {
    return TranslationHistoryItem(
      text: json['text'],
      mode: json['mode'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class HistoryService {
  static const String _key = 'translation_history';

  static Future<void> saveHistory(TranslationHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyList = prefs.getStringList(_key) ?? [];
    
    // Add new item to the beginning of the list
    historyList.insert(0, jsonEncode(item.toJson()));
    
    // Optional: limit history size (e.g., to 100 items)
    if (historyList.length > 100) {
      historyList.removeLast();
    }
    
    await prefs.setStringList(_key, historyList);
  }

  static Future<List<TranslationHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyList = prefs.getStringList(_key) ?? [];
    
    return historyList.map((item) {
      return TranslationHistoryItem.fromJson(jsonDecode(item));
    }).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
