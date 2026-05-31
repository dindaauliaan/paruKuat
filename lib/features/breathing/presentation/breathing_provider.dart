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
// PACE CONFIGURATIONS
// ====================================================================

/// Mapping exercise type ID → BreathingPace.
///
/// Setiap jenis latihan memiliki pace yang berbeda sesuai tujuan terapeutiknya.
BreathingPace paceForExerciseType(int exerciseTypeId) {
  switch (exerciseTypeId) {
    case 1: // Deep Lung Recovery — slow & deep
      return const BreathingPace(
        inhaleSeconds: 4,
        holdSeconds: 2,
        exhaleSeconds: 6,
        restSeconds: 2,
      );
    case 2: // Pursed Lip Breathing — shorter inhale, focused exhale
      return const BreathingPace(
        inhaleSeconds: 2,
        holdSeconds: 1,
        exhaleSeconds: 4,
        restSeconds: 2,
      );
    case 3: // Diaphragmatic Breathing — long & full
      return const BreathingPace(
        inhaleSeconds: 5,
        holdSeconds: 3,
        exhaleSeconds: 7,
        restSeconds: 3,
      );
    default:
      return const BreathingPace(
        inhaleSeconds: 4,
        holdSeconds: 2,
        exhaleSeconds: 6,
        restSeconds: 2,
      );
  }
}

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
    final pace = paceForExerciseType(state.selectedExerciseTypeId);
    final initialPhase = BreathingPhase.inhale;
    // Hitung total cycles dari total durasi exercise type dibagi cycle duration
    final totalCycles = _resolveTotalCycles(pace);

    state = BreathingState(
      phase: initialPhase,
      secondsRemaining: pace.inhaleSeconds,
      currentCycle: 1,
      totalCycles: totalCycles,
      isRunning: true,
      isCompleted: false,
      selectedExerciseTypeId: state.selectedExerciseTypeId,
      pace: pace,
      totalSecondsElapsed: 0,
      circleScale: 0.7,
      currentColor: _colorForPhase(initialPhase, 0.0, pace),
    );
    _startTimer();
  }

  void pauseSession() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resumeSession() {
    // Reset sessionSaved agar ketika pause/stop berikutnya,
    // saveSession bisa menyimpan data cycle tambahan
    state = state.copyWith(isRunning: true, sessionSaved: false);
    _startTimer();
  }

  void stopSession() {
    _timer?.cancel();
    state = const BreathingState();
  }

  /// Hitung total cycles dari total durasi exercise type / cycleDuration.
  /// Fallback jika tidak dikenal: 8 cycles.
  int _resolveTotalCycles(BreathingPace pace) {
    final durationMap = {
      1: 112, // Deep Lung Recovery
      2: 112, // Pursed Lip Breathing
      3: 168, // Diaphragmatic Breathing
    };
    final totalDuration = durationMap[state.selectedExerciseTypeId] ?? 112;
    final cycles = totalDuration ~/ pace.cycleDuration;
    return cycles > 0 ? cycles : 8;
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
      final phaseDuration = state.pace.secondsFor(state.phase);
      final phaseProgress =
          (phaseDuration - newRemaining) / phaseDuration;
      state = state.copyWith(
        secondsRemaining: newRemaining,
        totalSecondsElapsed: newElapsed,
        circleScale: _scaleForPhase(state.phase, phaseProgress),
        currentColor: _colorForPhase(state.phase, phaseProgress, state.pace),
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
        secondsRemaining: state.pace.inhaleSeconds,
        currentCycle: nextCycle,
        totalSecondsElapsed: newElapsed,
        circleScale: 0.7,
        currentColor: _colorForPhase(newPhase, 0.0, state.pace),
      );
    } else {
      // Pindah ke fase berikutnya dalam cycle yang sama
      final newPhase = phases[currentIndex + 1];
      state = state.copyWith(
        phase: newPhase,
        secondsRemaining: state.pace.secondsFor(newPhase),
        totalSecondsElapsed: newElapsed,
        circleScale: _scaleForPhase(newPhase, 0.0),
        currentColor: _colorForPhase(newPhase, 0.0, state.pace),
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
  Color _colorForPhase(BreathingPhase phase, double progress, BreathingPace pace) {
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
  ///
  /// Bisa dipanggil kapan saja — baik sesi penuh (`isCompleted`) maupun
  /// sesi parsial (user pause/stop di tengah jalan). Data yang disimpan
  /// berdasarkan jumlah cycle yang sudah benar-benar diselesaikan.
  ///
  /// Returns `true` jika berhasil, `false` jika gagal disimpan.
  /// Caller bisa menggunakan return value untuk retry atau indikasi error.
  Future<bool> saveSession(int userId) async {
    if (state.sessionSaved) return true;
    if (state.totalSecondsElapsed == 0) return true; // belum ada progress

    // Jumlah cycle yang benar-benar selesai
    // currentCycle = cycle yang sedang dikerjakan → completed = currentCycle - 1
    final completedCycles = state.isCompleted
        ? state.totalCycles
        : (state.currentCycle - 1).clamp(1, state.totalCycles);

    final vitalCapacity =
        SupabaseBreathingRepository.simulateVitalCapacity(completedCycles);
    final oxygenLevel = SupabaseBreathingRepository.simulateOxygenLevel();
    final breathingRate =
        SupabaseBreathingRepository.calculateBreathingRate(
      completedCycles,
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
      return true;
    } catch (e) {
      debugPrint('❌ Gagal simpan exercise log: $e');
      // Jangan mark sessionSaved agar retry bisa dilakukan
      return false;
    }
  }
}
