# 🌱 PlantCare — AI-Powered Mango Plant Disease Detection App
<img width="1376" height="768" alt="WhatsApp Image 2026-05-12 at 11 03 42 AM" src="https://github.com/user-attachments/assets/397c1e21-0a7c-41f7-b3e7-9272a6b4996f" />


# 📱 PlantCare

PlantCare is an AI-powered mobile application designed to help farmers detect mango plant diseases efficiently using deep learning and computer vision technology. Farmers can capture a mango leaf image using the device camera or upload an image from the gallery, and the integrated AI model analyzes the image to identify diseases and provide detailed information about them.

The application focuses on improving smart agriculture by enabling early disease detection, reducing crop damage, and increasing farming productivity through AI-driven solutions.

---

## 🚀 Features

✅ AI-based mango plant disease detection <br>
✅ Capture image using device camera <br>
✅ Upload image from gallery <br>
✅ DenseNet deep learning model integration <br>
✅ Real-time disease prediction <br>
✅ Weather forecasting using Weather API <br>
✅ Agricultural news & disease alerts <br>
✅ Firebase backend integration <br>
✅ GetX state management <br>
✅ MVVM architecture implementation <br>
✅ Clean and responsive UI <br>
✅ Cross-platform support (Android & iOS)

---

# 🧠 AI Disease Detection

PlantCare uses a **DenseNet (Dense Convolutional Neural Network)** model trained on mango plant disease datasets to classify and detect diseases accurately.

### Supported Disease Detection

* Anthracnose
* Powdery Mildew
* Bacterial Black Spot
* Healthy Leaf Detection
* Other common mango plant diseases

---

# 🏗️ Architecture

The application follows the **MVVM (Model-View-ViewModel)** architecture combined with **GetX** for state management, dependency injection, and navigation.

### Architecture Benefits

* Scalable project structure
* Better code maintainability
* Separation of concerns
* Reactive state management
* Improved performance
* Easy feature integration

---

# 🛠️ Tech Stack

| Technology  | Usage                         |
| ----------- | ----------------------------- |
| Flutter     | Mobile App Development        |
| Dart        | Programming Language          |
| GetX        | State Management & Navigation |
| MVVM        | Project Architecture          |
| Firebase    | Backend Services              |
| DenseNet    | AI Disease Detection Model    |
| Weather API | Weather Forecast Integration  |
| REST APIs   | Data Communication            |

---

# 📂 Project Structure

```bash id="u0mjlwm"
lib/
│
├── core/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── view/
│   ├── screens/
│   └── widgets/
│
├── view_model/
│
├── utils/
├── routes/
├── firebase/
└── main.dart
```

---

# 📷 App Workflow

1. User opens the PlantCare application
2. Capture image using camera or upload from gallery
3. AI model processes the leaf image
4. Disease is detected and classified
5. App displays disease details and recommendations
6. Farmer can also view weather updates and agriculture news

---

# 🌦️ Weather Integration

PlantCare integrates a Weather API to provide:

* Live weather conditions
* Temperature updates
* Environmental insights
* Weather awareness for crop protection

---

# 📰 Agriculture News & Alerts

The app provides:

* Latest agriculture news
* Mango disease alerts
* Farming awareness updates
* Information about recent disease outbreaks

---

# 🎯 Project Objective

The goal of PlantCare is to empower farmers with AI technology by:

* Detecting diseases at an early stage
* Reducing crop losses
* Improving productivity
* Increasing awareness about plant health
* Supporting smart farming solutions

---

# ⚙️ Installation

## Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio / VS Code
* Firebase Setup

---

## Clone Repository

```bash id="m0s0c6"
git clone https://github.com/your-username/PlantCare.git
```

---

## Navigate to Project

```bash id="2kqz3e"
cd PlantCare
```

---

## Install Dependencies

```bash id="l0p8m8"
flutter pub get
```

---

## Run Application

```bash id="mjlwmr"
flutter run
```

---

# 🔥 Firebase Services Used

* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Firebase Analytics

---

# ⭐ Support

If you like this project, give it a ⭐ on GitHub and support smart agriculture innovation.

---

# 📄 License

This project is licensed under the MIT License.
