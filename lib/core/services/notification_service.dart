import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('[FCM-BG] Background message received: ${message.messageId}');
  if (message.notification != null) {
    debugPrint('[FCM-BG] Notification Title: ${message.notification!.title}');
    debugPrint('[FCM-BG] Notification Body: ${message.notification!.body}');
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  String? _fcmToken;
  final _messageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessageReceived => _messageController.stream;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    try {
      debugPrint('[FCM] Requesting notification permissions...');
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // Background message handler
        if (!kIsWeb) {
          FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        }

        // Get the token
        try {
          if (kIsWeb) {
            // Optional: Specify VAPID key if needed
            _fcmToken = await _fcm.getToken();
          } else {
            _fcmToken = await _fcm.getToken();
          }
          debugPrint('[FCM] Token: $_fcmToken');
          if (_fcmToken != null) {
            await _saveToken(_fcmToken!);
          }
        } catch (e) {
          debugPrint('[FCM] Error getting token: $e');
        }

        // Token refresh listener
        _fcm.onTokenRefresh.listen((token) async {
          _fcmToken = token;
          debugPrint('[FCM] Token refreshed: $_fcmToken');
          await _saveToken(token);
        });

        // Foreground messages listener
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('[FCM-FG] Message received: ${message.messageId}');
          _messageController.add(message);
        });

        // Open app from background listener
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('[FCM-CLICK] Notification opened app: ${message.data}');
        });

        // Terminated app initial message
        final initialMessage = await _fcm.getInitialMessage();
        if (initialMessage != null) {
          debugPrint('[FCM-INIT] Initial message: ${initialMessage.data}');
        }
      }
    } catch (e) {
      debugPrint('[FCM] Initialization failed: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (_) {}
  }

  // Local simulator helper to send notifications manually during testing
  void simulateNotification({required String title, required String body, Map<String, dynamic>? data}) {
    final message = RemoteMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      notification: RemoteNotification(
        title: title,
        body: body,
      ),
      data: data ?? {},
      sentTime: DateTime.now(),
    );
    _messageController.add(message);
  }
}
