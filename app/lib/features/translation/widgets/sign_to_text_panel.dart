import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
      // Keep terminal buffer at a reasonable size
      if (_terminalLines.length > 200) {
        _terminalLines.removeRange(0, _terminalLines.length - 200);
      }
    });

    // Auto-scroll to bottom
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Translated Output Card --
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TRANSLATED TEXT',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Row(
                    children: [
                      // Speaker button
                      IconButton(
                        icon: Icon(
                          Icons.volume_up,
                          color: _fullSentence.isNotEmpty
                              ? theme.colorScheme.primary
                              : Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: _fullSentence.isNotEmpty
                            ? () => _tts.speak(_fullSentence.trim())
                            : null,
                        tooltip: 'Speak translation',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      // Reset button
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: (_fullSentence.isNotEmpty || _currentWord.isNotEmpty)
                              ? Colors.red
                              : Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: (_fullSentence.isNotEmpty || _currentWord.isNotEmpty)
                            ? () {
                                setState(() {
                                  _fullSentence = '';
                                  _currentWord = '';
                                  _lastClassifiedLetter = '';
                                  _confidence = 0.0;
                                });
                              }
                            : null,
                        tooltip: 'Reset translation',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // Live indicator
                      if (_isRunning) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _fullSentence.isEmpty && _currentWord.isEmpty
                    ? 'Waiting for input...'
                    : '$_fullSentence$_currentWord',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _fullSentence.isEmpty && _currentWord.isEmpty
                      ? Colors.grey.shade400
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (_currentWord.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Spelling: ',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                    Text(
                      _currentWord,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // -- Confidence & Last Letter Row --
        if (_isRunning)
          Row(
            children: [
              // Last classified letter
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  _lastClassifiedLetter.isEmpty
                      ? '?'
                      : _lastClassifiedLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Confidence bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _confidence,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _confidence > 0.9
                              ? Colors.green
                              : _confidence > 0.7
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),

        // -- Terminal Header --
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.terminal, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'SENSOR DATA STREAM',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            // Start / Stop button
            SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                onPressed: _isRunning ? _stopSimulation : _startSimulation,
                icon: Icon(
                    _isRunning ? Icons.stop : Icons.play_arrow,
                    size: 16),
                label: Text(_isRunning ? 'Stop' : 'Start',
                    style: const TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isRunning ? Colors.red : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // -- Terminal Window --
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                        lineColor = Colors.greenAccent;
                      } else if (line.isEmpty) {
                        return const SizedBox(height: 4);
                      } else {
                        lineColor = Colors.grey.shade400;
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
    );
  }
}
