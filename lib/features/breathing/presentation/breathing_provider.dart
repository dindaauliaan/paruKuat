import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase_breathing_repository.dart';
import '../domain/exercise_type.dart';
import '../domain/breathing_phase.dart';
import '../domain/breathing_repository.dart';
import '../domain/breathing_state.dart';

// ====================================================================
// PROVIDERS
// ====================================================================

final breathingRepositoryProvider = Provider<BreathingRepository>((ref) {
  return SupabaseBreathingRepository(client: Supabase.instance.client);
});

final exerciseTypesProvider = FutureProvider<List<ExerciseType>>((ref) {
  final repo = ref.watch(breathingRepositoryProvider);
  return repo.getExerciseTypes();
});

final breathingNotifierProvider =
    StateNotifierProvider<BreathingNotifier, BreathingState>((ref) {
  final repo = ref.watch(breathingRepositoryProvider);
  return BreathingNotifier(repo);
});

// ====================================================================
// BREATHING NOTIFIER
// ====================================================================

class BreathingNotifier extends StateNotifier<BreathingState> {
  final BreathingRepository _repository;
  Timer? _timer;

  BreathingNotifier(this._repository) : super(const BreathingState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────

  void selectExerciseType(int id) {
    if (state.isRunning) return; // jangan ganti saat latihan berjalan
    state = state.copyWith(selectedExerciseTypeId: id);
  }

  void startSession() {
    _timer?.cancel();
    final initialPhase = BreathingPhase.inhale;
    state = BreathingState(
      phase: initialPhase,
      secondsRemaining: initialPhase.durationSeconds,
      currentCycle: 1,
      totalCycles: state.totalCycles,
      isRunning: true,
      isCompleted: false,
      selectedExerciseTypeId: state.selectedExerciseTypeId,
      totalSecondsElapsed: 0,
      circleScale: 0.7,
      currentColor: _colorForPhase(initialPhase, 0.0),
    );
    _startTimer();
  }

  void pauseSession() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resumeSession() {
    state = state.copyWith(isRunning: true);
    _startTimer();
  }

  void stopSession() {
    _timer?.cancel();
    state = const BreathingState();
  }

  // ── Timer ─────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  void _tick() {
    if (!state.isRunning) return;

    final newElapsed = state.totalSecondsElapsed + 1;
    final newRemaining = state.secondsRemaining - 1;

    if (newRemaining > 0) {
      // Masih dalam fase yang sama
      final progress =
          (state.cycleDuration - newRemaining) / state.cycleDuration;
      state = state.copyWith(
        secondsRemaining: newRemaining,
        totalSecondsElapsed: newElapsed,
        circleScale: _scaleForPhase(state.phase, progress),
        currentColor: _colorForPhase(state.phase, progress),
      );
    } else {
      // Fase selesai — pindah ke fase berikutnya
      _advancePhase(newElapsed);
    }
  }

  void _advancePhase(int newElapsed) {
    final phases = BreathingPhase.values;
    final currentIndex = phases.indexOf(state.phase);
    final isLastPhase = currentIndex == phases.length - 1;

    if (isLastPhase) {
      // Rest selesai → cycle berikutnya
      final nextCycle = state.currentCycle + 1;
      if (nextCycle > state.totalCycles) {
        // Semua cycle selesai!
        _timer?.cancel();
        state = state.copyWith(
          isRunning: false,
          isCompleted: true,
          totalSecondsElapsed: newElapsed,
          secondsRemaining: 0,
        );
        return;
      }

      // Mulai cycle baru dengan inhale
      final newPhase = BreathingPhase.inhale;
      state = state.copyWith(
        phase: newPhase,
        secondsRemaining: newPhase.durationSeconds,
        currentCycle: nextCycle,
        totalSecondsElapsed: newElapsed,
        circleScale: 0.7,
        currentColor: _colorForPhase(newPhase, 0.0),
      );
    } else {
      // Pindah ke fase berikutnya dalam cycle yang sama
      final newPhase = phases[currentIndex + 1];
      state = state.copyWith(
        phase: newPhase,
        secondsRemaining: newPhase.durationSeconds,
        totalSecondsElapsed: newElapsed,
        circleScale: _scaleForPhase(newPhase, 0.0),
        currentColor: _colorForPhase(newPhase, 0.0),
      );
    }
  }

  // ── Kalkulasi ────────────────────────────────────────────────────

  /// Skala lingkaran 0.7–1.0 berdasarkan fase & progress.
  double _scaleForPhase(BreathingPhase phase, double progress) {
    // progress: 0.0 – 1.0 dalam fase
    switch (phase) {
      case BreathingPhase.inhale:
        return 0.7 + (0.3 * progress); // 0.7 → 1.0
      case BreathingPhase.hold:
        return 1.0;
      case BreathingPhase.exhale:
        return 1.0 - (0.3 * progress); // 1.0 → 0.7
      case BreathingPhase.rest:
        return 0.7;
    }
  }

  /// Warna berdasarkan fase & progress.
  Color _colorForPhase(BreathingPhase phase, double progress) {
    switch (phase) {
      case BreathingPhase.inhale:
        return Color.lerp(
          const Color(0xFFF48FB1), // soft pink start
          const Color(0xFFCD2C58), // primary pink end
          progress,
        )!;
      case BreathingPhase.hold:
        return const Color(0xFFB39DDB); // lavender
      case BreathingPhase.exhale:
        return Color.lerp(
          const Color(0xFFB39DDB), // lavender start
          const Color(0xFF006565), // teal end
          progress,
        )!;
      case BreathingPhase.rest:
        return const Color(0xFFF48FB1); // soft pink
    }
  }

  // ── Save hasil ───────────────────────────────────────────────────

  /// Simpan ExerciseLog setelah sesi selesai.
  Future<void> saveSession(int userId) async {
    if (!state.isCompleted || state.sessionSaved) return;

    final vitalCapacity =
        SupabaseBreathingRepository.simulateVitalCapacity(state.totalCycles);
    final oxygenLevel = SupabaseBreathingRepository.simulateOxygenLevel();
    final breathingRate =
        SupabaseBreathingRepository.calculateBreathingRate(
      state.totalCycles,
      state.totalSecondsElapsed,
    );

    try {
      await _repository.saveExerciseLog(
        userId: userId,
        exerciseTypeId: state.selectedExerciseTypeId,
        vitalCapacityValue: vitalCapacity,
        oxygenLevel: oxygenLevel,
        breathingRate: breathingRate,
      );
      state = state.copyWith(sessionSaved: true);
    } catch (_) {
      // Gagal save — tidak critical, tetap anggap sesi selesai
      state = state.copyWith(sessionSaved: true);
    }
  }
}
