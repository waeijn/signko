# SignKo: Bidirectional Filipino Sign Language Translation System

SignKo is a wearable hardware and mobile software ecosystem designed to facilitate real-time, bidirectional communication between Deaf and hard-of-hearing (DHH) Filipino Sign Language (FSL) users and non-signing hearing individuals. The system utilizes ESP32-based sensor gloves to recognize FSL gestures and a Flutter-based mobile application to process text, audio, and visual FSL media.

## Key Features

* **FSL to Text and Speech:** The wearable gloves capture finger flexion and hand orientation data. An embedded TinyML model classifies the data into FSL letters and numbers, transmitting the results via Bluetooth Low Energy (BLE) to the mobile application for text display and Text-to-Speech (TTS) output.
* **Speech/Text to FSL Video/Image:** Non-signers can input text or use the device microphone via Speech-to-Text (STT). The application maps this input to a stored video or image database, playing the corresponding FSL gesture media on the screen.
* **Haptic Alerts:** The mobile application triggers a vibration motor on the glove to notify the DHH user of incoming messages or detected speech.
* **Edge Processing:** Gesture classification runs entirely on the ESP32 microcontroller using Edge Impulse, ensuring low latency and reduced power consumption by transmitting lightweight string data rather than raw sensor streams.
* **Offline Functionality:** Core STT, TTS, and rendering engines utilize on-device libraries, allowing the system to operate without an active internet connection.

## Tech Stack

### Hardware & Embedded Systems
* **Microcontroller:** ESP32 Development Boards (one per glove) for sensor acquisition, processing, and wireless transmission.
* **Sensors:** Resistive Flex Sensors (finger bend angles) and MPU-6050 / BNO085 IMUs (hand spatial orientation).
* **Actuators:** 3V Coin Vibration Motors (haptic feedback for incoming messages).
* **Firmware Environment:** PlatformIO utilizing C/C++.
* **Wireless Protocol:** Bluetooth Low Energy (BLE) configured as a GATT server.

### Machine Learning (TinyML)
* **Development Platform:** Edge Impulse for data collection, feature extraction, and model training.
* **Deployment Format:** Optimized C++ library running inference directly on the ESP32 (Edge AI) to eliminate cloud latency.
* **Model Type:** Lightweight Classifiers (K-Nearest Neighbors or small Neural Networks) optimized for time-series sensor data.

### Mobile Application (Frontend)
* **Framework:** Flutter (Dart) for cross-platform native compilation (iOS/Android).
* **State Management:** Riverpod for managing asynchronous BLE data streams, audio I/O, and UI state synchronization.
* **Hardware Bridge:** `flutter_blue_plus` package for persistent BLE client connections to the gloves.
* **Local Storage:** Isar Database or Hive (embedded NoSQL) for storing offline FSL vocabulary dictionaries and app settings.

### Media Rendering
* **Video/Image Engine:** `video_player` embedded directly in the Flutter view hierarchy for playback of FSL clips.
* **Asset Pipeline:** Pre-recorded `.mp4` video clips and static `.png` images of human actors performing FSL gestures.
* **Speech-to-Text (STT):** `speech_to_text` package invoking device-native offline transcription (Apple `SFSpeechRecognizer` and Android `SpeechRecognizer`).
* **Text-to-Speech (TTS):** `flutter_tts` package utilizing native OS voice synthesizers for offline audio output.

## Repository Structure

```text
signko/
├── embedded/                       # ESP32 firmware and hardware configuration
│   ├── lib/signko_inferencing/     # Edge Impulse TinyML exported library
│   ├── src/                        # Main C++ source files (BLE, sensors, haptics)
│   └── platformio.ini              # Build and dependency settings
├── app/                            # Flutter mobile application codebase
│   ├── assets/videos/              # .mp4 files of FSL gestures
│   ├── assets/images/              # .png files of static FSL signs
│   ├── lib/                        # Dart source code (Features, UI, Services)
│   └── pubspec.yaml                # Flutter dependencies
└── ml_pipeline/                    # Raw sensor datasets and Python data processing scripts
```

## Getting Started

### Hardware Setup

1. Navigate to the `embedded/` directory.
2. Open the project in Visual Studio Code with the PlatformIO extension installed.
3. Connect the ESP32 board via USB.
4. Build and upload the firmware using the PlatformIO interface. Ensure the correct COM port is selected.

### Mobile App Setup

1. Ensure you have the Flutter SDK (version 3.x or higher) installed and configured on your machine.
2. Navigate to the `app/` directory in your terminal.
3. Run `flutter pub get` to fetch all necessary dependencies.
4. Connect a physical Android or iOS device (BLE functionality does not work on emulators).
5. Run `flutter run` to build and deploy the application to your device.

## Usage Instructions

1. Power on the ESP32 sensor gloves.
2. Open the SignKo app on your mobile device and grant Bluetooth and Microphone permissions.
3. Navigate to the **Connect** tab and select the gloves from the list of available BLE devices.
4. Once the status indicates **Connected**, the DHH user can begin signing. Recognized FSL gestures will automatically appear in the chat view and play aloud.
5. The hearing user can tap the microphone icon to speak. The app will transcribe the speech and play the video or display the image of the corresponding FSL sign.

## Contributing
Please refer to the [`.agentrules`](./.agentrules) file for general workspace guidelines, code quality expectations, and commit message conventions.

## License
This project is licensed under the [MIT License](LICENSE).
