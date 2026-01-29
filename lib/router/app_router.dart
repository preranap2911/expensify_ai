import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/receipts/receipt_detail_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',

    // 🔐 AUTH + EMAIL VERIFICATION GUARD
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final emailVerified = user?.emailVerified ?? false;

      final location = state.matchedLocation;

      final isAuthRoute =
          location == '/login' || location == '/register';
      final isPublicRoute =
          location == '/login' ||
              location == '/register' ||
              location == '/forgot-password';

      // ❌ Not logged in → force login
      if (!loggedIn && !isPublicRoute) {
        return '/login';
      }

      // ⚠️ Logged in but email NOT verified
      if (loggedIn && !emailVerified && location != '/verify-email') {
        return '/verify-email';
      }

      // ✅ Logged in + verified → block auth pages
      if (loggedIn && emailVerified && isAuthRoute) {
        return '/app';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/app',
        builder: (_, __) => const AppShell(),
      ),
      GoRoute(
        path: '/receipt/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReceiptDetailScreen(receiptId: id);
        },
      ),
    ],
  );
});
