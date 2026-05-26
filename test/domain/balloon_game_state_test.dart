import 'package:flutter_test/flutter_test.dart';
import 'package:paru_kuat/features/game/domain/balloon_game_state.dart';

void main() {
  group('BalloonGameState default constructor', () {
    test('balloonSize default → 0.3', () {
      const state = BalloonGameState();
      expect(state.balloonSize, 0.3);
    });

    test('altitude default → 0', () {
      const state = BalloonGameState();
      expect(state.altitude, 0);
    });

    test('breathingPower default → 0', () {
      const state = BalloonGameState();
      expect(state.breathingPower, 0);
    });

    test('score default → 0', () {
      const state = BalloonGameState();
      expect(state.score, 0);
    });

    test('isGameActive default → false', () {
      const state = BalloonGameState();
      expect(state.isGameActive, false);
    });

    test('isBalloonPopped default → false', () {
      const state = BalloonGameState();
      expect(state.isBalloonPopped, false);
    });

    test('isGameOver default → false', () {
      const state = BalloonGameState();
      expect(state.isGameOver, false);
    });

    test('isCompleted default → false', () {
      const state = BalloonGameState();
      expect(state.isCompleted, false);
    });

    test('isPaused default → false', () {
      const state = BalloonGameState();
      expect(state.isPaused, false);
    });

    test('timeElapsed default → 0', () {
      const state = BalloonGameState();
      expect(state.timeElapsed, 0);
    });

    test('gameDuration default → 60', () {
      const state = BalloonGameState();
      expect(state.gameDuration, 60);
    });

    test('isGameSaved default → false', () {
      const state = BalloonGameState();
      expect(state.isGameSaved, false);
    });

    test('holdDurationTicks default → 0', () {
      const state = BalloonGameState();
      expect(state.holdDurationTicks, 0);
    });

    test('isHolding default → false', () {
      const state = BalloonGameState();
      expect(state.isHolding, false);
    });

    test('tickCounter default → 0', () {
      const state = BalloonGameState();
      expect(state.tickCounter, 0);
    });

    // ── Mic fields ──

    test('useMicMode default → false', () {
      const state = BalloonGameState();
      expect(state.useMicMode, false);
    });

    test('isListeningMic default → false', () {
      const state = BalloonGameState();
      expect(state.isListeningMic, false);
    });

    test('microphoneDb default → negativeInfinity', () {
      const state = BalloonGameState();
      expect(state.microphoneDb, double.negativeInfinity);
    });

    test('powerHistory default → empty list', () {
      const state = BalloonGameState();
      expect(state.powerHistory, isEmpty);
    });

    test('micPermissionStatus default → 0', () {
      const state = BalloonGameState();
      expect(state.micPermissionStatus, 0);
    });

    test('breathLabel default → empty string', () {
      const state = BalloonGameState();
      expect(state.breathLabel, '');
    });
  });

  group('BalloonGameState custom constructor', () {
    test('mengatur semua field mic dengan benar', () {
      final state = BalloonGameState(
        useMicMode: true,
        isListeningMic: true,
        microphoneDb: 65.5,
        powerHistory: [10, 20, 30, 40, 50],
        micPermissionStatus: 1,
        breathLabel: 'Bagus!',
      );

      expect(state.useMicMode, true);
      expect(state.isListeningMic, true);
      expect(state.microphoneDb, 65.5);
      expect(state.powerHistory, [10, 20, 30, 40, 50]);
      expect(state.micPermissionStatus, 1);
      expect(state.breathLabel, 'Bagus!');
    });
  });

  group('BalloonGameState copyWith', () {
    test('copyWith mengubah useMicMode', () {
      final state = BalloonGameState().copyWith(useMicMode: true);
      expect(state.useMicMode, true);
    });

    test('copyWith mengubah isListeningMic', () {
      final state = BalloonGameState().copyWith(isListeningMic: true);
      expect(state.isListeningMic, true);
    });

    test('copyWith mengubah microphoneDb', () {
      final state = BalloonGameState().copyWith(microphoneDb: 72.0);
      expect(state.microphoneDb, 72.0);
    });

    test('copyWith mengubah powerHistory', () {
      final history = [15.0, 25.0, 35.0];
      final state = BalloonGameState().copyWith(powerHistory: history);
      expect(state.powerHistory, [15.0, 25.0, 35.0]);
    });

    test('copyWith powerHistory adalah list baru (immutable)', () {
      final original = [10.0];
      final state = BalloonGameState().copyWith(powerHistory: original);
      original.add(20.0);
      // powerHistory tidak terpengaruh oleh perubahan list original
      expect(state.powerHistory, [10.0]);
    });

    test('copyWith mengubah micPermissionStatus', () {
      final state = BalloonGameState().copyWith(micPermissionStatus: 2);
      expect(state.micPermissionStatus, 2);
    });

    test('copyWith mengubah breathLabel', () {
      final state = BalloonGameState().copyWith(breathLabel: 'Mantap! 🔥');
      expect(state.breathLabel, 'Mantap! 🔥');
    });

    test('copyWith multiple fields sekaligus', () {
      final state = BalloonGameState().copyWith(
        useMicMode: true,
        isListeningMic: true,
        microphoneDb: 80.0,
        micPermissionStatus: 1,
        breathLabel: 'Terlalu kuat!',
      );

      expect(state.useMicMode, true);
      expect(state.isListeningMic, true);
      expect(state.microphoneDb, 80.0);
      expect(state.micPermissionStatus, 1);
      expect(state.breathLabel, 'Terlalu kuat!');
    });

    test('copyWith tanpa parameter → field tetap default', () {
      final original = BalloonGameState(
        useMicMode: true,
        isListeningMic: true,
        microphoneDb: 55.0,
        micPermissionStatus: 1,
        breathLabel: 'Bagus!',
      );
      final copied = original.copyWith();
      expect(copied.useMicMode, true);
      expect(copied.isListeningMic, true);
      expect(copied.microphoneDb, 55.0);
      expect(copied.micPermissionStatus, 1);
      expect(copied.breathLabel, 'Bagus!');
    });
  });

  group('BalloonGameState computed properties', () {
    test('remainingTime = gameDuration - timeElapsed', () {
      final state = BalloonGameState(gameDuration: 60, timeElapsed: 23);
      expect(state.remainingTime, 37);
    });

    test('formattedTimeElapsed format mm:ss (0 menit)', () {
      final state = BalloonGameState(timeElapsed: 45);
      expect(state.formattedTimeElapsed, '00:45');
    });

    test('formattedTimeElapsed format mm:ss (1 menit 30 detik)', () {
      final state = BalloonGameState(timeElapsed: 90);
      expect(state.formattedTimeElapsed, '01:30');
    });

    test('formattedRemainingTime format mm:ss', () {
      final state = BalloonGameState(gameDuration: 60, timeElapsed: 15);
      expect(state.formattedRemainingTime, '00:45');
    });
  });
}