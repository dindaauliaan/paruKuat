import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../../features/auth/presentation/auth_notifier.dart';

// Pages
import '../../pages/welcome_page.dart';
import '../../pages/login_page.dart';
import '../../pages/register_page.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/breathing/presentation/breathing_screen.dart';
import '../../features/game/presentation/game_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/notification/presentation/notification_screen.dart';

// ====================================================================
// ROUTER PROVIDER
// Menggunakan authNotifierProvider sebagai dependency agar router
// otomatis me-redirect saat auth state berubah (login/logout).
// ====================================================================
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true,

    // Refresh router setiap kali auth state berubah
    refreshListenable: _AuthStateListenable(ref),

    // ── AUTH GUARD ─────────────────────────────────────────────────
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final currentPath = state.matchedLocation;

      // Route publik — boleh diakses siapa saja
      const publicRoutes = {
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.register,
      };

      final isPublic = publicRoutes.contains(currentPath);
      final isAuthenticated = authState is AuthAuthenticated;
      final isInitialOrLoading =
          authState is AuthInitial || authState is AuthLoading;

      // Saat masih loading session — jangan redirect dulu
      if (isInitialOrLoading) return null;

      if (isAuthenticated && isPublic) {
        // Sudah login tapi buka halaman publik → ke home
        return AppRoutes.home;
      }

      if (!isAuthenticated && !isPublic) {
        // Belum login, coba akses protected route → ke login
        return AppRoutes.login;
      }

      return null; // Tidak perlu redirect
    },

    routes: [
      // ── PUBLIC ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomePageParukuat(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginParukuat(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterParukuat(),
      ),

      // ── PROTECTED ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.breathing,
        name: 'breathing',
        builder: (context, state) => const BreathingScreen(),
      ),
      GoRoute(
        path: AppRoutes.games,
        name: 'games',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        name: 'progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],

    errorBuilder: (context, state) => _RouteErrorPage(error: state.error),
  );
});

// ====================================================================
// AUTH STATE LISTENABLE
// Adapter antara Riverpod StateNotifier dan GoRouter refreshListenable.
// ====================================================================
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    // Defer 1 frame untuk hindari notifyListeners() saat GoRouter konstruksi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AuthState>(authNotifierProvider, (_, _) {
        notifyListeners();
      });
    });
  }
}

// ====================================================================
// ERROR PAGE
// ====================================================================
class _RouteErrorPage extends StatelessWidget {
  final Exception? error;
  const _RouteErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC7C7),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFCD2C58), size: 56),
            const SizedBox(height: 16),
            const Text(
              'Halaman tidak ditemukan',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFCD2C58),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(fontFamily: 'Manrope', color: Color(0xFF3E4949)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
