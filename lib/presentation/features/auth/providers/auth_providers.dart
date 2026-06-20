import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/auth_repository_provider.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/domain/usecases/auth/sign_in.usecase.dart';
import 'package:fresh_market/domain/usecases/auth/sign_up.usecase.dart';
import 'package:fresh_market/domain/usecases/auth/sign_out.usecase.dart';
import 'package:fresh_market/domain/usecases/auth/send_password_reset.usecase.dart';
import 'package:fresh_market/domain/usecases/auth/get_current_user.usecase.dart';
import 'package:fresh_market/domain/repositories/user_repository.dart';
import 'package:fresh_market/data/providers/user_repository_provider.dart';
import 'package:fresh_market/core/services/notification_service.dart';

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>((ref) {
  return SendPasswordResetUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final watchAuthStateUseCaseProvider = Provider<WatchAuthStateUseCase>((ref) {
  return WatchAuthStateUseCase(ref.watch(authRepositoryProvider));
});

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.uninitialized,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUninitialized => status == AuthStatus.uninitialized;
  bool get isAdmin => user?.isAdmin ?? false;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final WatchAuthStateUseCase _watchAuthState;
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;
  final SendPasswordResetUseCase _sendPasswordReset;
  final UserRepository _userRepository;

  AuthNotifier({
    required WatchAuthStateUseCase watchAuthState,
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignOutUseCase signOut,
    required SendPasswordResetUseCase sendPasswordReset,
    required UserRepository userRepository,
  })  : _watchAuthState = watchAuthState,
        _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _sendPasswordReset = sendPasswordReset,
        _userRepository = userRepository,
        super(const AuthState()) {
    _init();
  }

  StreamSubscription<UserEntity?>? _authSubscription;

  void _init() {
    debugPrint('[AUTH] AuthNotifier._init() - subscribing to auth state stream');
    debugPrint('[AUTH] AuthNotifier initial state: ${state.status}');

    _authSubscription = _watchAuthState.call().listen(
      (user) {
        if (user != null) {
          debugPrint('[AUTH] Auth state stream: authenticated as ${user.id}');
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
          );
          _syncFcmToken(user.id);
        } else {
          debugPrint('[AUTH] Auth state stream: unauthenticated (user=null)');
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[AUTH] Auth stream error: $error');
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: error.toString(),
        );
      },
      onDone: () {
        debugPrint('[AUTH] Auth stream done');
        if (state.status == AuthStatus.uninitialized) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      },
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (state.status == AuthStatus.uninitialized) {
        debugPrint('[AUTH] AuthNotifier 5s timeout - forcing unauthenticated');
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _signIn(email, password);
    if (result is Success<UserEntity>) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.data,
      );
    } else if (result is Failure<UserEntity>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error.message,
      );
    }
  }

  Future<void> signUp(String email, String password, String? displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _signUp(email, password, displayName);
    if (result is Success<UserEntity>) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.data,
      );
    } else if (result is Failure<UserEntity>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.error.message,
      );
    }
  }

  Future<void> signOut() async {
    await _signOut();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _sendPasswordReset(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> refreshUser() async {
    final user = state.user;
    if (user != null) {
      final result = await _userRepository.getUser(user.id);
      if (result is Success<UserEntity>) {
        state = state.copyWith(user: result.data);
      }
    }
  }

  Future<void> _syncFcmToken(String userId) async {
    try {
      final token = NotificationService.instance.fcmToken;
      if (token != null) {
        debugPrint('[AUTH] Syncing FCM token for user $userId: $token');
        await _userRepository.updateFcmToken(userId, token);
      } else {
        debugPrint('[AUTH] No FCM token found to sync for user $userId');
      }
    } catch (e) {
      debugPrint('[AUTH] Failed to sync FCM token: $e');
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  debugPrint('[AUTH] authNotifierProvider: creating AuthNotifier');
  return AuthNotifier(
    watchAuthState: ref.watch(watchAuthStateUseCaseProvider),
    signIn: ref.watch(signInUseCaseProvider),
    signUp: ref.watch(signUpUseCaseProvider),
    signOut: ref.watch(signOutUseCaseProvider),
    sendPasswordReset: ref.watch(sendPasswordResetUseCaseProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final authStateProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAdmin;
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final firebaseReadyProvider = FutureProvider<bool>((ref) async {
  return true;
});

