import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'pages/games_page.dart';
import 'pages/breathing_page.dart';
import 'pages/profile_page.dart';
import 'pages/notification_page.dart';

void main() {
  runApp(const ParuKuatApp());
}

class ParuKuatApp extends StatelessWidget {
  const ParuKuatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paru Kuat',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEB4C4C),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const WelcomePageParukuat(),
      routes: {
        '/home': (context) => const HomeParukuat(),
        '/games': (context) => const GamesParukuat(),
        '/breathing': (context) => const BreathingParukuat(),
        '/profile': (context) => const ProfileParukuat(),
        '/notifications': (context) => const NotificationParukuat(),
      },
    );
  }
}
