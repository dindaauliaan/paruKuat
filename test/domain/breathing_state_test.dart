import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paru_kuat/features/breathing/domain/breathing_phase.dart';
import 'package:paru_kuat/features/breathing/domain/breathing_state.dart';

void main() {
  group('BreathingState', () {
    group('default constructor', () {
      final state = const BreathingState();

      test('phase default → inhale', () {
        expect(state.phase, BreathingPhase.inhale);
      });

      test('secondsRemaining default → 4', () {
        expect(state.secondsRemaining, 4);
      });

      test('currentCycle default → 1', () {
        expect(state.currentCycle, 1);
      });

      test('totalCycles default → 8', () {
        expect(state.totalCycles, 8);
      });

      test('isRunning default → false', () {
        expect(state.isRunning, false);
      });

      test('isCompleted default → false', () {
        expect(state.isCompleted, false);
      });

      test('sessionSaved default → false', () {
        expect(state.sessionSaved, false);
      });

      test('selectedExerciseTypeId default → 1', () {
        expect(state.selectedExerciseTypeId, 1);
      });

      test('totalSecondsElapsed default → 0', () {
        expect(state.totalSecondsElapsed, 0);
      });

      test('circleScale default → 0.7', () {
        expect(state.circleScale, 0.7);
      });

      test('currentColor default → primary pink', () {
        expect(state.currentColor, const Color(0xFFCD2C58));
      });
    });

    group('copyWith', () {
      test('mengubah phase', () {
        final state = const BreathingState();
        final updated = state.copyWith(phase: BreathingPhase.hold);
        expect(updated.phase, BreathingPhase.hold);
        expect(updated.secondsRemaining, state.secondsRemaining);
      });

      test('mengubah secondsRemaining', () {
        final state = const BreathingState();
        final updated = state.copyWith(secondsRemaining: 3);
        expect(updated.secondsRemaining, 3);
      });

      test('mengubah beberapa field sekaligus', () {
        final state = const BreathingState();
        final updated = state.copyWith(
          currentCycle: 3,
          isRunning: true,
          circleScale: 0.85,
        );
        expect(updated.currentCycle, 3);
        expect(updated.isRunning, true);
        expect(updated.circleScale, 0.85);
        // Field lain tidak berubah
        expect(updated.phase, BreathingPhase.inhale);
        expect(updated.isCompleted, false);
      });

      test('tanpa parameter → instance sama', () {
        final state = const BreathingState();
        final updated = state.copyWith();
        expect(updated.phase, state.phase);
        expect(updated.secondsRemaining, state.secondsRemaining);
        expect(updated.currentCycle, state.currentCycle);
        expect(updated.isRunning, state.isRunning);
      });
    });

    group('cycleDuration', () {
      test('cycleDuration = durasi fase saat ini', () {
        final state = BreathingState(phase: BreathingPhase.exhale);
        expect(state.cycleDuration, 6);
      });
    });

    group('totalSessionDuration', () {
      test('8 cycles × 14 detik = 112 detik', () {
        const state = BreathingState(totalCycles: 8);
        expect(state.totalSessionDuration, 112);
      });

      test('4 cycles × 14 detik = 56 detik', () {
        final state = BreathingState(totalCycles: 4);
        expect(state.totalSessionDuration, 56);
      });
    });

    group('totalSecondsRemaining', () {
      test('0 elapsed → sama dengan totalSessionDuration', () {
        const state = BreathingState(totalCycles: 8);
        expect(state.totalSecondsRemaining, state.totalSessionDuration);
      });

      test('30 detik elapsed → sisa 82 detik', () {
        final state = BreathingState(
          totalCycles: 8,
          totalSecondsElapsed: 30,
        );
        expect(state.totalSecondsRemaining, 82);
      });
    });
  });
}
