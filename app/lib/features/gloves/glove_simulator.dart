import 'dart:async';
import 'dart:math';

/// Simulates raw sensor data from an ESP32 BLE glove.
/// In the final product, this class will be replaced by a real
/// BLE connection that reads characteristic values from the hardware.
class GloveSimulator {
  final Random _random = Random();
  Timer? _timer;
  final StreamController<GloveSensorData> _controller =
      StreamController<GloveSensorData>.broadcast();

  Stream<GloveSensorData> get dataStream => _controller.stream;

  // The alphabet sequence we cycle through during simulation
  static const List<String> _signSequence = [
    'H', 'E', 'L', 'L', 'O', ' ',
    'W', 'O', 'R', 'L', 'D', ' ',
    'T', 'H', 'A', 'N', 'K', ' ',
    'Y', 'O', 'U', ' ',
  ];

  // Realistic flex sensor ranges per letter (degrees 0-180)
  // Each letter maps to a characteristic "hand shape" as 5 flex values
  static const Map<String, List<int>> _letterFlexProfiles = {
    'A': [170, 170, 170, 170, 90],
    'B': [10, 10, 10, 10, 170],
    'C': [90, 90, 90, 90, 90],
    'D': [10, 170, 170, 170, 170],
    'E': [170, 170, 170, 170, 170],
    'F': [10, 10, 170, 10, 10],
    'G': [10, 170, 170, 170, 170],
    'H': [10, 10, 170, 170, 170],
    'I': [170, 170, 170, 10, 170],
    'J': [170, 170, 170, 10, 170],
    'K': [10, 10, 170, 170, 170],
    'L': [10, 170, 170, 170, 10],
    'M': [170, 170, 170, 170, 170],
    'N': [170, 170, 170, 170, 170],
    'O': [120, 120, 120, 120, 120],
    'P': [10, 10, 170, 170, 170],
    'Q': [10, 170, 170, 170, 170],
    'R': [10, 10, 170, 170, 170],
    'S': [170, 170, 170, 170, 170],
    'T': [170, 10, 170, 170, 170],
    'U': [10, 10, 170, 170, 170],
    'V': [10, 10, 170, 170, 170],
    'W': [10, 10, 10, 170, 170],
    'X': [170, 90, 170, 170, 170],
    'Y': [10, 170, 170, 170, 10],
    'Z': [10, 170, 170, 170, 170],
    ' ': [0, 0, 0, 0, 0],
  };

  int _sequenceIndex = 0;

  /// Start streaming simulated data at the given interval.
  void start({Duration interval = const Duration(milliseconds: 800)}) {
    _sequenceIndex = 0;
    _timer = Timer.periodic(interval, (_) {
      if (_controller.isClosed) return;

      final letter = _signSequence[_sequenceIndex % _signSequence.length];
      final baseProfile = _letterFlexProfiles[letter] ?? [0, 0, 0, 0, 0];

      // Add noise to simulate real analog sensor jitter
      final flexValues = baseProfile.map((v) {
        final noise = _random.nextInt(15) - 7; // +/- 7 degrees
        return (v + noise).clamp(0, 180);
      }).toList();

      final gyroX = (_random.nextDouble() * 4) - 2; // -2.0 to 2.0
      final gyroY = (_random.nextDouble() * 4) - 2;
      final gyroZ = (_random.nextDouble() * 4) - 2;

      _controller.add(GloveSensorData(
        thumb: flexValues[0],
        index: flexValues[1],
        middle: flexValues[2],
        ring: flexValues[3],
        pinky: flexValues[4],
        gyroX: double.parse(gyroX.toStringAsFixed(2)),
        gyroY: double.parse(gyroY.toStringAsFixed(2)),
        gyroZ: double.parse(gyroZ.toStringAsFixed(2)),
        classifiedLetter: letter,
        timestamp: DateTime.now(),
      ));

      _sequenceIndex++;
    });
  }

  /// Stop the simulation.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Clean up resources.
  void dispose() {
    stop();
    _controller.close();
  }
}

/// A single snapshot of sensor data from the glove hardware.
class GloveSensorData {
  final int thumb;
  final int index;
  final int middle;
  final int ring;
  final int pinky;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final String classifiedLetter;
  final DateTime timestamp;

  GloveSensorData({
    required this.thumb,
    required this.index,
    required this.middle,
    required this.ring,
    required this.pinky,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.classifiedLetter,
    required this.timestamp,
  });

  /// Formatted string that mimics what a real BLE characteristic read looks like.
  String get rawHex {
    return 'F:${thumb.toString().padLeft(3, '0')},${index.toString().padLeft(3, '0')},${middle.toString().padLeft(3, '0')},${ring.toString().padLeft(3, '0')},${pinky.toString().padLeft(3, '0')} | G:$gyroX,$gyroY,$gyroZ';
  }
}
