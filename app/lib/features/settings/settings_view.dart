import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'settings_provider.dart';

class VoiceOption {
  final String label;
  final Map<String, String> rawVoice;

  VoiceOption({required this.label, required this.rawVoice});
}

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final FlutterTts _flutterTts = FlutterTts();
  List<VoiceOption> _voiceOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchVoices();
  }

  Future<void> _fetchVoices() async {
    try {
      var voices = await _flutterTts.getVoices;

      // Web workaround: Wait for browser's SpeechSynthesis to populate voices asynchronously
      if ((voices == null || (voices is List && voices.isEmpty)) && mounted) {
        await Future.delayed(const Duration(milliseconds: 1500));
        voices = await _flutterTts.getVoices;
      }

      if (voices == null) return;

      final List<Map<String, String>> parsedVoices = [];
      for (var voice in voices) {
        if (voice is Map) {
          parsedVoices.add({
            'name': voice['name']?.toString() ?? '',
            'locale': voice['locale']?.toString() ?? '',
          });
        }
      }

      // 1. Locale Filter: Broaden to ANY English to prevent vanishing on en-GB or similar browsers
      var englishVoices = parsedVoices.where((v) {
        if (v['name']!.isEmpty) return false;
        final loc = v['locale']!.toLowerCase().replaceAll('_', '-');
        return loc.startsWith('en');
      }).toList();

      if (englishVoices.isEmpty) {
        englishVoices = parsedVoices; // Fallback to all voices if no English
      }

      // 2. Offline Priority
      var offlineVoices = englishVoices.where((v) {
        final name = v['name']!.toLowerCase();
        return name.contains('local') || !name.contains('network');
      }).toList();

      if (offlineVoices.isEmpty) {
        offlineVoices = englishVoices;
      }

      // 3. Gender & Acoustic Code Curating
      final femaleIds = [
        'sfg',
        'tpf',
        'iob',
        'tpc',
        'female',
        'zira',
        'aria',
        'samantha',
        'karen',
        'victoria'
      ];
      final maleIds = [
        'iom',
        'tpd',
        'iol',
        'sfb',
        'male',
        'david',
        'mark',
        'aaron',
        'arthur',
        'fred'
      ];

      List<VoiceOption> curated = [];

      // Used hyphens instead of unicode bullets to prevent encoding corruption
      final Map<String, String> femaleLabels = {
        'Female - Soft': '',
        'Female - Crisp': '',
      };
      final Map<String, String> maleLabels = {
        'Male - Deep': '',
        'Male - Clear': '',
      };

      for (var v in offlineVoices) {
        final name = v['name']!.toLowerCase();

        bool isFemale = false;
        bool isMale = false;

        // Ensure 'male' does not accidentally match 'female'
        if (femaleIds.any((id) => name.contains(id))) {
          isFemale = true;
        } else if (maleIds
            .any((id) => name.replaceAll('female', '').contains(id))) {
          isMale = true;
        }

        if (isFemale && femaleLabels.isNotEmpty) {
          final label = femaleLabels.keys.first;
          femaleLabels.remove(label);
          curated.add(VoiceOption(label: label, rawVoice: v));
        } else if (isMale && maleLabels.isNotEmpty) {
          final label = maleLabels.keys.first;
          maleLabels.remove(label);
          curated.add(VoiceOption(label: label, rawVoice: v));
        }

        if (curated.length >= 4) break;
      }

      // 4. OEM Fallback
      if (curated.isEmpty) {
        for (int i = 0; i < offlineVoices.length && i < 4; i++) {
          curated.add(VoiceOption(
              label: 'English Voice ${i + 1}', rawVoice: offlineVoices[i]));
        }
      }

      // 5. Ultimate Fallback (ensures dropdown never completely vanishes)
      if (curated.isEmpty) {
        curated.add(VoiceOption(
            label: 'System Default',
            rawVoice: {'name': 'default', 'locale': 'en-US'}));
      }

      if (mounted) {
        setState(() {
          _voiceOptions = curated;
        });

        // Automatically set the first curated voice as the active default upon initialization
        final settingsNotifier = ref.read(settingsProvider.notifier);
        final currentVoice = ref.read(settingsProvider).ttsVoice;

        if (curated.isNotEmpty &&
            (currentVoice == null ||
                !curated.any((opt) => opt.rawVoice['name'] == currentVoice))) {
          settingsNotifier.setTtsVoice(curated.first.rawVoice['name']!);
        }
      }
    } catch (e) {
      debugPrint("Error fetching TTS voices: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text('PREFERENCES',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildSwitchTile(context, 'Dark Mode', settings.isDarkMode, (v) {
            settingsNotifier.toggleDarkMode(v);
          }),
          _buildSwitchTile(
              context, 'Save translation history', settings.saveHistory, (v) {
            settingsNotifier.toggleSaveHistory(v);
          }),
          _buildSwitchTile(
              context, 'Auto-translate Sign to Text', settings.autoTranslate,
              (v) {
            settingsNotifier.toggleAutoTranslate(v);
          }),
          _buildSwitchTile(context, 'Speak translations aloud (TTS)',
              settings.speakTranslations, (v) {
            settingsNotifier.toggleSpeakTranslations(v);
            if (!v) {
              _flutterTts.stop();
            }
          }),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: settings.speakTranslations && _voiceOptions.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.volume_up_outlined,
                                color: Colors.grey.shade500, size: 20),
                            const SizedBox(width: 12),
                            const Text('Voice',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          height:
                              36, // Compact height matching standard switches
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _voiceOptions.any((o) =>
                                      o.rawVoice['name'] == settings.ttsVoice)
                                  ? settings.ttsVoice
                                  : _voiceOptions.first.rawVoice['name'],
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              dropdownColor:
                                  Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(16),
                              alignment: AlignmentDirectional.centerEnd,
                              items: _voiceOptions.map((option) {
                                return DropdownMenuItem<String>(
                                  value: option.rawVoice['name'],
                                  child: Text(option.label),
                                );
                              }).toList(),
                              onChanged: (String? newName) async {
                                if (newName != null &&
                                    newName != settings.ttsVoice) {
                                  settingsNotifier.setTtsVoice(newName);
                                  final option = _voiceOptions.firstWhere(
                                      (o) => o.rawVoice['name'] == newName);
                                  await _flutterTts.stop();
                                  await Future.delayed(
                                      const Duration(milliseconds: 100));
                                  await _flutterTts.setVoice({
                                    "name": option.rawVoice['name']!,
                                    "locale": option.rawVoice['locale']!
                                  });
                                  await _flutterTts
                                      .speak("Hello, voice selected.");
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          _buildSwitchTile(context, 'Show Gloves Telemetry', settings.showTelemetry, (v) {
            settingsNotifier.toggleShowTelemetry(v);
          }),
          const SizedBox(height: 32),
          const Text('HARDWARE',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildListTile('Calibrate Gloves', Icons.pan_tool_outlined),
          _buildListTile('Firmware Update', Icons.system_update_outlined),
          const SizedBox(height: 32),
          const Text('ABOUT',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildListTile('Help & FAQ', Icons.help_outline),
          _buildListTile('Privacy Policy', Icons.privacy_tip_outlined),
          _buildListTile('About SignKo', Icons.info_outline),
          const SizedBox(height: 40),
          Center(
            child: Text('Version 1.0.0',
                style: TextStyle(color: Colors.grey.shade400)),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
