# SignKo: Bidirectional Filipino Sign Language Translation System

SignKo is a wearable hardware and mobile software ecosystem designed to facilitate real-time, bidirectional communication between Deaf and hard-of-hearing (DHH) Filipino Sign Language (FSL) users and non-signing hearing individuals. The system utilizes ESP32-based sensor gloves to recognize FSL gestures and a Flutter-based mobile application to process text, audio, and visual FSL media.

## Key Features

- **FSL to Text and Speech:** The wearable gloves capture finger flexion and hand orientation data. An embedded TinyML model classifies the data into FSL letters and numbers, transmitting the results via Bluetooth Low Energy (BLE) to the mobile application for text display and Text-to-Speech (TTS) output.
- **Speech/Text to FSL Video/Image:** Non-signers can input text or use the device microphone via Speech-to-Text (STT). The application maps this input to a stored video or image database, playing the corresponding FSL gesture media on the screen.
- **Haptic Alerts:** The mobile application triggers a vibration motor on the glove to notify the DHH user of incoming messages or detected speech.
- **Edge Processing:** Gesture classification runs entirely on the ESP32 microcontroller using Edge Impulse, ensuring low latency and reduced power consumption by transmitting lightweight string data rather than raw sensor streams.
- **Offline Functionality:** Core STT, TTS, and rendering engines utilize on-device libraries, allowing the system to operate without an active internet connection.

## Tech Stack

### Hardware & Embedded Systems

- **Microcontroller:** ESP32 Development Boards (one per glove) for sensor acquisition, processing, and wireless transmission.
- **Sensors:** Resistive Flex Sensors (finger bend angles) and MPU-6050 / BNO085 IMUs (hand spatial orientation).
- **Actuators:** 3V Coin Vibration Motors (haptic feedback for incoming messages).
- **Firmware Environment:** PlatformIO utilizing C/C++.
- **Wireless Protocol:** Bluetooth Low Energy (BLE) configured as a GATT server.

### Machine Learning (TinyML)

- **Development Platform:** Edge Impulse for data collection, feature extraction, and model training.
- **Deployment Format:** Optimized C++ library running inference directly on the ESP32 (Edge AI) to eliminate cloud latency.
- **Model Type:** **1D Convolutional Neural Network (1D CNN)** optimized for spatial-temporal time-series sensor data from the gloves.

### Mobile Application (Frontend)

- **Framework:** Flutter (Dart) for cross-platform native compilation (iOS/Android).
- **State Management:** Riverpod for managing asynchronous BLE data streams, audio I/O, and UI state synchronization.
- **Hardware Bridge:** `flutter_blue_plus` package for persistent BLE client connections to the gloves.
- **Local Storage:** `shared_preferences` for storing offline translation history and app settings (Dark Mode, TTS preferences).

### Media Rendering & Backend

- **Video/Image Engine:** Responsive UI panels embedded directly in the Flutter view hierarchy for playback of FSL clips and fingerspelling grid arrays.
- **Backend API:** FastAPI (Python) running on Docker, handling phrase splitting, normalization, and translation logic.
- **Database:** PostgreSQL used for seeding and querying the FSL dictionary (alphabet, numbers, and dynamic words).
- **Asset Pipeline:** Pre-recorded `.mp4` video clips and static `.png` images served dynamically based on translation logic.
- **Speech-to-Text (STT):** `speech_to_text` package invoking device-native offline transcription (Apple `SFSpeechRecognizer` and Android `SpeechRecognizer`).
- **Text-to-Speech (TTS):** Native integrations planned for offline audio output of translations.

## Repository Structure

```text
signko/
├── embedded/                       # ESP32 firmware and hardware configuration
│   ├── lib/signko_inferencing/     # Edge Impulse TinyML exported library
│   ├── src/                        # Main C++ source files (BLE, sensors, haptics)
│   └── platformio.ini              # Build and dependency settings
├── backend/                        # FastAPI Python backend & Database
│   ├── app/                        # API routes, schemas, models, and scripts
│   └── Dockerfile                  # Containerization for backend
├── app/                            # Flutter mobile application codebase
│   ├── assets/                     # .png and .mp4 files for FSL media
│   ├── lib/                        # Dart source code (Features, UI, Services)
│   └── pubspec.yaml                # Flutter dependencies
├── docker-compose.yml              # Orchestrates FastAPI and PostgreSQL containers
└── ml_pipeline/                    # Raw sensor datasets and Python data processing scripts
```

## Getting Started (Windows)

We have automated scripts to get the entire stack (Flutter + Docker + FastAPI + Postgres) running locally in minutes.

### Prerequisites

1. **Docker Desktop** (must be running)
2. **Flutter SDK** (must be in your PATH)
3. **Microsoft Edge** or **Google Chrome** (for web testing)

### Initial Setup (One-time)

Clone the repository and run the setup script from your terminal (PowerShell):

```powershell
# Installs Flutter dependencies, builds Docker images, and seeds the PostgreSQL database
.\setup.ps1
```

### Starting the Environment

Whenever you want to work on the app, simply run the start script. This will boot the Docker backend and launch the Flutter app in Microsoft Edge automatically:

```powershell
.\start_all.ps1
```

To gracefully shut down the backend and clean up, run:

```powershell
.\stop_all.ps1
```

### Hardware Setup (Optional for UI Dev)

1. Navigate to the `embedded/` directory.
2. Open the project in Visual Studio Code with the PlatformIO extension installed.
3. Connect the ESP32 board via USB.
4. Build and upload the firmware using the PlatformIO interface. Ensure the correct COM port is selected.

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
