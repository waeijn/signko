import 'package:flutter/material.dart';
import '../auth/views/login_view.dart';

class OnboardingData {
  final String title;
  final String description;
  final IconData? icon;
  final bool isLogo;

  OnboardingData({
    required this.title,
    required this.description,
    this.icon,
    this.isLogo = false,
  });
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      isLogo: true,
      title: 'SignKo',
      description: 'Bridging Filipino Sign Language to voice and text in real time.',
    ),
    OnboardingData(
      icon: Icons.sync_alt_rounded,
      title: 'Two-Way Translation',
      description: 'Translate signs to speech instantly, and watch spoken words turn into sign language videos.',
    ),
    OnboardingData(
      icon: Icons.bolt_rounded,
      title: 'Offline & Zero Latency',
      description: 'Powered by on-device TinyML. Experience real-time translation without needing an internet connection.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  Widget _buildDot(int index, ThemeData theme, bool isDark) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 24 : 6,
      decoration: BoxDecoration(
        color: isActive 
            ? theme.colorScheme.primary 
            : (isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFEBF2FF),
      body: Stack(
        children: [
          // 1. Fixed Backgrounds (Split Tier)
          Column(
            children: [
              Expanded(
                flex: 55,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
                          : [const Color(0xFFF1F5F9), const Color(0xFFDBEAFE)], // Slightly deeper blue/slate to contrast with white sheet
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 45,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                            ? Colors.black.withValues(alpha: 0.4) 
                            : const Color(0xFF0F172A).withValues(alpha: 0.08),
                        blurRadius: 32,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. Sliding Content (Images and Text)
          SafeArea(
            bottom: false,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Column(
                  children: [
                    // Top Graphic
                    Expanded(
                      flex: 55,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient glowing orb
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark 
                                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                        : theme.colorScheme.primary.withValues(alpha: 0.08), // Use a soft blue glow for Light Mode instead of invisible white
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            if (page.isLogo)
                              Image.asset(
                                'assets/logo/logo.png',
                                height: 210,
                                fit: BoxFit.contain,
                              )
                            else
                              Icon(
                                page.icon,
                                size: 120,
                                color: theme.colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Text Content
                    Expanded(
                      flex: 45,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
                        child: Column(
                          children: [
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 280,
                              child: Text(
                                page.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant, // Richer Slate 600
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 3. Fixed UI Overlay (Dots and Button)
          Positioned(
            left: 32,
            right: 32,
            bottom: 32 + MediaQuery.of(context).padding.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dot Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildDot(index, theme, isDark),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Primary Action Button
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
