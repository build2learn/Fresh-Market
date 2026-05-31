import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

class AdminGuard {
  final Ref _ref;

  AdminGuard(this._ref);

  String? call(BuildContext context, GoRouterState state) {
    final isAdmin = _ref.read(isAdminProvider);

    if (!isAdmin) {
      return '/home';
    }

    return null;
  }
}
