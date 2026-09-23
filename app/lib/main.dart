import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/splash/splash_view.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling async methods
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local offline storage
  await Hive.initFlutter();
  
  // Wrap the entire app in a ProviderScope to enable Riverpod
  runApp(const ProviderScope(child: SignKoApp()));
}

class SignKoApp extends StatelessWidget {
  const SignKoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignKo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashView(),
    );
  }
}
