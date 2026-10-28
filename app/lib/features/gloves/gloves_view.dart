import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ble_service.dart';
import '../hardware/calibration_view.dart';

class GlovesView extends ConsumerWidget {
  const GlovesView({super.key});

  void _triggerTestHaptic(
    BuildContext context,
    WidgetRef ref,
    GloveHapticPattern pattern,
  ) {
    ref.read(bleServiceProvider).sendHaptic(
          pattern,
          reason: 'Hardware Test Panel',
        );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sent ${pattern.label} (${pattern.hexCode}) to connected gloves',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Hardware',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.indigo.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.bluetooth_connected,
                    size: 48, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'SignKo Gloves Connected',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Battery: 85% • Signal: Strong',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Paired Devices',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Mock Device List
          _buildDeviceTile(
              context, 'SignKo ESP32 (Left)', 'Connected', Colors.green),
          const SizedBox(height: 12),
          _buildDeviceTile(
              context, 'SignKo ESP32 (Right)', 'Connected', Colors.green),
          const SizedBox(height: 32),
          // Haptic Feedback Test Section
          const Text(
            'Haptic Feedback Test',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a test vibration pulse to verify the glove actuators.',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHapticTestButton(
                  context,
                  label: 'Short',
                  subtitle: '100ms',
                  icon: Icons.vibration,
                  onTap: () => _triggerTestHaptic(
                    context,
                    ref,
                    GloveHapticPattern.shortPulse,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHapticTestButton(
                  context,
                  label: 'Double',
                  subtitle: '2x 150ms',
                  icon: Icons.notifications_active_outlined,
                  onTap: () => _triggerTestHaptic(
                    context,
                    ref,
                    GloveHapticPattern.doublePulse,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHapticTestButton(
                  context,
                  label: 'Alert',
                  subtitle: '500ms',
                  icon: Icons.warning_amber_rounded,
                  onTap: () => _triggerTestHaptic(
                    context,
                    ref,
                    GloveHapticPattern.longAlert,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Pair Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalibrationView()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Pair & Calibrate Gloves'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHapticTestButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceTile(
      BuildContext context, String name, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.back_hand,
                color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}
