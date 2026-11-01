# Research Objectives & System Evaluation Framework (ISO/IEC 25010:2023)

This document defines the research objectives of the SignKo portable two-way Filipino Sign Language (FSL) communication system and outlines the quantitative technical metrics and standardized ISO/IEC 25010:2023 evaluation criteria used to assess the system.

---

## Research Objectives

1. **Dual Wearable Sensor Gloves (Gesture to Text):** To design dual wearable sensor gloves that can recognize predefined Filipino Sign Language (FSL) gestures and translate them into text.
2. **Mobile Application Output Display:** To develop a mobile application that displays the translated text output received from the dual wearable sensor gloves.
3. **Virtual Sign Language Interpreter (Text to Gesture):** To develop a mobile application that converts typed input into Filipino Sign Language (FSL) using a virtual sign language interpreter.
4. **System Evaluation (ISO/IEC 25010:2023):** To evaluate the developed portable two-way Filipino Sign Language (FSL) communication system in accordance with ISO/IEC 25010:2023, specifically in terms of:
   - **4.1.** Appropriateness Recognizability
   - **4.2.** Learnability
   - **4.3.** Operability
   - **4.4.** Inclusivity

---

## Part 1: Technical & Quantitative Performance Metrics (Objectives 1–3)

### 1. Gesture Recognition & Sensor Performance (Objective 1)

Evaluates hardware sensor reliability and Edge Impulse 1D-CNN TinyML classification performance across the predefined FSL dataset (26 Alphabet letters, Numbers 1–10, and 30 bilingual Words/Phrases):

- **Classification Accuracy (`%`):** Ratio of correctly classified FSL gestures to total attempted gestures across test trials.
  $$\text{Accuracy} = \frac{TP + TN}{TP + TN + FP + FN} \times 100\%$$
- **Precision, Recall, and F1-Score:** Evaluated per class and macro-averaged across all classes to assess discrimination between visually or kinematically similar hand configurations.
  $$\text{Precision} = \frac{TP}{TP + FP}, \quad \text{Recall} = \frac{TP}{TP + FN}, \quad \text{F1-Score} = 2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}}$$
- **Multi-Class Confusion Matrix:** Cross-tabulation logging predicted vs. ground-truth gesture labels to identify inter-class confusion.
- **Sensor Calibration Repeatability:** Consistency of normalized flex sensor ADC values (`0.00` to `1.00`) and IMU orientation angles (`roll`, `pitch`, `yaw`) after executing the Rest Pose vs. Fist Pose calibration protocol.

### 2. Real-Time BLE Transmission & Display (Objective 2)

Measures the responsiveness and reliability of the wireless pipeline from the ESP32 GATT server (`0xFFE0`) to the Flutter mobile client:

- **End-to-End Gesture-to-Text Latency (`ms`):** Total elapsed time from the completion of a physical gesture to the text rendering on the mobile interface.
  $$\text{Latency}_{\text{total}} = t_{\text{sampling}} + t_{\text{inference}} + t_{\text{BLE}} + t_{\text{UI render}}$$
- **BLE Packet Delivery Ratio (PDR) (`%`):** Ratio of telemetry packets (`0xFFE1`) and haptic feedback command packets (`0xFFE2`) successfully received by the target device without packet loss across operating distances (`0.5 m`, `1.0 m`, `3.0 m`).
- **Word Error Rate (WER) / Character Error Rate (CER):** Accuracy of continuous character accumulation and word boundary detection during fingerspelling sequences.

### 3. Virtual FSL Interpreter & Media Rendering (Objective 3)

Evaluates the reverse translation pipeline from typed or spoken input to visual FSL media playback:

- **Query-to-Render Response Time (`ms`):** Elapsed time from submitting a text query in the mobile app to the FastAPI backend resolving the database match and the Flutter UI rendering the video clip or fingerspelling sequence.
- **Bilingual Lexical Matching Accuracy (`%`):**
  - **Exact Phrase/Word Resolution:** Accuracy of resolving English and Filipino (Tagalog) inputs (including punctuation and space-normalized variants) to their corresponding `.mp4` FSL video clips.
  - **Out-of-Vocabulary (OOV) Fingerspelling Fallback:** Accuracy of decomposing unindexed words into sequential `.png` alphabet character cards.

---

## Part 2: ISO/IEC 25010:2023 Interaction Capability Metrics (Objective 4)

Under **ISO/IEC 25010:2023**, system usability is evaluated under the **Interaction Capability** quality characteristic. Assessment combines task-based performance observations with a standardized **5-point Likert Scale instrument** (`1 = Strongly Disagree` to `5 = Strongly Agree`) administered to target user groups (Deaf/Hard-of-Hearing signers, FSL interpreters, and non-signing hearing individuals).

### 4.1. Appropriateness Recognizability

*Degree to which users can recognize whether the system is appropriate for their two-way FSL communication needs.*

- **Task Indicator:** First-impression mode identification rate (percentage of participants who accurately identify how to initiate *Gesture to Text* and *Text to Gesture* workflows without prior briefing).
- **Evaluation Criteria:**
  - Clarity of the interface layout and mode-switching toggles (*Gesture to Text* vs. *Text to Gesture*).
  - Visibility of hardware connection status, dual-glove telemetry indicators, and active translation state.
  - Relevance of the supported bilingual FSL dataset to everyday conversational scenarios.

### 4.2. Learnability

*Degree to which the system enables a user to learn how to operate the sensor gloves and mobile application within a specified time.*

- **Task Indicator:** Time to proficiency (`minutes` required for a first-time user to independently complete the 4-step Bluetooth pairing and flex sensor calibration flow) and reduction in task completion time across repeated trials.
- **Evaluation Criteria:**
  - Clarity of the step-by-step calibration instructions (Rest Pose vs. Fist Pose).
  - Intuitiveness of the glove haptic vibration patterns (`HAPTIC_SHORT_PULSE` for word confirmation, `HAPTIC_DOUBLE_PULSE` for incoming text/speech alerts, `HAPTIC_LONG_ALERT` for connection alerts).
  - Ease of learning how to input queries and interpret the virtual FSL video and fingerspelling outputs.

### 4.3. Operability

*Degree to which the system has attributes that make it easy to operate and control.*

- **Task Indicator:** Task completion rate (`%` of users completing a full bidirectional conversation loop without external assistance) and user operational error frequency.
- **Evaluation Criteria:**
  - Physical ergonomics, weight distribution, and finger movement freedom while wearing the dual ESP32 sensor gloves.
  - Responsiveness and accessibility of mobile UI controls (mode toggles, speech-to-text microphone trigger, text-to-speech playback, and reset actions).
  - Visual consistency and legibility across both Light Mode and Dark Mode themes.

### 4.4. Inclusivity

*Degree to which the system can be utilized by people of diverse backgrounds, abilities, and physical characteristics.*

- **Task Indicator:** Cross-hand-size calibration success rate (`%` across small, medium, and large hand profiles) and bilingual query equivalence (`100%` parity between English and Filipino/Tagalog inputs).
- **Evaluation Criteria:**
  - **Sensory Accessibility:** Effectiveness of multimodal feedback—tactile haptic alerts on the gloves and visual indicators for Deaf and Hard-of-Hearing (DHH) users, paired with Text-to-Speech (TTS) audio output for hearing users.
  - **Linguistic Inclusivity:** Native support for both English and Filipino (Tagalog) text and voice inputs mapped to localized Filipino Sign Language (FSL).
  - **Physical Adaptability:** Hardware strap adjustability and dynamic software min/max normalization to accommodate varying hand sizes and finger flex ranges.

---

## Summary Matrix

| Objective | Quality Dimension | Measurable Indicators | Evaluation Method / Tool |
| :--- | :--- | :--- | :--- |
| **Objective 1** | Gesture Recognition Performance | Accuracy (`%`), Precision, Recall, F1-Score, Confusion Matrix | Controlled gesture trials across FSL dataset classes |
| **Objective 2** | Real-Time Display & BLE Pipeline | End-to-End Latency (`ms`), Packet Delivery Ratio (`%`), WER/CER | Timestamp logging from ESP32 inference to Flutter UI render |
| **Objective 3** | Virtual FSL Interpreter | Query-to-Render Time (`ms`), Bilingual Match & Fallback Accuracy (`%`) | API response benchmarking and bilingual test query suite |
| **Objective 4** | ISO/IEC 25010:2023 Interaction Capability | Weighted Mean (`1.00–5.00`), Task Completion Rate (`%`), Time on Task | Standardized ISO/IEC 25010:2023 Likert survey and user testing |
