import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provides a synchronous instance of SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main.dart');
});

class SettingsState {
  final bool autoTranslate;
  final bool speakTranslations;
  final bool saveHistory;
  final bool isDarkMode;
  final bool showTelemetry;
  final String? ttsVoice;

  SettingsState({
    required this.autoTranslate,
    required this.speakTranslations,
    required this.saveHistory,
    required this.isDarkMode,
    required this.showTelemetry,
    this.ttsVoice,
  });

  SettingsState copyWith({
    bool? autoTranslate,
    bool? speakTranslations,
    bool? saveHistory,
    bool? isDarkMode,
    bool? showTelemetry,
    String? ttsVoice,
  }) {
    return SettingsState(
      autoTranslate: autoTranslate ?? this.autoTranslate,
      speakTranslations: speakTranslations ?? this.speakTranslations,
      saveHistory: saveHistory ?? this.saveHistory,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      showTelemetry: showTelemetry ?? this.showTelemetry,
      ttsVoice: ttsVoice ?? this.ttsVoice,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences prefs;

  SettingsNotifier(this.prefs)
      : super(SettingsState(
          autoTranslate: prefs.getBool('autoTranslate') ?? true,
          speakTranslations: prefs.getBool('speakTranslations') ?? true,
          saveHistory: prefs.getBool('saveHistory') ?? true,
          isDarkMode: prefs.getBool('isDarkMode') ?? false,
          showTelemetry: prefs.getBool('showTelemetry') ?? false,
          ttsVoice: prefs.getString('ttsVoice'),
        ));

  void toggleAutoTranslate(bool value) {
    prefs.setBool('autoTranslate', value);
    state = state.copyWith(autoTranslate: value);
  }

  void toggleSpeakTranslations(bool value) {
    prefs.setBool('speakTranslations', value);
    state = state.copyWith(speakTranslations: value);
  }

  void setTtsVoice(String value) {
    prefs.setString('ttsVoice', value);
    state = state.copyWith(ttsVoice: value);
  }

  void toggleSaveHistory(bool value) {
    prefs.setBool('saveHistory', value);
    state = state.copyWith(saveHistory: value);
  }

  void toggleDarkMode(bool value) {
    prefs.setBool('isDarkMode', value);
    state = state.copyWith(isDarkMode: value);
  }

  void toggleShowTelemetry(bool value) {
    prefs.setBool('showTelemetry', value);
    state = state.copyWith(showTelemetry: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
