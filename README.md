# SignKo: Bidirectional Filipino Sign Language Translation System

SignKo is a wearable hardware and mobile software ecosystem designed to facilitate real-time, bidirectional communication between Deaf and hard-of-hearing (DHH) Filipino Sign Language (FSL) users and non-signing hearing individuals. The system utilizes ESP32-S3-based sensor gloves to recognize FSL gestures and a Flutter-based mobile application to process text, audio, and visual FSL media.

## Research Objectives

1. **Dual Wearable Sensor Gloves (Gesture to Text):** To design dual wearable sensor gloves that can recognize predefined Filipino Sign Language (FSL) gestures and translate them into text.
2. **Mobile Application Output Display:** To develop a mobile application that displays the translated text output received from the dual wearable sensor gloves.
3. **Virtual Sign Language Interpreter (Text to Gesture):** To develop a mobile application that converts typed input into Filipino Sign Language (FSL) using a virtual sign language interpreter.
4. **System Evaluation (ISO/IEC 25010:2023):** To evaluate the developed portable two-way Filipino Sign Language (FSL) communication system in accordance with ISO/IEC 25010:2023, specifically in terms of **Appropriateness Recognizability**, **Learnability**, **Operability**, and **Inclusivity**.

For the complete breakdown of technical metrics (Accuracy, Precision, Recall, F1-Score, End-to-End BLE Latency) and ISO/IEC 25010:2023 Interaction Capability evaluation criteria, refer to the [Research Objectives & System Evaluation Framework](docs/evaluation_metrics.md).

## Key Features

- **FSL to Text and Speech:** The wearable gloves capture finger flexion and hand orientation data. An embedded TinyML model classifies the data into FSL letters and numbers, transmitting the results via Bluetooth Low Energy (BLE) to the mobile application for text display and Text-to-Speech (TTS) output.
- **Speech/Text to FSL Video/Image:** Non-signers can input text or use the device microphone via Speech-to-Text (STT). The application maps this input to a stored video or image database, playing the corresponding FSL gesture media on the screen.
- **Haptic Alerts:** The mobile application triggers a vibration motor on the glove to notify the DHH user of incoming messages or detected speech.
- **Edge Processing:** Gesture classification runs entirely on the ESP32-S3 microcontroller using Edge Impulse, ensuring low latency and reduced power consumption by transmitting lightweight string data rather than raw sensor streams.
- **Offline Functionality:** Core STT, TTS, and rendering engines utilize on-device libraries, allowing the system to operate without an active internet connection.

## Tech Stack

### Hardware & Embedded Systems

- **Microcontroller:** **ESP32-S3-N16R8** (`ESP32-S3-WROOM-1` SoC, 16MB Quad SPI Flash, 8MB Octal SPI PSRAM, 44-Pin, Dual USB Type-C) — one per glove.
- **Flex Sensors:** **Spectra Symbol `FS-L-0055-253-ST`** 2.2" Resistive Flex Sensors (25 kΩ flat to 45 kΩ–125 kΩ bent; 5 per glove on ESP32-S3 ADC1).
- **Inertial Measurement Unit (IMU):** **TDK InvenSense `MPU-6050`** (`GY-521` breakout, 6-axis 16-bit Accelerometer & Gyroscope over 400 kHz I²C at `0x68`).
- **Haptic Actuator:** **5.0V DC Vibration Motor Module** (9,000 RPM min, 3.0V–5.3V operating range, up to 60–90 mA, 23mm × 20.8mm).
- **Power & Charging Subsystem:** **1500mAh 3.7V 1S Li-Po Battery** (5.55Wh) charged via a **TP4056 USB Type-C Module** (with overcharge/discharge protection) and stepped up via a **Mini DC-to-DC Boost Converter (5.0V)** (see [Hardware Specifications & Wiring Reference](docs/hardware_specs.md)).
- **Firmware Environment:** PlatformIO utilizing C/C++ (`esp32-s3-devkitc-1`, `qio_opi`).
- **Wireless Protocol:** Bluetooth Low Energy (BLE 5.0) configured as a GATT server.

### Machine Learning (TinyML)

- **Development Platform:** Edge Impulse for data collection, feature extraction, and model training.
- **Deployment Format:** Optimized C++ library running inference directly on the ESP32-S3 (Edge AI) to eliminate cloud latency.
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
├── embedded/                       # ESP32-S3 firmware and hardware configuration
│   ├── compat/                     # VS Code IntelliSense mock headers for local dev
│   ├── include/                    # Project C++ header files (sensors, TinyML, BLE, haptics)
│   ├── lib/signko_inferencing/     # Edge Impulse TinyML exported library
│   ├── scripts/                    # PlatformIO build and flash automation scripts
│   ├── src/                        # Main C++ source files (sensors, TinyML, BLE, haptics)
│   ├── test/                       # Unit and hardware integration tests
│   └── platformio.ini              # Build and dependency settings (ESP32-S3-N16R8)
├── backend/                        # FastAPI Python backend & Database
│   ├── app/                        # API routes, schemas, models, and scripts
│   └── Dockerfile                  # Containerization for backend
├── app/                            # Flutter mobile application codebase
│   ├── assets/                     # .png and .mp4 files for FSL media
│   ├── lib/                        # Dart source code (Features, UI, Services)
│   └── pubspec.yaml                # Flutter dependencies
├── docs/                           # System documentation, dataset reference, and ISO metrics
│   ├── evaluation_metrics.md       # Research objectives and ISO/IEC 25010:2023 framework
│   ├── fsl_vocabulary.md           # Supported bilingual FSL vocabulary and media mapping
│   └── hardware_specs.md           # Complete BOM, electrical specs, and ESP32-S3 pinout
├── docker-compose.yml              # Orchestrates FastAPI and PostgreSQL containers
└── ml_pipeline/                    # Raw sensor datasets and Python data processing scripts
```

## Local Development Setup

We have automated scripts to get the entire stack (Flutter + Docker + FastAPI + Postgres) running locally in minutes on Windows.

### Prerequisites

1. **Docker Desktop** (must be running)
2. **Flutter SDK** (must be in your PATH)
3. **Microsoft Edge** or **Google Chrome** (for web testing)

### 1-Click Installation

Clone the repository and run the setup script from your terminal (PowerShell):

```powershell
# Automatically generates .env, installs dependencies, builds Docker images, and seeds the database
.\setup.ps1
```

### Running the Environment

Whenever you want to work on the app, simply run the start script. This boots the backend and launches the Flutter app in your browser:

```powershell
.\start_all.ps1
```

To gracefully shut down the backend and clean up, run:

```powershell
.\stop_all.ps1
```

## App Navigation & Usage

1. **Hardware Calibration:** Navigate to the **Hardware** tab (or Settings) and tap **Pair & Calibrate Gloves**. This launches a 4-step interactive flow to connect the ESP32-S3 gloves via Bluetooth and calibrate the flex sensors (Rest Pose vs. Fist Pose).
2. **Gesture-to-Text Mode:** In the **Translation** tab, select the "Gesture to Text" toggle. Tap the play button to start listening to glove telemetry. Recognized FSL gestures will appear on screen and can be spoken aloud via TTS.
3. **Text-to-Gesture Mode:** Switch to the "Text to Gesture" toggle. Type a phrase or tap the microphone to use Speech-to-Text. The app will query the backend and render the corresponding FSL video clip or fingerspelling sequence.

## Supported FSL Dataset

SignKo supports an official bilingual Filipino Sign Language (FSL) dataset covering:

- **Alphabet (26 Letters):** Complete fingerspelling sequence (Aa to Zz) rendered as dynamic character cards.
- **Numbers (1 to 10):** Numeric digits, English words (`one` to `ten`), and Filipino words (`isa` to `sampu`).
- **Words and Phrases (30 Bilingual Entries):** Conversational signs covering greetings, questions, courtesies, school/home terminology, and common phrases in both English and Filipino (Tagalog).

For the full list of database query keys, Filipino translations, and media asset paths, refer to the [FSL Vocabulary & Dataset Reference](docs/fsl_vocabulary.md).

## Embedded Hardware Setup (For Firmware Devs)

1. Navigate to the `embedded/` directory.
2. Open the project in Visual Studio Code with the PlatformIO extension installed.
3. Connect the **ESP32-S3-N16R8** board via USB Type-C.
4. Build and upload the firmware using the PlatformIO interface (`.\embedded\scripts\build.ps1` / `.\embedded\scripts\flash.ps1`). Ensure the correct COM port is selected.

## Git Workflow & Contributing

SignKo follows a two-tier branching model:

- **`dev`**: Primary active integration branch. All feature branches, bugfixes, and daily development commits must target `dev`.
- **`main`**: Production-ready branch. Releases are merged from `dev` into `main` after verification.

### Quick Start: Updating Your Local Environment

```bash
# 1. Switch to dev and pull the latest changes
git checkout dev
git pull origin dev

# 2. Create a feature branch
git checkout -b feat/your-feature-name

# 3. Commit using Conventional Commits
git commit -m "feat: description of work"
```

For complete instructions on stashing uncommitted work, syncing feature branches with `dev`, resolving Flutter generated file conflicts, and post-pull setup, refer to the [Development Runbook](RUNBOOK.md#git-workflow--updating-local-repository).

Please refer to [`AGENTS.md`](./AGENTS.md) for general workspace guidelines, code quality expectations, and commit message conventions.

## License

This project is developed as an academic thesis and research prototype. All rights reserved by the authors.
