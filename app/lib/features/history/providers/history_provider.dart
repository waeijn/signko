import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_model.dart';
import '../../../core/api_service.dart';

class HistoryState {
  final List<HistoryModel> items;
  final bool isLoading;
  final String? error;

  HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<HistoryModel>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(HistoryState()) {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiService.get('/history/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final items = data.map((item) => HistoryModel.fromJson(item)).toList();
        state = state.copyWith(items: items, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to fetch history');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error');
    }
  }

  Future<void> addHistory(String sourceText, String translatedText, String mode) async {
    try {
      final response = await ApiService.post('/history/', {
        'source_text': sourceText,
        'translated_text': translatedText,
        'mode': mode,
      });

      if (response.statusCode == 200) {
        final newItem = HistoryModel.fromJson(jsonDecode(response.body));
        // Add to the top of the list
        state = state.copyWith(items: [newItem, ...state.items]);
      }
    } catch (e) {
      // Silently fail if unable to save history
    }
  }

  Future<void> clearHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await ApiService.delete('/history/');
      if (response.statusCode == 200) {
        state = state.copyWith(items: [], isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to clear history');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error');
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});
