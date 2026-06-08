import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_market/config/firebase_options.dart';

final firebaseReadyProvider = FutureProvider<bool>((ref) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
  }
  return true;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final bool isLoading;
  const AuthState({this.status = AuthStatus.uninitialized, this.errorMessage, this.isLoading = false});
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUninitialized => status == AuthStatus.uninitialized;
  bool get isAdmin => false;

  AuthState copyWith({AuthStatus? status, String? errorMessage, bool? isLoading}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  StreamSubscription? _sub;
  AuthNotifier() : super(const AuthState()) {
    debugPrint('[AUTH] AuthNotifier created, subscribing to stream');
    _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('[AUTH] Stream emitted: ${user == null ? "null" : user.uid}');
      state = AuthState(status: user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated);
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (state.status == AuthStatus.uninitialized) {
        debugPrint('[AUTH] 5s timeout - forcing unauthenticated');
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message ?? 'Sign in failed');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signUp(String email, String password, String? displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (displayName != null && cred.user != null) {
        await cred.user!.updateDisplayName(displayName);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message ?? 'Sign up failed');
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  debugPrint('[AUTH] Creating AuthNotifier via provider');
  return AuthNotifier();
});
