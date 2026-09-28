import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/splash/splash_view.dart';
import 'features/settings/settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling async methods
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local offline storage
  await Hive.initFlutter();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Wrap the entire app in a ProviderScope to enable Riverpod
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SignKoApp(),
    ),
  );
}

class SignKoApp extends ConsumerWidget {
  const SignKoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the dark mode setting from our persistent settings provider
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    return MaterialApp(
      title: 'SignKo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashView(),
    );
  }
}
