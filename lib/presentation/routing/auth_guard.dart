import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

class AuthGuard {
  final Ref _ref;

  AuthGuard(this._ref);

  String? call(BuildContext context, GoRouterState state) {
    final isAuthenticated = _ref.read(authStateProvider);
    final isAuthRoute = state.matchedLocation == RouteConstants.signIn ||
        state.matchedLocation == RouteConstants.signUp ||
        state.matchedLocation == RouteConstants.forgotPassword;

    if (!isAuthenticated && !isAuthRoute && state.matchedLocation != RouteConstants.splash) {
      return '${RouteConstants.signIn}?redirect=${Uri.encodeComponent(state.uri.toString())}';
    }

    if (isAuthenticated && isAuthRoute) {
      return RouteConstants.home;
    }

    return null;
  }
}
