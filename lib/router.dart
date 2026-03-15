import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/shell_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/journal',
  redirect: (BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuth  = session != null;
    final isOnAuth = state.matchedLocation == '/auth';

    if (!isAuth && !isOnAuth) return '/auth';
    if (isAuth && isOnAuth)   return '/journal';
    return null;
  },
  routes: [
    GoRoute(
      path:    '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path:    '/journal',
          builder: (context, state) => const JournalTab(),
        ),
        GoRoute(
          path:    '/vault',
          builder: (context, state) => const VaultTab(),
        ),
        GoRoute(
          path:    '/analytics',
          builder: (context, state) => const AnalyticsTab(),
        ),
        GoRoute(
          path:    '/settings',
          builder: (context, state) => const SettingsTab(),
        ),
      ],
    ),
  ],
);