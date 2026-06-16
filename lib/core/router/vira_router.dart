import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_provider.dart';
import '../../shared/models/vira_enums.dart';

import '../../features/auth/screens/role_select_screen.dart';
import '../../features/auth/screens/otp_screen.dart';

import '../../features/rider/screens/rider_home_screen.dart';
import '../../features/rider/screens/new_request_screen.dart';

import '../../features/courier/screens/courier_home_screen.dart';
import '../../features/courier/screens/job_feed_screen.dart';

import '../../features/dispatch/screens/dispatch_console_screen.dart';

import '../../features/trip/screens/live_tracking_screen.dart';

import '../../features/wallet/screens/wallet_screen.dart';

/// Central routing guard. This is the single place that enforces
/// role boundaries — a Rider session must never resolve a Courier or
/// Dispatch route, and vice versa, regardless of how the user navigates
/// (deep link, back button, manual URL on the web Dispatch build).
class ViraRouter {
  ViraRouter._();

  static GoRouter build(WidgetRef ref) {
    final refreshNotifier = _AuthRefreshNotifier(ref);

    return GoRouter(
      initialLocation: '/auth/role',
      refreshListenable: refreshNotifier,
      redirect: (context, state) {
        final session = ref.read(authProvider);
        final path = state.uri.path;

        final isAuthRoute = path.startsWith('/auth');

        if (session == null) {
          return isAuthRoute ? null : '/auth/role';
        }

        // Authenticated — keep them out of auth routes.
        if (isAuthRoute) {
          return _homeRouteFor(session.role);
        }

        // Role-boundary enforcement: redirect away from routes that
        // don't belong to this session's role.
        if (path.startsWith('/rider') && session.role != ViraRole.rider) {
          return _homeRouteFor(session.role);
        }
        if (path.startsWith('/courier') && session.role != ViraRole.courier) {
          return _homeRouteFor(session.role);
        }
        if (path.startsWith('/dispatch') &&
            session.role != ViraRole.dispatch) {
          return _homeRouteFor(session.role);
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/auth/role',
          builder: (context, state) => const RoleSelectScreen(),
        ),
        GoRoute(
          path: '/auth/otp',
          builder: (context, state) => OtpScreen(
            role: state.extra as ViraRole? ?? ViraRole.rider,
          ),
        ),

        // ── Rider ──
        GoRoute(
          path: '/rider/home',
          builder: (context, state) => const RiderHomeScreen(),
        ),
        GoRoute(
          path: '/rider/new-request',
          builder: (context, state) => const NewRequestScreen(),
        ),

        // ── Courier ──
        GoRoute(
          path: '/courier/home',
          builder: (context, state) => const CourierHomeScreen(),
        ),
        GoRoute(
          path: '/courier/jobs',
          builder: (context, state) => const JobFeedScreen(),
        ),

        // ── Dispatch (also the responsive web build target) ──
        GoRoute(
          path: '/dispatch/console',
          builder: (context, state) => const DispatchConsoleScreen(),
        ),

        // ── Shared: trip tracking and wallet reachable from any role ──
        GoRoute(
          path: '/trip/:tripId',
          builder: (context, state) => LiveTrackingScreen(
            tripId: state.pathParameters['tripId']!,
          ),
        ),
        GoRoute(
          path: '/wallet',
          builder: (context, state) => const WalletScreen(),
        ),
      ],
    );
  }

  static String _homeRouteFor(ViraRole role) => switch (role) {
        ViraRole.rider => '/rider/home',
        ViraRole.courier => '/courier/home',
        ViraRole.dispatch => '/dispatch/console',
      };
}

/// Bridges Riverpod's authProvider to GoRouter's ChangeNotifier-based
/// refresh mechanism. Without this, signing in/out wouldn't trigger
/// GoRouter's `redirect` to re-run, since GoRouter doesn't watch Riverpod
/// providers on its own.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}
