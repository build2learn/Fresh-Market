import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.listenManual(authNotifierProvider, (prev, next) {
        if (next.status != AuthStatus.uninitialized && mounted) {
          context.go(
            next.isAuthenticated ? RouteConstants.home : RouteConstants.signIn,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
