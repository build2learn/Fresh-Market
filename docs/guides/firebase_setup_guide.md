# Firebase Setup Guide

This guide describes how to connect the Fresh Market project to a production Firebase instance.

## 1. Firebase Project Creation
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it `fresh-market-prod`.
3. Enable Google Analytics (optional).

## 2. Add Platform Applications
Add the platforms you want to build:
* **Web App**: Register web app, copy configuration options into `lib/firebase_options.dart`.
* **Android App**: Register package name `com.build2learn.fresh_market`. Download `google-services.json` and place it in `android/app/`.

---

## 3. Enable Services

### Firebase Authentication
1. Go to **Build -> Authentication -> Get Started**.
2. Enable **Email/Password** sign-in method.

### Cloud Firestore
1. Go to **Build -> Firestore Database -> Create Database**.
2. Start in production mode.
3. Select your cloud resource location.
4. Deploy the rules from the project root:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Firebase Storage
1. Go to **Build -> Storage -> Get Started**.
2. Deploy the storage rules from the project root:
   ```bash
   firebase deploy --only storage:rules
   ```

---

## 4. Deploying Firestore Indexes & Rules
Use the Firebase CLI to deploy files located at the root of the project:

### Log in to Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### Deploy configuration
```bash
firebase deploy --only firestore:indexes,firestore:rules,storage:rules
```

---

## 5. Firebase Cloud Messaging (FCM)
For push notifications:
* Android: Autowired via the `google-services.json` configuration file.
* iOS: Setup APNs keys inside the project Settings on the Firebase Console under **Cloud Messaging**.
