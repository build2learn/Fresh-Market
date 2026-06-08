import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/presentation/providers/app_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    ref.listen(firebaseReadyProvider, (prev, next) {
      if (next is AsyncData) {
        debugPrint('[SPLASH] Firebase ready');
        _maybeNavigate();
      }
    });

    ref.listen(authNotifierProvider, (prev, next) {
      if (!next.isUninitialized) {
        debugPrint('[SPLASH] Auth resolved');
        _maybeNavigate();
      }
    });
  }

  void _maybeNavigate() {
    if (_navigated || !mounted) return;

    final firebaseReady = ref.read(firebaseReadyProvider);
    final authState = ref.read(authNotifierProvider);

    if (firebaseReady is! AsyncData) return;
    if (authState.isUninitialized) return;

    _navigated = true;

    if (authState.isAuthenticated) {
      if (authState.isAdmin) {
        debugPrint('[SPLASH] Navigating to admin');
        context.go('/admin');
      } else {
        debugPrint('[SPLASH] Navigating to home');
        context.go(RouteConstants.home);
      }
    } else {
      debugPrint('[SPLASH] Navigating to login');
      context.go(RouteConstants.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAsync = ref.watch(firebaseReadyProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store, size: 80, color: context.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Fresh Market', style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold, color: context.colorScheme.primary,
              )),
              const SizedBox(height: 32),
              firebaseAsync.when(
                data: (_) => authState.isUninitialized
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          Icon(
                            authState.isAuthenticated ? Icons.check_circle : Icons.info,
                            color: authState.isAuthenticated ? Colors.green : Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            authState.isAuthenticated ? 'Authenticated' : 'Not signed in',
                            style: context.textTheme.titleMedium,
                          ),
                        ],
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Firebase Error: $e', style: TextStyle(color: context.colorScheme.error)),
              ),
              if (authState.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(authState.errorMessage!, style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.error,
                ), textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
