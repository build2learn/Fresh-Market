# Firebase Integration Skill

## Initialization
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FreshMarketApp());
}
```

## Firestore Usage Pattern
```dart
// Collection reference
final usersRef = FirebaseFirestore.instance.collection('users');

// Real-time listener
usersRef.snapshots().listen((snapshot) {
  for (var change in snapshot.docChanges) {
    // handle change
  }
});

// Get document
final doc = await usersRef.doc(userId).get();
```

## Authentication
```dart
// Sign in
final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign out
await FirebaseAuth.instance.signOut();

// Auth state changes
FirebaseAuth.instance.authStateChanges().listen((user) {
  // handle auth change
});
```

## Storage
```dart
final ref = FirebaseStorage.instance.ref('products/$productId.jpg');
await ref.putFile(file);
final url = await ref.getDownloadURL();
```

## Firebase Cloud Messaging
```dart
final messaging = FirebaseMessaging.instance;
final token = await messaging.getToken();
messaging.subscribeToTopic('offers');
messaging.onMessage.listen((message) {
  // handle foreground message
});
```

## Firestore Security Rules Format
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
    match /roles/{roleId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
    // ... more rules
  }
}
```
