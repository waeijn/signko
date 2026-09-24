import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

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
          _buildSwitchTile(
              context, 'Auto-translate Sign to Text', true, (v) {}),
          _buildSwitchTile(
              context, 'Speak translations aloud (TTS)', true, (v) {}),
          _buildSwitchTile(context, 'Save translation history', true, (v) {}),
          _buildSwitchTile(context, 'Dark Mode', isDarkMode, (v) {
            ref.read(themeModeProvider.notifier).state =
                v ? ThemeMode.dark : ThemeMode.light;
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
