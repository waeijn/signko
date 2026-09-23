import 'package:flutter/material.dart';
import '../translation/translation_view.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        // Creating a soft gradient background to mimic the abstract blobs in the design
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.8),
            radius: 1.5,
            colors: [
              Colors.cyan.shade50,
              Colors.white,
              Colors.purple.shade50,
              Colors.white,
              Colors.pink.shade50,
            ],
            stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            
            // Logo Image
            Image.asset(
              'assets/logo.png',
              width: 250,
              fit: BoxFit.contain,
            ),
            
            const Spacer(flex: 2),
            
            // Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
              child: GestureDetector(
                onTap: () {
                  // Navigate to the main Translation View
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const TranslationView(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.orange.shade300],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
