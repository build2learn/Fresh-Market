import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/presentation/providers/app_providers.dart';

class AdminGuard {
  final Ref _ref;

  AdminGuard(this._ref);

  String? call(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    if (!location.startsWith('/admin')) return null;

    final authState = _ref.read(authNotifierProvider);
    final isAdmin = authState.isAdmin;
    debugPrint('[AUTH] AdminGuard: location=$location, isAdmin=$isAdmin');

    if (!isAdmin) {
      debugPrint('[AUTH] AdminGuard: redirect non-admin to home');
      return '/home';
    }

    debugPrint('[AUTH] AdminGuard: ALLOW admin access');
    return null;
  }
}
