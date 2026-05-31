import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/auth_repository_provider.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/domain/usecases/auth/sign_in.usecase.dart';
import 'package:fresh_market/domain/usecases/auth/sign_up.usecase.dart';
import 'package:fresh_market/domain/usecases/auth/sign_out.usecase.dart';
import 'package:fresh_market/domain/usecases/auth/send_password_reset.usecase.dart';
import 'package:fresh_market/domain/usecases/auth/get_current_user.usecase.dart';

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
  bool get isAdmin => user?.isAdmin ?? false;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final WatchAuthStateUseCase _watchAuthState;
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;
  final SendPasswordResetUseCase _sendPasswordReset;

  AuthNotifier({
    required WatchAuthStateUseCase watchAuthState,
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignOutUseCase signOut,
    required SendPasswordResetUseCase sendPasswordReset,
  })  : _watchAuthState = watchAuthState,
        _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _sendPasswordReset = sendPasswordReset,
        super(const AuthState()) {
    _init();
  }

  void _init() {
    _watchAuthState.call().listen((user) {
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
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
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    watchAuthState: ref.watch(watchAuthStateUseCaseProvider),
    signIn: ref.watch(signInUseCaseProvider),
    signUp: ref.watch(signUpUseCaseProvider),
    signOut: ref.watch(signOutUseCaseProvider),
    sendPasswordReset: ref.watch(sendPasswordResetUseCaseProvider),
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
