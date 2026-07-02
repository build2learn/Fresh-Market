# Installation Guide

This guide will help you set up and run the Fresh Market project locally on your development machine.

## Prerequisites

Ensure you have the following installed:
1. **Flutter SDK**: Version `3.16.x` or higher.
2. **Dart SDK**: Integrated with Flutter.
3. **IDE**: VS Code (recommended) or Android Studio with Flutter/Dart extensions.
4. **Git**: To clone the repository.
5. **Chrome/Edge**: For running the web application.

---

## Local Machine Setup

### 1. Clone the Repository
Clone the project to your local drive:
```bash
git clone https://github.com/build2learn/Fresh-Market.git
cd Fresh-Market
```

### 2. Download Dependencies
Run the package getter to fetch all Riverpod, GoRouter, and Firebase packages:
```bash
flutter pub get
```

### 3. Verify Setup
Verify your environment settings and connected devices:
```bash
flutter doctor
flutter devices
```

---

## Running in Development Mode

By default, the application is bootstrapped to use **SharedPreferences-backed Mock Repositories** for offline-first development. You do not need a active internet connection or Firebase setup to run the app in development mode.

* Run the app on **Web (Chrome)**:
  ```bash
  flutter run -d chrome
  ```
* Run the app on a **Mobile Emulator/Device**:
  ```bash
  flutter run
  ```
* To test the local release builds:
  ```bash
  flutter run --release
  ```
