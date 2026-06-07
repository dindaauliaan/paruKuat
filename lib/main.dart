import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';
import 'core/services/local_notification_service.dart';
import 'features/auth/presentation/auth_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi local notification service
  final notificationService = LocalNotificationService();
  await notificationService.init();

  // Error handler — tampilkan error di layar biar kelihatan
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  try {
    // Inisialisasi Supabase
    await SupabaseConfig.init();

    // Inisialisasi SharedPreferences sebelum runApp
    final prefs = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ParuKuatApp(),
      ),
    );
  } catch (e) {
    // Kalau init gagal, tampilkan error screen
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(0xFFCD2C58)),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memulai aplikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Manrope'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontFamily: 'Manrope', color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParuKuatApp extends ConsumerWidget {
  const ParuKuatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Paru Kuat',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCD2C58),
          brightness: Brightness.light,
        ),
        fontFamily: 'Manrope',
      ),
    );
  }
}
