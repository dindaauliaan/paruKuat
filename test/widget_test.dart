import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:paru_kuat/widgets/bottom_nav.dart';

/// Test helper: MaterialApp dengan GoRouter minimal untuk test navigasi.
Widget createTestApp({required String initialRoute, required Widget body}) {
  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/home',
        builder: (_, _) => body,
      ),
      GoRoute(
        path: '/games',
        builder: (_, _) => body,
      ),
      GoRoute(
        path: '/breathing',
        builder: (_, _) => body,
      ),
      GoRoute(
        path: '/profile',
        builder: (_, _) => body,
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
  );
}

void main() {
  group('BottomNav', () {
    testWidgets('menampilkan 4 item navigasi', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          initialRoute: '/home',
          body: const Scaffold(
            body: Column(
              children: [
                Spacer(),
                BottomNav(currentRoute: '/home'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('GAMES'), findsOneWidget);
      expect(find.text('BREATHING'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget);
    });

    testWidgets('item yang aktif memiliki style berbeda', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          initialRoute: '/games',
          body: const Scaffold(
            body: Column(
              children: [
                Spacer(),
                BottomNav(currentRoute: '/games'),
              ],
            ),
          ),
        ),
      );

      // 'GAMES' adalah item aktif → teks putih
      final gamesText = tester.widget<Text>(find.text('GAMES'));
      expect(gamesText.style?.color, Colors.white);

      // 'HOME' tidak aktif → teks gelap
      final homeText = tester.widget<Text>(find.text('HOME'));
      expect(homeText.style?.color, const Color(0xFF3E4949));
    });
  });
}
