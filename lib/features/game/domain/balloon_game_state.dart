/// Immutable state for the Balloon Breathing Game.
///
/// Semua field final — instance baru dibuat setiap tick oleh [GameNotifier].
class BalloonGameState {
  /// Ukuran balon 0.05 (kempis) – 1.0 (maks / pop).
  final double balloonSize;

  /// Ketinggian saat ini dalam feet.
  final double altitude;

  /// Kekuatan napas 0–100%.
  final double breathingPower;

  /// Skor akumulasi.
  final int score;

  /// Apakah game sedang aktif (timer berjalan).
  final bool isGameActive;

  /// Apakah balon meledak (over-inflated).
  final bool isBalloonPopped;

  /// Apakah game selesai (pop atau jatuh).
  final bool isGameOver;

  /// Apakah user berhasil menyelesaikan durasi penuh.
  final bool isCompleted;

  /// Apakah game di-pause.
  final bool isPaused;

  /// Detik yang sudah berlalu sejak game dimulai.
  final int timeElapsed;

  /// Durasi total game dalam detik (default 60).
  final int gameDuration;

  /// Apakah GameStat sudah tersimpan ke Supabase.
  final bool isGameSaved;

  /// Durasi hold saat ini (dalam ticks).
  final int holdDurationTicks;

  /// Apakah user sedang menekan (exhale).
  final bool isHolding;

  /// Tick counter untuk animasi float.
  final int tickCounter;

  // ── Microphone Fields ───────────────────────────────────────────

  /// Apakah game menggunakan mikrofon (true) atau tap & hold (false).
  final bool useMicMode;

  /// Apakah mikrofon sedang aktif mendengarkan.
  final bool isListeningMic;

  /// Decibel terakhir dari mikrofon.
  final double microphoneDb;

  /// Riwayat breathing power untuk visualisasi wave.
  /// Max 30 entries, disimpan sebagai list immutable.
  final List<double> powerHistory;

  /// Status permission mikrofon.
  /// - 0 = unknown, 1 = granted, 2 = denied, 3 = permanentlyDenied
  final int micPermissionStatus;

  /// Label kekuatan napas saat ini.
  final String breathLabel;

  const BalloonGameState({
    this.balloonSize = 0.3,
    this.altitude = 0,
    this.breathingPower = 0,
    this.score = 0,
    this.isGameActive = false,
    this.isBalloonPopped = false,
    this.isGameOver = false,
    this.isCompleted = false,
    this.isPaused = false,
    this.timeElapsed = 0,
    this.gameDuration = 60,
    this.isGameSaved = false,
    this.holdDurationTicks = 0,
    this.isHolding = false,
    this.tickCounter = 0,
    this.useMicMode = false,
    this.isListeningMic = false,
    this.microphoneDb = double.negativeInfinity,
    this.powerHistory = const [],
    this.micPermissionStatus = 0,
    this.breathLabel = '',
  });

  BalloonGameState copyWith({
    double? balloonSize,
    double? altitude,
    double? breathingPower,
    int? score,
    bool? isGameActive,
    bool? isBalloonPopped,
    bool? isGameOver,
    bool? isCompleted,
    bool? isPaused,
    int? timeElapsed,
    int? gameDuration,
    bool? isGameSaved,
    int? holdDurationTicks,
    bool? isHolding,
    int? tickCounter,
    bool? useMicMode,
    bool? isListeningMic,
    double? microphoneDb,
    List<double>? powerHistory,
    int? micPermissionStatus,
    String? breathLabel,
  }) {
    return BalloonGameState(
      balloonSize: balloonSize ?? this.balloonSize,
      altitude: altitude ?? this.altitude,
      breathingPower: breathingPower ?? this.breathingPower,
      score: score ?? this.score,
      isGameActive: isGameActive ?? this.isGameActive,
      isBalloonPopped: isBalloonPopped ?? this.isBalloonPopped,
      isGameOver: isGameOver ?? this.isGameOver,
      isCompleted: isCompleted ?? this.isCompleted,
      isPaused: isPaused ?? this.isPaused,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      gameDuration: gameDuration ?? this.gameDuration,
      isGameSaved: isGameSaved ?? this.isGameSaved,
      holdDurationTicks: holdDurationTicks ?? this.holdDurationTicks,
      isHolding: isHolding ?? this.isHolding,
      tickCounter: tickCounter ?? this.tickCounter,
      useMicMode: useMicMode ?? this.useMicMode,
      isListeningMic: isListeningMic ?? this.isListeningMic,
      microphoneDb: microphoneDb ?? this.microphoneDb,
      powerHistory: powerHistory != null ? List<double>.of(powerHistory) : this.powerHistory,
      micPermissionStatus: micPermissionStatus ?? this.micPermissionStatus,
      breathLabel: breathLabel ?? this.breathLabel,
    );
  }

  /// Sisa waktu dalam detik.
  int get remainingTime => gameDuration - timeElapsed;

  /// Waktu yang sudah berlalu dalam format mm:ss.
  String get formattedTimeElapsed {
    final minutes = timeElapsed ~/ 60;
    final seconds = timeElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Sisa waktu dalam format mm:ss.
  String get formattedRemainingTime {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
