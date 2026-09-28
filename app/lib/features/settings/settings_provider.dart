import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provides a synchronous instance of SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main.dart');
});

class SettingsState {
  final bool autoTranslate;
  final bool saveHistory;
  final bool isDarkMode;

  SettingsState({
    required this.autoTranslate,
    required this.saveHistory,
    required this.isDarkMode,
  });

  SettingsState copyWith({
    bool? autoTranslate,
    bool? saveHistory,
    bool? isDarkMode,
  }) {
    return SettingsState(
      autoTranslate: autoTranslate ?? this.autoTranslate,
      saveHistory: saveHistory ?? this.saveHistory,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences prefs;

  SettingsNotifier(this.prefs)
      : super(SettingsState(
          autoTranslate: prefs.getBool('autoTranslate') ?? true,
          saveHistory: prefs.getBool('saveHistory') ?? true,
          isDarkMode: prefs.getBool('isDarkMode') ?? false,
        ));

  void toggleAutoTranslate(bool value) {
    prefs.setBool('autoTranslate', value);
    state = state.copyWith(autoTranslate: value);
  }

  void toggleSaveHistory(bool value) {
    prefs.setBool('saveHistory', value);
    state = state.copyWith(saveHistory: value);
  }

  void toggleDarkMode(bool value) {
    prefs.setBool('isDarkMode', value);
    state = state.copyWith(isDarkMode: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
