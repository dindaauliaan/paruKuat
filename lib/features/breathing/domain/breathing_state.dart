import 'package:flutter/material.dart';

import 'breathing_phase.dart';

/// Konfigurasi durasi tiap fase dalam satu siklus pernapasan.
///
/// Setiap exercise type memiliki pace yang berbeda.
class BreathingPace {
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int restSeconds;

  const BreathingPace({
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.restSeconds,
  });

  /// Total detik 1 siklus penuh.
  int get cycleDuration =>
      inhaleSeconds + holdSeconds + exhaleSeconds + restSeconds;

  /// Label ringkas untuk ditampilkan di UI, misal "4 - 2 - 6 - 2".
  String get label => '$inhaleSeconds - $holdSeconds - $exhaleSeconds - $restSeconds';

  /// Label panjang, misal "Inhale 4s · Hold 2s · Exhale 6s · Rest 2s".
  String get description =>
      'Inhale ${inhaleSeconds}s · Hold ${holdSeconds}s · Exhale ${exhaleSeconds}s · Rest ${restSeconds}s';

  /// Durasi fase tertentu dalam detik.
  int secondsFor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return inhaleSeconds;
      case BreathingPhase.hold:
        return holdSeconds;
      case BreathingPhase.exhale:
        return exhaleSeconds;
      case BreathingPhase.rest:
        return restSeconds;
    }
  }
}

/// Immutable state untuk guided breathing session.
///
/// Semua field final — instance baru dibuat setiap detik oleh [BreathingNotifier].
class BreathingState {
  /// Fase saat ini.
  final BreathingPhase phase;

  /// Detik tersisa pada fase ini.
  final int secondsRemaining;

  /// Cycle ke-n (1-indexed).
  final int currentCycle;

  /// Total cycles untuk sesi ini.
  final int totalCycles;

  /// Apakah timer sedang berjalan.
  final bool isRunning;

  /// Apakah sesi sudah selesai (semua cycle completed).
  final bool isCompleted;

  /// Apakah ExerciseLog sudah disimpan ke Supabase.
  final bool sessionSaved;

  /// ID exercise type yang sedang dipilih.
  final int selectedExerciseTypeId;

  /// Pace latihan — durasi tiap fase dalam 1 siklus.
  final BreathingPace pace;

  /// Total detik yang sudah berlalu sejak sesi dimulai.
  final int totalSecondsElapsed;

  /// Skala lingkaran 0.7–1.0 untuk animasi breathing.
  final double circleScale;

  /// Warna sesuai fase saat ini.
  final Color currentColor;

  const BreathingState({
    this.phase = BreathingPhase.inhale,
    this.secondsRemaining = 4,
    this.currentCycle = 1,
    this.totalCycles = 8,
    this.isRunning = false,
    this.isCompleted = false,
    this.sessionSaved = false,
    this.selectedExerciseTypeId = 1,
    this.pace = const BreathingPace(
      inhaleSeconds: 4,
      holdSeconds: 2,
      exhaleSeconds: 6,
      restSeconds: 2,
    ),
    this.totalSecondsElapsed = 0,
    this.circleScale = 0.7,
    this.currentColor = const Color(0xFFCD2C58),
  });

  /// Copy dengan override field tertentu.
  BreathingState copyWith({
    BreathingPhase? phase,
    int? secondsRemaining,
    int? currentCycle,
    int? totalCycles,
    bool? isRunning,
    bool? isCompleted,
    bool? sessionSaved,
    int? selectedExerciseTypeId,
    BreathingPace? pace,
    int? totalSecondsElapsed,
    double? circleScale,
    Color? currentColor,
  }) {
    return BreathingState(
      phase: phase ?? this.phase,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      sessionSaved: sessionSaved ?? this.sessionSaved,
      selectedExerciseTypeId:
          selectedExerciseTypeId ?? this.selectedExerciseTypeId,
      pace: pace ?? this.pace,
      totalSecondsElapsed:
          totalSecondsElapsed ?? this.totalSecondsElapsed,
      circleScale: circleScale ?? this.circleScale,
      currentColor: currentColor ?? this.currentColor,
    );
  }

  /// Total detik per cycle (berdasarkan pace).
  int get cycleDuration => pace.cycleDuration;

  /// Total detik seluruh sesi.
  int get totalSessionDuration => cycleDuration * totalCycles;

  /// Sisa detik seluruh sesi.
  int get totalSecondsRemaining =>
      totalSessionDuration - totalSecondsElapsed;
}
