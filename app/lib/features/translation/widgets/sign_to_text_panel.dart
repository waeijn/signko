import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../gloves/glove_simulator.dart';
import '../../settings/settings_provider.dart';
import '../../history/providers/history_provider.dart';

class SignToTextPanel extends ConsumerStatefulWidget {
  const SignToTextPanel({super.key});

  @override
  ConsumerState<SignToTextPanel> createState() => _SignToTextPanelState();
}

class _SignToTextPanelState extends ConsumerState<SignToTextPanel> {
  final GloveSimulator _simulator = GloveSimulator();
  final FlutterTts _tts = FlutterTts();
  final ScrollController _terminalScrollController = ScrollController();

  StreamSubscription<GloveSensorData>? _subscription;
  final List<String> _terminalLines = [];
  String _currentWord = '';
  String _fullSentence = '';
  String _lastClassifiedLetter = '';
  bool _isRunning = false;
  bool _isTerminalExpanded = false;

  // Confidence simulation
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _simulator.dispose();
    _tts.stop();
    _terminalScrollController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    setState(() {
      _isRunning = true;
      _terminalLines.clear();
      _currentWord = '';
      _fullSentence = '';
      _lastClassifiedLetter = '';
    });

    _addTerminalLine('[SYS] Initializing BLE connection...');
    _addTerminalLine('[SYS] Connected to SignKo ESP32 (Left)');
    _addTerminalLine('[SYS] Connected to SignKo ESP32 (Right)');
    _addTerminalLine('[SYS] TinyML model loaded (v1.2.0)');
    _addTerminalLine('[SYS] Stream active. Awaiting sensor data...');
    _addTerminalLine('');

    _simulator.start(interval: const Duration(milliseconds: 1200));

    _subscription = _simulator.dataStream.listen((data) {
      if (!mounted) return;

      // Add the raw data line to terminal
      final timeStr =
          '${data.timestamp.hour.toString().padLeft(2, '0')}:${data.timestamp.minute.toString().padLeft(2, '0')}:${data.timestamp.second.toString().padLeft(2, '0')}';
      _addTerminalLine('[$timeStr] RX: ${data.rawHex}');

      // Simulate confidence value
      setState(() {
        _confidence = 0.82 + (data.thumb % 18) / 100.0;
        if (_confidence > 0.99) _confidence = 0.97;
        _lastClassifiedLetter = data.classifiedLetter;
      });

      if (data.classifiedLetter == ' ') {
        // Space means end of word
        _addTerminalLine(
            '[ML]  CLASSIFY -> WORD_BREAK (conf: ${_confidence.toStringAsFixed(2)})');
        _addTerminalLine('');

        if (_currentWord.isNotEmpty) {
          final completedWord = _currentWord;
          setState(() {
            _fullSentence += '$completedWord ';
            _currentWord = '';
          });

          // TTS: speak the completed word
          final settings = ref.read(settingsProvider);
          if (settings.speakTranslations) {
            _tts.speak(completedWord);
          }

          // Save to history
          if (settings.saveHistory) {
            ref.read(historyProvider.notifier).addHistory(
                  completedWord,
                  'Spoken English',
                  'Sign to Text',
                );
          }
        }
      } else {
        _addTerminalLine(
            '[ML]  CLASSIFY -> "${data.classifiedLetter}" (conf: ${_confidence.toStringAsFixed(2)})');
        setState(() {
          _currentWord += data.classifiedLetter;
        });
      }
    });
  }

  void _stopSimulation() {
    _simulator.stop();
    _subscription?.cancel();
    _subscription = null;

    if (_currentWord.isNotEmpty) {
      setState(() {
        _fullSentence += '$_currentWord ';
        _currentWord = '';
      });
    }

    _addTerminalLine('');
    _addTerminalLine('[SYS] Stream stopped.');
    _addTerminalLine('[SYS] BLE disconnected.');

    setState(() {
      _isRunning = false;
    });
  }

  void _addTerminalLine(String line) {
    if (!mounted) return;
    setState(() {
      _terminalLines.add(line);
      if (_terminalLines.length > 200) {
        _terminalLines.removeRange(0, _terminalLines.length - 200);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_terminalScrollController.hasClients) {
        _terminalScrollController.animateTo(
          _terminalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildMainTranslationCard(theme),
        ),
        if (settings.showTelemetry) ...[
          const SizedBox(height: 16),
          _buildDockedTerminal(theme),
        ],
      ],
    );
  }

  Widget _buildMainTranslationCard(ThemeData theme) {
    Color confColor;
    if (_confidence >= 0.85) {
      confColor = const Color(0xFF10B981); // Emerald Green
    } else if (_confidence >= 0.70) {
      confColor = Colors.orange;
    } else {
      confColor = Colors.red.shade400; // Soft Crimson Red
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Action Buttons)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      color: _fullSentence.isNotEmpty
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 24,
                    ),
                    onPressed: _fullSentence.isNotEmpty
                        ? () => _tts.speak(_fullSentence.trim())
                        : null,
                    tooltip: 'Speak translation',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: (_fullSentence.isNotEmpty || _currentWord.isNotEmpty || _terminalLines.isNotEmpty)
                          ? Colors.red
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 24,
                    ),
                    onPressed: (_fullSentence.isNotEmpty || _currentWord.isNotEmpty || _terminalLines.isNotEmpty)
                        ? () {
                            setState(() {
                              _fullSentence = '';
                              _currentWord = '';
                              _lastClassifiedLetter = '';
                              _confidence = 0.0;
                              _terminalLines.clear();
                            });
                          }
                        : null,
                    tooltip: 'Reset translation',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (_isRunning) ...[
                    const SizedBox(width: 16),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
              ],
            ],
          ),

          const Spacer(),

          // Translated Text Display
          Center(
            child: _fullSentence.isEmpty && _currentWord.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : theme.colorScheme.primary.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.waving_hand,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ready for Signs',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Start Translating" and perform\ngestures with your SignKo gloves.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '$_fullSentence$_currentWord',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
          ),
          if (_currentWord.isNotEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Spelling: ',
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    _currentWord,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 3.0,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Gesture Visual Box & Confidence Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                // Visual Placeholder Box
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isRunning
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isRunning
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: _isRunning && _lastClassifiedLetter.isNotEmpty
                        ? Text(
                            _lastClassifiedLetter,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Icon(
                            Icons.back_hand,
                            color: _isRunning
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Confidence Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Confidence',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${(_confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: _isRunning ? confColor : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _isRunning ? _confidence : 0,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(confColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Primary Action Button (Start/Stop)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isRunning ? _stopSimulation : _startSimulation,
              icon: Icon(
                _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                size: 24,
              ),
              label: Text(
                _isRunning ? 'Stop Translating' : 'Start Translating',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning
                    ? Colors.red.shade600
                    : theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockedTerminal(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Slate/Black
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]),
      child: Column(
        children: [
          // Collapsed Header (Tap to toggle)
          InkWell(
            onTap: () {
              setState(() {
                _isTerminalExpanded = !_isTerminalExpanded;
              });
            },
            borderRadius: _isTerminalExpanded
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Icon(Icons.terminal, size: 18, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Telemetry',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Live Dot
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _isRunning ? const Color(0xFF10B981) : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _isRunning ? 'Live • 50 Hz' : 'Offline',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _isRunning ? const Color(0xFF10B981) : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(width: 8),
                  Icon(
                    _isTerminalExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Log Body
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              height: _isTerminalExpanded ? 200 : 0,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                color: _isTerminalExpanded
                    ? Colors.grey.shade800
                    : Colors.transparent,
              ))),
              child: _terminalLines.isEmpty
                  ? Center(
                      child: Text(
                        'Press Start to begin receiving sensor data.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _terminalScrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _terminalLines.length,
                      itemBuilder: (context, index) {
                        final line = _terminalLines[index];
                        Color lineColor;
                        if (line.startsWith('[SYS]')) {
                          lineColor = Colors.cyanAccent;
                        } else if (line.startsWith('[ML]')) {
                          lineColor = const Color(0xFF10B981); // Emerald Green
                        } else if (line.isEmpty) {
                          return const SizedBox(height: 4);
                        } else {
                          lineColor = const Color(0xFF94A3B8); // Slate Gray
                        }

                        return Text(
                          line,
                          style: TextStyle(
                            color: lineColor,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
