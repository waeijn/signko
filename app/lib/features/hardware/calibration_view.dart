import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CalibrationView extends ConsumerStatefulWidget {
  const CalibrationView({super.key});

  @override
  ConsumerState<CalibrationView> createState() => _CalibrationViewState();
}

class _CalibrationViewState extends ConsumerState<CalibrationView>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isProcessing = false;
  double _calibrationProgress = 0.0;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _processStep() async {
    setState(() {
      _isProcessing = true;
      _calibrationProgress = 0.0;
    });

    // Simulate connection/calibration process over 3 seconds
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() {
          _calibrationProgress = i / 100;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
        if (_currentStep < 3) {
          _currentStep++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Glove Calibration', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isActive = index <= _currentStep;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 32 : 16,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),

              // Dynamic Step Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildStepContent(isDark, theme),
                ),
              ),

              // Action Button
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing || _currentStep == 3 ? () => Navigator.pop(context) : _processStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStep == 3 
                        ? const Color(0xFF10B981) 
                        : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _getButtonText(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0: return 'Connect Gloves';
      case 1: return 'Calibrate Open Hand';
      case 2: return 'Calibrate Fist';
      case 3: return 'Finish';
      default: return 'Next';
    }
  }

  Widget _buildStepContent(bool isDark, ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildStepCard(
          key: const ValueKey(0),
          title: 'Pair via Bluetooth',
          description: 'Turn on your SignKo Gloves and ensure Bluetooth is enabled on your device.',
          icon: Icons.bluetooth_searching,
          isDark: isDark,
          theme: theme,
        );
      case 1:
        return _buildStepCard(
          key: const ValueKey(1),
          title: 'Rest Pose',
          description: 'Hold your hand completely open and relaxed. Keep your fingers straight.',
          icon: Icons.pan_tool_outlined,
          isDark: isDark,
          theme: theme,
          showProgress: _isProcessing,
        );
      case 2:
        return _buildStepCard(
          key: const ValueKey(2),
          title: 'Fist Pose',
          description: 'Close your hand tightly into a fist. Hold steady until calibration completes.',
          icon: Icons.back_hand,
          isDark: isDark,
          theme: theme,
          showProgress: _isProcessing,
        );
      case 3:
        return _buildStepCard(
          key: const ValueKey(3),
          title: 'Calibration Complete',
          description: 'Your gloves are successfully calibrated and ready for accurate sign translation!',
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF10B981),
          isDark: isDark,
          theme: theme,
          animatePulse: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepCard({
    required Key key,
    required String title,
    required String description,
    required IconData icon,
    Color? iconColor,
    required bool isDark,
    required ThemeData theme,
    bool showProgress = false,
    bool animatePulse = true,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2642) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3357) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showProgress)
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _calibrationProgress,
                    strokeWidth: 8,
                    backgroundColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                    color: theme.colorScheme.primary,
                  ),
                  Center(
                    child: Icon(icon, size: 48, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            )
          else
            ScaleTransition(
              scale: animatePulse ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
            ),
          const SizedBox(height: 40),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
