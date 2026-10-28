import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vibration patterns supported by the SignKo ESP32 Glove firmware (`haptics.h`).
enum GloveHapticPattern {
  off(0x00, 'Stop Vibration'),
  shortPulse(0x01, 'Short Pulse (100ms)'),
  doublePulse(0x02, 'Double Pulse (2x 150ms)'),
  longAlert(0x03, 'Long Alert (500ms)');

  final int commandByte;
  final String label;

  const GloveHapticPattern(this.commandByte, this.label);

  String get hexCode => '0x${commandByte.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

/// Represents a haptic command event dispatched to the SignKo gloves.
class GloveHapticEvent {
  final GloveHapticPattern pattern;
  final String reason;
  final DateTime timestamp;

  GloveHapticEvent({
    required this.pattern,
    required this.reason,
    required this.timestamp,
  });
}

/// A Riverpod provider to access the BleService instance globally.
final bleServiceProvider = Provider<BleService>((ref) {
  final service = BleService();
  ref.onDispose(service.dispose);
  return service;
});

class BleService {
  static const String serviceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String telemetryCharacteristicUuid =
      '0000ffe1-0000-1000-8000-00805f9b34fb';
  static const String hapticCharacteristicUuid =
      '0000ffe2-0000-1000-8000-00805f9b34fb';

  final StreamController<GloveHapticEvent> _hapticEventController =
      StreamController<GloveHapticEvent>.broadcast();

  /// Broadcast stream of outgoing haptic events for telemetry logging and UI feedback.
  Stream<GloveHapticEvent> get hapticEventStream =>
      _hapticEventController.stream;

  /// Stream of incoming TinyML gesture classifications from the gloves.
  Stream<String> get gestureStream {
    return const Stream.empty();
  }

  /// Sends a single-byte haptic vibration command to the connected ESP32 gloves.
  Future<void> sendHaptic(
    GloveHapticPattern pattern, {
    String reason = 'Manual Trigger',
  }) async {
    final event = GloveHapticEvent(
      pattern: pattern,
      reason: reason,
      timestamp: DateTime.now(),
    );

    if (!_hapticEventController.isClosed) {
      _hapticEventController.add(event);
    }

    debugPrint(
      '[BLE] TX Haptic (${pattern.hexCode} - ${pattern.label}) | Reason: $reason',
    );
  }

  void dispose() {
    _hapticEventController.close();
  }
}
