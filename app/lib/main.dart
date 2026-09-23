import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignKo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          'SignKo Bidirectional Translation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
