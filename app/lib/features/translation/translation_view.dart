import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import '../account/account_view.dart';
import 'widgets/text_to_sign_panel.dart';
import 'widgets/sign_to_text_panel.dart';
import '../history/providers/history_provider.dart';
import '../settings/settings_provider.dart';

enum TranslationMode { signToText, textToSign }

class TranslationView extends ConsumerStatefulWidget {
  const TranslationView({super.key});

  @override
  ConsumerState<TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends ConsumerState<TranslationView>
    with SingleTickerProviderStateMixin {
  TranslationMode _currentMode = TranslationMode.signToText;
  final TextEditingController _textController = TextEditingController();
  late stt.SpeechToText _speech;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  bool _isTranslating = false;
  bool _showVideoMock = false;
  String _lastSentText = '';
  String? _mediaPath;
  String? _mediaType;
  List<List<String>>? _mediaSequence;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    // Web and Desktop treat 0.5 as half-speed. Android treats 0.5 as normal.
    await _flutterTts.setSpeechRate(kIsWeb ? 0.65 : 0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    final settings = ref.read(settingsProvider);
    if (settings.ttsVoice != null) {
      try {
        final voices = await _flutterTts.getVoices;
        if (voices != null) {
          for (var voice in voices) {
            if (voice is Map && voice['name'] == settings.ttsVoice) {
              await _flutterTts
                  .setVoice({"name": voice['name'], "locale": voice['locale']});
              break;
            }
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _speak(String text) async {
    final settings = ref.read(settingsProvider);
    if (!settings.speakTranslations || text.trim().isEmpty) return;
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Automatically mute/stop the microphone if it was listening when they hit send
    if (_isListening) {
      _speech
          .cancel(); // cancel() prevents the plugin from sending one last onResult callback
      _isListening = false;
      _pulseController.stop();
      _pulseController.reset();
    }

    final settings = ref.read(settingsProvider);

    FocusScope.of(context).unfocus();
    setState(() {
      _isTranslating = true;
      _showVideoMock = false;
      _lastSentText = text;
      _textController.clear();
    });

    if (settings.saveHistory) {
      final modeStr = _currentMode == TranslationMode.textToSign
          ? 'Text to Sign'
          : 'Sign to Text';
      ref.read(historyProvider.notifier).addHistory(text, modeStr == 'Text to Sign' ? 'FSL Translation' : 'Spoken English', modeStr);
    }

    try {
      // Connect to the local FastAPI backend (127.0.0.1 since we are on Web/Edge)
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/translate'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'signko_dev_api_key_998877', // Our secret API key
        },
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mediaPath = data['media_path'];
        final mediaType = data['media_type'];
        final mediaSequence = data['media_sequence'] != null
            ? (data['media_sequence'] as List)
                .map((wordList) => List<String>.from(wordList))
                .toList()
            : null;

        if (mounted) {
          setState(() {
            _mediaPath = mediaPath;
            _mediaType = mediaType;
            _mediaSequence = mediaSequence;
            _isTranslating = false;
            _showVideoMock = true;
          });
          debugPrint(
              'Successfully loaded $mediaType from database: ${mediaPath ?? mediaSequence}');
        }
      } else {
        throw Exception('Failed to translate');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to backend: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            if (mounted) {
              setState(() => _isListening = false);
              _pulseController.stop();
              _pulseController.reset();
            }
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _pulseController.repeat(reverse: true);
        _speech.listen(
          onResult: (val) {
            // Only update text if we are still actively listening
            if (_isListening && mounted) {
              setState(() {
                _textController.text = val.recognizedWords;
              });
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _pulseController.stop();
      _pulseController.reset();
      _speech.cancel(); // cancel() instead of stop() drops late callbacks
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Transform.scale(
              scale:
                  2.5, // Scales up the image to counteract the large 512x512 transparent padding
              child: Image.asset(
                'assets/logo/text.png',
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 28),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AccountView()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            // Toggle Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      context: context,
                      title: 'Sign to Text',
                      icon: Icons.back_hand,
                      isActive: _currentMode == TranslationMode.signToText,
                      onTap: () => setState(
                          () => _currentMode = TranslationMode.signToText),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildToggleButton(
                      context: context,
                      title: 'Text to Sign',
                      icon: Icons.chat_bubble_outline,
                      isActive: _currentMode == TranslationMode.textToSign,
                      onTap: () => setState(
                          () => _currentMode = TranslationMode.textToSign),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Main Content Area (Grey Background)
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _currentMode == TranslationMode.signToText
                            ? SignToTextPanel() // Live simulation panel
                            : Stack(
                                children: [
                                  Positioned.fill(
                                    child: TextToSignPanel(
                                      isTranslating: _isTranslating,
                                      showVideoMock: _showVideoMock,
                                      lastSentText: _lastSentText,
                                      mediaType: _mediaType,
                                      mediaPath: _mediaPath,
                                      mediaSequence: _mediaSequence,
                                    ),
                                  ),
                                  if (_showVideoMock && !_isTranslating)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.refresh,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                        tooltip: 'Reset Translation',
                                        onPressed: () {
                                          setState(() {
                                            _showVideoMock = false;
                                            _lastSentText = '';
                                            _mediaSequence = null;
                                            _mediaPath = null;
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Input Field (Only in Text to Sign mode)
            if (_currentMode == TranslationMode.textToSign)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.1),
                          width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        )
                      ]),
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? 'Listening...'
                          : 'Type something here...',
                      hintStyle: TextStyle(
                          color: _isListening
                              ? Colors.red.withValues(alpha: 0.7)
                              : Colors.grey.shade500),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: _isListening
                                  ? _pulseAnimation
                                  : const AlwaysStoppedAnimation(1.0),
                              child: IconButton(
                                icon: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: _isListening
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: _listen,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: _handleSend,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary : surface,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: onSurface.withValues(alpha: 0.2), width: 1.5),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: isActive
                    ? Theme.of(context).colorScheme.surface
                    : onSurface),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isActive
                    ? Theme.of(context).colorScheme.surface
                    : onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Removed _buildTextToSignPlaceholder since it is now in TextToSignPanel
// Removed _buildSignToTextContent since it is now in SignToTextPanel
}
