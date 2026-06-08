import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/presentation/providers/app_providers.dart';

class AuthGuard {
  final Ref _ref;

  AuthGuard(this._ref);

  String? call(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final isAuthenticated = authState.isAuthenticated;
    final location = state.matchedLocation;
    debugPrint('[AUTH] AuthGuard: location=$location, status=${authState.status}');

    final isAuthRoute = location == RouteConstants.signIn ||
        location == RouteConstants.signUp ||
        location == RouteConstants.forgotPassword;

    if (!isAuthenticated && !isAuthRoute && location != RouteConstants.splash) {
      debugPrint('[AUTH] AuthGuard: redirect TO sign-in FROM $location');
      return '${RouteConstants.signIn}?redirect=${Uri.encodeComponent(state.uri.toString())}';
    }

    if (isAuthenticated && isAuthRoute) {
      debugPrint('[AUTH] AuthGuard: redirect authenticated to home FROM $location');
      return RouteConstants.home;
    }

    debugPrint('[AUTH] AuthGuard: ALLOW $location');
    return null;
  }
}
