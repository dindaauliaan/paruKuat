import 'package:flutter/material.dart';

import 'breathing_phase.dart';

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
      totalSecondsElapsed:
          totalSecondsElapsed ?? this.totalSecondsElapsed,
      circleScale: circleScale ?? this.circleScale,
      currentColor: currentColor ?? this.currentColor,
    );
  }

  /// Total detik per cycle.
  int get cycleDuration => phase.durationSeconds;

  /// Total detik seluruh sesi.
  int get totalSessionDuration {
    int total = 0;
    for (final p in BreathingPhase.values) {
      total += p.durationSeconds;
    }
    return total * totalCycles;
  }

  /// Sisa detik seluruh sesi.
  int get totalSecondsRemaining =>
      totalSessionDuration - totalSecondsElapsed;
}
