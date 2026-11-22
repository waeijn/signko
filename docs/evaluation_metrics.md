# Research Objectives & System Evaluation Framework (ISO/IEC 25010:2023)

This document defines the research objectives of the SignKo portable two-way Filipino Sign Language (FSL) communication system and outlines the quantitative technical metrics and standardized ISO/IEC 25010:2023 evaluation criteria used to assess the system.

---

## Research Objectives

1. **Dual Wearable Sensor Gloves (Gesture to Text):** To design dual wearable sensor gloves using flex sensors and MPU6050 inertial measurement units (IMUs), integrated with a 1D Convolutional Neural Network (1D-CNN), to recognize predefined Filipino Sign Language (FSL) gestures and translate them into text.
2. **Mobile Application Output Display:** To develop a mobile application using Bluetooth Low Energy (BLE) communication to receive and display the translated text output from the dual wearable sensor gloves.
3. **Virtual Sign Language Interpreter (Text to Gesture):** To develop a mobile application feature that converts typed text input into Filipino Sign Language (FSL) through the retrieval and presentation of predefined FSL images/videos using a virtual sign language interpreter.
4. **System Evaluation (ISO/IEC 25010:2023):** To evaluate the developed portable two-way Filipino Sign Language (FSL) communication system in accordance with ISO/IEC 25010:2023, specifically in terms of:
   - **4.1.** Appropriateness Recognizability
   - **4.2.** Learnability
   - **4.3.** Operability
   - **4.4.** Inclusivity

---

## Part 1: Technical & Quantitative Performance Metrics (Objectives 1–3)

### 1. Gesture Recognition & Sensor Performance (Objective 1)

Evaluates hardware sensor reliability and Edge Impulse 1D-CNN TinyML classification performance across the predefined FSL dataset (26 Alphabet letters, Numbers 1–10, and 20 bilingual Words/Phrases, totaling 56 FSL classes):

- **Hardware Pass/Fail Inspection:** Functional verification of flex sensor bend resistance ($\Delta R \ge 15\text{ k}\Omega$), MPU6050 I2C response, battery voltage stability ($3.3\text{V} \pm 0.05\text{V}$), ESP-NOW inter-glove wireless communication, BLE advertisement, and haptic actuator response.
- **Gesture Recognition Trials (1,680 Trials):** 56 predefined FSL classes tested across 30 repetitions each ($56 \times 30 = 1,680\text{ trials}$).
- **One-vs-Rest (OvR) Confusion Matrix:** Logs True Positives ($TP$), False Positives ($FP$), True Negatives ($TN$), and False Negatives ($FN$) for each gesture class to calculate macro-averaged Precision, Recall, and F1-Score:
  $$\text{Precision} = \frac{TP}{TP + FP}, \quad \text{Recall} = \frac{TP}{TP + FN}, \quad \text{F1-Score} = 2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}}$$
- **Overall Multi-Class Classification Accuracy:**
  $$\text{Overall Accuracy} = \frac{\sum_{i=1}^{56} TP_i}{1,680} \times 100\%$$
- **Accuracy Interpretation Ranges:**
  - $\ge 95.00\%$: Very High
  - $90.00\% \le \text{Accuracy} < 95.00\%$: High
  - $85.00\% \le \text{Accuracy} < 90.00\%$: Moderate
  - $< 85.00\%$: Poor

### 2. Real-Time BLE Transmission & Display (Objective 2)

Measures the responsiveness and reliability of the wireless pipeline from the ESP32 GATT server (`0xFFE0`) to the Flutter mobile client:

- **BLE Packet Delivery Ratio (PDR):** Ratio of telemetry and haptic packets successfully received by the mobile device across operating distances ($0.5\text{ m}$, $1.0\text{ m}$, $3.0\text{ m}$):
  $$\text{PDR} = \frac{\text{Packets Received by Mobile App}}{\text{Packets Transmitted by Gloves}} \times 100\%$$
  - $\ge 98.00\%$: Excellent
  - $95.00\% \le \text{PDR} < 98.00\%$: Good
  - $90.00\% \le \text{PDR} < 95.00\%$: Fair
  - $< 90.00\%$: Poor
- **Text Display Accuracy (TDA):** Evaluates how correctly the mobile application parses and renders received classifications compared to the transmitted classification payload from the gloves:
  $$\text{TDA} = \frac{\text{Correctly Displayed Output Strings}}{\text{Total Received Classification Packets}} \times 100\%$$
  - $\ge 98.00\%$: Excellent
  - $94.00\% \le \text{TDA} < 98.00\%$: Good
  - $90.00\% \le \text{TDA} < 94.00\%$: Fair
  - $< 90.00\%$: Poor
- **Application Response Time ($T$):** Quantifies internal mobile application latency from BLE packet arrival (`0xFFE1`) to complete UI text rendering:
  $$T = t_{\text{UI Render Complete}} - t_{\text{BLE Packet Arrival}}$$
  - $T \le 150\text{ ms}$: Excellent
  - $150\text{ ms} < T \le 1,000\text{ ms}$: Good
  - $1,000\text{ ms} < T \le 2,000\text{ ms}$: Fair
  - $T > 2,000\text{ ms}$: Poor

### 3. Virtual FSL Interpreter & Media Rendering (Objective 3)

Evaluates the reverse translation pipeline converting typed text or speech input into FSL visual media. Evaluated across 280 experimental trials (56 vocabulary entries $\times$ 5 trials each):

- **Query Response Time ($\overline{QRT}$):** Elapsed time from submitting a typed query in the mobile app to complete rendering of the video or fingerspelling sequence:
  $$\overline{QRT} = \frac{\sum_{i=1}^{280} QRT_i}{280} \quad (\text{Benchmark: } \le 2.0\text{ seconds meets benchmark; } > 2.0\text{ seconds below benchmark})$$
- **FSL Translation Output Accuracy (FSL-TOA):** Proportion of displayed FSL signs verified as semantically and grammatically correct representations of the input text by a certified, independent FSL interpreter:
  $$\text{FSL-TOA} = \frac{N_c}{280} \times 100\% \quad (\text{where } N_c = \text{validator-confirmed correct outputs})$$
  - $100.00\%$: Excellent
  - $90.00\% \le \text{FSL-TOA} < 100.00\%$: Meets Benchmark
  - $< 90.00\%$: Below Benchmark
- **Image/Video Retrieval Success Rate (IVRSR):** Assesses the pipeline's capability to locate, load, and render the predefined FSL visual asset without missing files or video player errors:
  $$\text{IVRSR} = \frac{N_s}{280} \times 100\% \quad (\text{Benchmark: } \ge 84.00\% \text{ meets/exceeds published benchmark; } < 84.00\% \text{ below benchmark})$$

#### Why a Confusion Matrix is Not Used for Text-to-Gesture
A confusion matrix is mathematically formulated for probabilistic machine learning classifiers (such as the 1D-CNN in Objective 1) where analog sensor noise and overlapping kinematic features produce classification uncertainty across classes. In contrast, Objective 3 operates on **deterministic lexical indexing, rule-based string normalization, and sequential character decomposition**. A query for `"salamat"` deterministically queries `assets/videos/thank_you.mp4` without probability distributions. Consequently, system failures in Objective 3 are analyzed using a **Categorical Error Analysis**:
1. **Exact Match Variance:** Slang or non-indexed phrases that trigger fingerspelling fallback.
2. **Out-of-Vocabulary (OOV):** Unlisted proper nouns successfully decomposed into character cards ($A\text{–}Z$).
3. **Punctuation / Whitespace Normalization:** Punctuation handling invariance.
4. **Media Asset Playback Integrity:** Measured via IVRSR ($\ge 84.00\%$).

---

## Part 2: ISO/IEC 25010:2023 Interaction Capability Metrics (Objective 4)

Under **ISO/IEC 25010:2023**, system usability and user experience are evaluated under the **Interaction Capability** quality characteristic using a standardized **four-point forced-choice Likert scale** administered to stratified respondent groups (Deaf and Hard-of-Hearing primary signers, hearing non-signers, and FSL/IT domain experts). The four-point scale eliminates central tendency bias by omitting a neutral midpoint.

### Four-Point Likert Scale (Table 7)
- **4 — Strongly Agree (SA):** Excellent (Weighted Mean Range: $3.25\text{–}4.00$)
- **3 — Agree (A):** Good (Weighted Mean Range: $2.50\text{–}3.24$)
- **2 — Disagree (D):** Fair (Weighted Mean Range: $1.75\text{–}2.49$)
- **1 — Strongly Disagree (SD):** Poor (Weighted Mean Range: $1.00\text{–}1.74$)

### Subcharacteristics Evaluated (Table 8)

#### 4.1. Appropriateness Recognizability
*Degree to which users can recognize whether the system is appropriate for their two-way FSL communication needs.*
- **Task Indicator:** First-impression mode identification rate (percentage of participants who accurately identify how to initiate *Gesture to Text* and *Text to Gesture* workflows without prior briefing).
- **Evaluation Criteria:**
  - Clarity of interface layout and mode-switching toggles.
  - Visibility of dual-glove connection status and battery levels.
  - Practical relevance of the 56 predefined FSL vocabulary items to daily communication.

#### 4.2. Learnability
*Degree to which the system enables a user to learn how to operate the sensor gloves and mobile application within a specified time.*
- **Task Indicator:** Time to proficiency (minutes required for a first-time user to independently complete the 4-step Bluetooth pairing and flex sensor calibration flow) and task completion time reduction across repeated trials.
- **Evaluation Criteria:**
  - Clarity of the step-by-step calibration instructions (Rest Pose vs. Fist Pose).
  - Intuitiveness of glove haptic vibration patterns (single pulse for gesture confirmation, double pulse for incoming text/speech alert).
  - Ease of interpreting the virtual FSL video demonstration and fingerspelling sequence outputs.

#### 4.3. Operability
*Degree to which the system has attributes that make it easy to operate and control.*
- **Task Indicator:** Task completion rate (percentage of users completing a full bidirectional conversation loop without external assistance) and operational error frequency.
- **Evaluation Criteria:**
  - Physical comfort, weight distribution, and finger mobility while wearing the dual sensor gloves.
  - Responsiveness of mobile UI controls (mode toggles, speech-to-text microphone, TTS playback, and reset actions).
  - Visual contrast and legibility across both Light Mode and Dark Mode themes.

#### 4.4. Inclusivity
*Degree to which the system can be utilized by people of diverse backgrounds, abilities, and physical characteristics.*
- **Task Indicator:** Cross-hand-size calibration success rate (across small, medium, and large hand dimensions) and bilingual query equivalence (parity between English and Filipino/Tagalog inputs).
- **Evaluation Criteria:**
  - **Sensory Accessibility:** Multimodal feedback—tactile haptic alerts on the gloves and visual indicators for Deaf users, paired with Text-to-Speech (TTS) audio output for hearing users.
  - **Linguistic Inclusivity:** Native support for both English and Filipino (Tagalog) text and voice inputs mapped to localized Filipino Sign Language (FSL).
  - **Physical Adaptability:** Hardware strap adjustability and dynamic software min/max normalization to accommodate varying hand anatomies.

### Statistical Treatment and Class Intervals (Table 9)
All four subcharacteristics and the Overall Interaction Capability share uniform $0.75$ class interval interpretation thresholds based on weighted means ($\overline{x}$):
- **$3.25 \le \overline{x} \le 4.00$:** **Excellent**
- **$2.50 \le \overline{x} \le 3.24$:** **Good**
- **$1.75 \le \overline{x} \le 2.49$:** **Fair**
- **$1.00 \le \overline{x} \le 1.74$:** **Poor**

---

## Summary Matrix

| Objective | Quality Dimension | Measurable Indicators | Evaluation Method / Tool |
| :--- | :--- | :--- | :--- |
| **Objective 1** | Gesture Recognition Performance | Accuracy ($\ge 95\%$ Very High), Precision, Recall, F1-Score | OvR Confusion Matrix across 1,680 trials (56 classes $\times$ 30) |
| **Objective 2** | Real-Time Display & BLE Pipeline | PDR ($\ge 98\%$), TDA ($\ge 98\%$), App Response Time ($T \le 150\text{ ms}$) | Hardware timestamp logging ($t_{\text{BLE}}$ to $t_{\text{Render}}$) |
| **Objective 3** | Virtual FSL Interpreter | QRT ($\le 2.0\text{ s}$), FSL-TOA ($\ge 90\%$), IVRSR ($\ge 84\%$) | Certified FSL interpreter validation & Categorical Error Analysis |
| **Objective 4** | ISO/IEC 25010:2023 Interaction Capability | Grand Weighted Mean ($\overline{x}$), Standard Deviation ($SD$) | 4-point forced-choice Likert survey across DHH, hearing, and experts |
