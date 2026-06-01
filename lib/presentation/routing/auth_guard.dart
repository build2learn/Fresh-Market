import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

class AuthGuard {
  final Ref _ref;

  AuthGuard(this._ref);

  String? call(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final isAuthenticated = authState.isAuthenticated;
    final location = state.matchedLocation;
    debugPrint('[AuthGuard] Checking: location=$location, authStatus=${authState.status}');

    final isAuthRoute = location == RouteConstants.signIn ||
        location == RouteConstants.signUp ||
        location == RouteConstants.forgotPassword;

    if (!isAuthenticated && !isAuthRoute && location != RouteConstants.splash) {
      debugPrint('[AuthGuard] Redirecting to sign-in from $location');
      return '${RouteConstants.signIn}?redirect=${Uri.encodeComponent(state.uri.toString())}';
    }

    if (isAuthenticated && isAuthRoute) {
      debugPrint('[AuthGuard] Redirecting authenticated user to home from $location');
      return RouteConstants.home;
    }

    debugPrint('[AuthGuard] Allowing access to $location');
    return null;
  }
}
