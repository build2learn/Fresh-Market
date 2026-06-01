import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

class AdminGuard {
  final Ref _ref;

  AdminGuard(this._ref);

  String? call(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final isAdmin = authState.isAdmin;
    debugPrint('[AdminGuard] Checking: location=${state.matchedLocation}, isAdmin=$isAdmin, authStatus=${authState.status}');

    if (!isAdmin) {
      debugPrint('[AdminGuard] Redirecting non-admin to home');
      return '/home';
    }

    debugPrint('[AdminGuard] Allowing admin access');
    return null;
  }
}
