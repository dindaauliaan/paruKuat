import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/services/breath_detector_service.dart';
import '../data/supabase_game_repository.dart';
import '../domain/balloon_game_state.dart';
import '../domain/breath_session_stat.dart';
import '../domain/game_repository.dart';

// ====================================================================
// PROVIDERS
// ====================================================================

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return SupabaseGameRepository(client: Supabase.instance.client);
});

/// Provider singleton untuk BreathDetectorService.
final breathDetectorProvider = Provider<BreathDetectorService>((ref) {
  final service = BreathDetectorService();
  ref.onDispose(() => service.dispose());
  return service;
});

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, BalloonGameState>((ref) {
  final repo = ref.watch(gameRepositoryProvider);
  final breathDetector = ref.watch(breathDetectorProvider);
  return GameNotifier(repo, breathDetector);
});

// ====================================================================
// GAME NOTIFIER
// ====================================================================

class GameNotifier extends StateNotifier<BalloonGameState> {
  final GameRepository _repository;
  final BreathDetectorService _breathDetector;
  Timer? _timer;

  // ── Konstanta Game ────────────────────────────────────────────────

  /// Inflasi per tick saat user exhale (hold / mic).
  static const double _inflateRate = 0.025;

  /// Deflasi per tick saat user tidak hold / tidak bernapas.
  static const double _deflateRate = 0.006;

  /// Deflasi lebih cepat di mic mode (napas lebih alami).
  static const double _micDeflateMultiplier = 1.5;

  /// Ukuran minimum balon (terlalu kempis = game over).
  static const double _minSize = 0.05;

  /// Ukuran maksimum balon (oversize = pop).
  static const double _maxSize = 1.0;

  /// Threshold ukuran balon untuk mulai terbang.
  static const double _floatThreshold = 0.3;

  /// Kenaikan altitude per tick saat terbang.
  static const double _altitudeGainRate = 6.0;

  /// Penurunan altitude per tick saat tidak terbang.
  static const double _altitudeLossRate = 3.0;

  /// Altitude maksimum (feet).
  static const double _maxAltitude = 10000;

  /// Interval timer (ms) — 200ms = 5 tick/detik.
  static const int _tickIntervalMs = 200;

  /// Jumlah tick per detik.
  static const int _ticksPerSecond = 1000 ~/ _tickIntervalMs; // = 5

  /// Threshold power untuk mendeteksi "sedang bernapas" (mic mode).
  static const double _breathingThreshold = 10.0; // 10%

  GameNotifier(this._repository, this._breathDetector)
      : super(const BalloonGameState());

  @override
  void dispose() {
    _timer?.cancel();
    _breathDetector.stopListening();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────

  /// Mulai game baru — coba init mic, fallback ke tap & hold.
  Future<void> startGame() async {
    _timer?.cancel();
    _breathDetector.resetStats();

    // Coba init mikrofon
    final micGranted = await _breathDetector.startListening();
    if (micGranted) {
      // Mode mikrofon berhasil
      state = BalloonGameState(
        balloonSize: 0.3,
        altitude: 0,
        breathingPower: 0,
        score: 0,
        isGameActive: true,
        isPaused: false,
        isGameOver: false,
        isCompleted: false,
        isBalloonPopped: false,
        timeElapsed: 0,
        holdDurationTicks: 0,
        isHolding: false,
        tickCounter: 0,
        useMicMode: true,
        isListeningMic: true,
        micPermissionStatus: 1, // granted
      );
    } else {
      // Fallback ke tap & hold
      state = BalloonGameState(
        balloonSize: 0.3,
        altitude: 0,
        breathingPower: 0,
        score: 0,
        isGameActive: true,
        isPaused: false,
        isGameOver: false,
        isCompleted: false,
        isBalloonPopped: false,
        timeElapsed: 0,
        holdDurationTicks: 0,
        isHolding: false,
        tickCounter: 0,
        useMicMode: false,
        isListeningMic: false,
        micPermissionStatus: _breathDetector.permissionStatus ==
                    MicPermissionStatus.denied ||
                _breathDetector.permissionStatus ==
                    MicPermissionStatus.permanentlyDenied
            ? 2
            : 0,
      );
    }

    _startTimer();
  }

  /// Pause game — stop mic sementara.
  void pauseGame() {
    _timer?.cancel();
    if (state.useMicMode) {
      _breathDetector.stopListening();
    }
    state = state.copyWith(isPaused: true, isGameActive: false);
  }

  /// Resume game dari pause — restart mic.
  void resumeGame() {
    state = state.copyWith(isPaused: false, isGameActive: true);
    if (state.useMicMode) {
      // Restart mic; jika gagal, tetap lanjut dengan power 0
      _breathDetector.startListening();
    }
    _startTimer();
  }

  /// User mulai exhale (tap down) — hanya untuk tap mode.
  void startExhale() {
    if (state.useMicMode) return; // di mic mode, ignore tap
    if (!state.isGameActive || state.isGameOver || state.isCompleted) return;
    state = state.copyWith(isHolding: true, holdDurationTicks: 0);
  }

  /// User berhenti exhale (tap up) — hanya untuk tap mode.
  void stopExhale() {
    if (state.useMicMode) return; // di mic mode, ignore tap
    if (!state.isGameActive || state.isGameOver || state.isCompleted) return;
    state = state.copyWith(isHolding: false, holdDurationTicks: 0);
  }

  /// Coba minta permission mic lagi setelah ditolak.
  Future<void> requestMicPermission() async {
    final granted = await _breathDetector.requestPermission();
    if (granted) {
      state = state.copyWith(micPermissionStatus: 1);
    } else {
      state = state.copyWith(micPermissionStatus: 2);
    }
  }

  /// Ganti mode ke tap & hold (ketika mic tidak tersedia).
  void switchToTapMode() {
    _breathDetector.stopListening();
    state = state.copyWith(useMicMode: false, isListeningMic: false);
  }

  /// Reset game ke idle — stop mic.
  void resetGame() {
    _timer?.cancel();
    _breathDetector.stopListening();
    state = const BalloonGameState();
  }

  // ── Timer ─────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: _tickIntervalMs), (_) {
      _tick();
    });
  }

  /// Tick utama — dipanggil setiap 200ms.
  void _tick() {
    if (state.isPaused || state.isGameOver || state.isCompleted) return;

    double newSize = state.balloonSize;
    double newAltitude = state.altitude;
    int newScore = state.score;
    int newTime = state.timeElapsed;
    final int newTick = state.tickCounter + 1;

    // ── 1. Dapatkan effective breathing power ──
    // Di mic mode: baca dari BreathDetectorService
    // Di tap mode: 80% jika hold, 0% jika tidak
    final double effectivePower;
    if (state.useMicMode) {
      effectivePower = _breathDetector.latestBreathPower;
    } else {
      effectivePower = state.isHolding ? 80.0 : 0.0;
    }

    // ── 2. Update breathing power di state ──
    final double newBreathingPower = effectivePower;

    // ── 3. Update label ──
    final String newLabel = _breathDetector.getBreathingLabel(effectivePower);

    // ── 4. Update microphoneDb ──
    final double newDb = state.useMicMode ? _breathDetector.latestDb : double.negativeInfinity;

    // ── 5. Update power history (max 30 entries) ──
    final List<double> newHistory = List.of(state.powerHistory);
    newHistory.add(effectivePower);
    if (newHistory.length > 30) {
      newHistory.removeAt(0);
    }

    // ── 6. Inflasi / Deflasi ──
    if (effectivePower > _breathingThreshold) {
      // Breathing detected — inflasi proporsional
      final normalizedPower =
          ((effectivePower - _breathingThreshold) / (100 - _breathingThreshold))
              .clamp(0.0, 1.0);
      // Power 0% → inflate 0x rate, power 100% → inflate 2.0x rate
      newSize += _inflateRate * (0.3 + (normalizedPower * 1.7));
    } else {
      // Tidak bernapas — deflasi
      final deflateMultiplier = state.useMicMode ? _micDeflateMultiplier : 1.0;
      newSize -= _deflateRate * deflateMultiplier;
    }

    // ── 7. Pop Check (over-inflated) ──
    if (newSize > _maxSize) {
      _endGame(
        isPopped: true,
        tick: newTick,
        altitude: newAltitude,
        score: newScore,
        time: newTime,
        breathingPower: newBreathingPower,
      );
      return;
    }

    // Clamp size
    newSize = newSize.clamp(_minSize, _maxSize);

    // ── 8. Fall Check (too deflated) ──
    if (newSize <= _minSize) {
      _endGame(
        isPopped: false,
        tick: newTick,
        altitude: newAltitude,
        size: newSize,
        score: newScore,
        time: newTime,
        breathingPower: newBreathingPower,
      );
      return;
    }

    // ── 9. Update Altitude ──
    if (newSize > _floatThreshold) {
      final ratio = ((newSize - _floatThreshold) / (1.0 - _floatThreshold))
          .clamp(0.0, 1.0);
      newAltitude =
          (newAltitude + _altitudeGainRate * ratio).clamp(0, _maxAltitude);
      // Bonus altitude score
      newScore += (ratio * 5).round();
    } else {
      newAltitude = (newAltitude - _altitudeLossRate).clamp(0, _maxAltitude);
    }

    // ── 10. Waktu & Skor Dasar ──
    if (newTick % _ticksPerSecond == 0) {
      newTime = state.timeElapsed + 1;
      newScore += 10; // Skor dasar per detik survive
    }

    // ── 11. Completion Check ──
    if (newTime >= state.gameDuration) {
      _timer?.cancel();
      _breathDetector.stopListening();
      state = state.copyWith(
        balloonSize: newSize,
        altitude: newAltitude,
        score: newScore,
        timeElapsed: newTime,
        isGameActive: false,
        isCompleted: true,
        isListeningMic: false,
        breathingPower: newBreathingPower,
        microphoneDb: newDb,
        powerHistory: newHistory,
        breathLabel: newLabel,
        tickCounter: newTick,
      );
      return;
    }

    // ── Normal update ──
    state = state.copyWith(
      balloonSize: newSize,
      altitude: newAltitude,
      score: newScore,
      timeElapsed: newTime,
      isListeningMic: state.useMicMode,
      breathingPower: newBreathingPower,
      microphoneDb: newDb,
      powerHistory: newHistory,
      breathLabel: newLabel,
      tickCounter: newTick,
    );
  }

  /// Akhiri game (pop atau jatuh).
  void _endGame({
    required bool isPopped,
    required int tick,
    double altitude = 0,
    double size = 0.3,
    int score = 0,
    int time = 0,
    double breathingPower = 0,
  }) {
    _timer?.cancel();
    _breathDetector.stopListening();
    state = state.copyWith(
      balloonSize: size.clamp(_minSize, _maxSize),
      altitude: altitude,
      score: score,
      timeElapsed: time,
      isGameActive: false,
      isGameOver: true,
      isBalloonPopped: isPopped,
      isListeningMic: false,
      breathingPower: breathingPower,
      tickCounter: tick,
    );
  }

  // ── Save ──────────────────────────────────────────────────────────

  /// Simpan GameStat ke Supabase setelah game selesai.
  Future<void> saveGameStat(int userId) async {
    if ((!state.isCompleted && !state.isGameOver) || state.isGameSaved) return;

    try {
      await _repository.saveGameStat(
        userId: userId,
        currentAltitude: state.altitude.round(),
        breathingPower: state.breathingPower,
      );

      // Jika mic mode, simpan breath session stat juga
      if (state.useMicMode) {
        await _repository.saveBreathSessionStat(
          userId: userId,
          stat: BreathSessionStat(
            averageBreathPower: _calculateAveragePower(),
            peakBreathPower: _breathDetector.peakBreathPower,
            stableBreathDurationSec:
                (_breathDetector.stableBreathDurationMs / 1000).round(),
            totalExhaleCount: _breathDetector.totalExhaleCount,
            usedMicrophone: true,
          ),
        );
      }

      state = state.copyWith(isGameSaved: true);
    } catch (_) {
      // Gagal save — tidak critical
      state = state.copyWith(isGameSaved: true);
    }
  }

  /// Hitung rata-rata power dari history.
  double _calculateAveragePower() {
    final history = state.powerHistory;
    if (history.isEmpty) return 0;
    return history.reduce((a, b) => a + b) / history.length;
  }
}
