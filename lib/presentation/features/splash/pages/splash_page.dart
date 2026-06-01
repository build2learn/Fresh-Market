import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;

  void _navigateToScreen({required bool isAuthenticated}) {
    if (_navigated || !mounted) return;
    _navigated = true;
    final destination = isAuthenticated ? RouteConstants.home : RouteConstants.signIn;
    debugPrint('[SplashPage] Navigating to: $destination');
    context.go(destination);
  }

  Future<void> _checkCurrentUser() async {
    debugPrint('[SplashPage] Checking current user via getCurrentUser()');
    try {
      final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
      final result = await getCurrentUser.call().timeout(const Duration(seconds: 5));
      if (result is Success<UserEntity?>) {
        final isAuthed = result.data != null;
        debugPrint('[SplashPage] getCurrentUser result: ${isAuthed ? "authenticated" : "unauthenticated"}');
        _navigateToScreen(isAuthenticated: isAuthed);
      } else if (result is Failure<UserEntity?>) {
        debugPrint('[SplashPage] getCurrentUser failed: ${result.error.message}');
        _navigateToScreen(isAuthenticated: false);
      }
    } on TimeoutException {
      debugPrint('[SplashPage] getCurrentUser timed out after 5s');
      _navigateToScreen(isAuthenticated: false);
    } catch (e, st) {
      debugPrint('[SplashPage] getCurrentUser error: $e\n$st');
      _navigateToScreen(isAuthenticated: false);
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('[SplashPage] initState started');

    _checkCurrentUser();

    ref.listenManual(authNotifierProvider, (prev, next) {
      if (_navigated) {
        debugPrint('[SplashPage] Auth changed after navigation: ${next.status} - ignoring');
        return;
      }
      final prevStatus = prev?.status;
      debugPrint('[SplashPage] Auth status changed: $prevStatus -> ${next.status}');
      if (next.status != AuthStatus.uninitialized) {
        _navigateToScreen(isAuthenticated: next.isAuthenticated);
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (!_navigated && mounted) {
        debugPrint('[SplashPage] FORCE TIMEOUT - navigating to sign-in');
        _navigateToScreen(isAuthenticated: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    debugPrint('[SplashPage] build - auth status: ${authState.status}');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store,
              size: 80,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Fresh Market',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.primary,
              ),
            ),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                authState.errorMessage!,
                style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            CircularProgressIndicator(
              color: context.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
