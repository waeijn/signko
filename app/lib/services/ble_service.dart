import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // TODO: Uncomment when building BLE logic

/// A Riverpod provider to access the BleService instance globally
final bleServiceProvider = Provider<BleService>((ref) {
  return BleService();
});

class BleService {
  // TODO: Add methods to scan for ESP32 gloves
  
  // TODO: Add methods to connect and discover GATT services
  
  // TODO: Create a Stream to listen to incoming TinyML gesture classifications from the gloves
  Stream<String> get gestureStream {
    // Placeholder stream
    return const Stream.empty();
  }
}
