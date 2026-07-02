# Deployment Guide

This guide explains how to build and deploy Fresh Market for production.

---

## 1. Web Deployment (Firebase Hosting)

### Step 1: Build the Web App
Compile the Flutter web build in release mode:
```bash
flutter build web --release
```

### Step 2: Initialize Firebase Hosting
Run this from the project root if not already done:
```bash
firebase init hosting
```
* Select `build/web` as your public directory.
* Configure as a single-page app (Yes).
* Do not overwrite `build/web/index.html` if prompted.

### Step 3: Deploy to Live Site
Deploy to Firebase Hosting:
```bash
firebase deploy --only hosting
```

---

## 2. Android Deployment

### Prerequisites: Keystore & Signing Config
Create a file named `android/key.properties` containing your release key paths:
```properties
storePassword=<YOUR_STORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=<YOUR_KEY_ALIAS>
storeFile=<PATH_TO_KEYSTORE_FILE>
```

### Build APK
Generate a standalone release APK:
```bash
flutter build apk --release
```
* Output location: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Google Play Store)
Generate an Android App Bundle (AAB):
```bash
flutter build appbundle --release
```
* Output location: `build/app/outputs/bundle/release/app-release.aab`
* Upload this file to the Google Play Console for distribution.
