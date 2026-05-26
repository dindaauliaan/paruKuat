/// Service untuk mendeteksi kekuatan napas via mikrofon secara real-time.
///
/// Menggunakan [NoiseMeter] untuk membaca decibel dari mikrofon,
/// lalu memetakannya ke breathing power (0–100%).
///
/// Tanggung Jawab:
/// - Request permission mikrofon
/// - Mendengarkan amplitude audio realtime
/// - Mengubah amplitude → breathing power (0-100%)
/// - Filter noise kecil agar suara sekitar tidak dianggap hembusan
///
/// Flow:
/// ```
/// Microphone Input → Audio Amplitude (dB) → Noise Filtering
///   → Normalize Value → Breathing Power (0-100%)
/// ```
library;

import 'dart:async';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Status permission mikrofon.
enum MicPermissionStatus {
  /// Belum ditanyakan.
  unknown,

  /// Diizinkan.
  granted,

  /// Ditolak — bisa ditanyakan lagi.
  denied,

  /// Ditolak permanen — harus lewat settings.
  permanentlyDenied,
}

/// Service untuk deteksi napas via mikrofon.
///
/// Gunakan method [startListening] untuk mulai mendengarkan,
/// dan [stopListening] untuk berhenti.
/// Baca [latestBreathPower] untuk mendapatkan kekuatan napas terkini.
class BreathDetectorService {
  final NoiseMeter _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _subscription;

  /// Apakah service sedang mendengarkan mikrofon.
  bool _isListening = false;
  bool get isListening => _isListening;

  /// Kekuatan napas terakhir (0–100%).
  double _latestBreathPower = 0;
  double get latestBreathPower => _latestBreathPower;

  /// Decibel terakhir dari mikrofon.
  double _latestDb = double.negativeInfinity;
  double get latestDb => _latestDb;

  /// Kekuatan napas puncak selama sesi.
  double _peakBreathPower = 0;
  double get peakBreathPower => _peakBreathPower;

  /// Total durasi napas stabil (power antara 30-70%) dalam milidetik.
  int _stableBreathDurationMs = 0;
  int get stableBreathDurationMs => _stableBreathDurationMs;

  /// Jumlah hembusan napas (power naik > 10% lalu turun).
  int _totalExhaleCount = 0;
  int get totalExhaleCount => _totalExhaleCount;

  /// Batas decibel di bawah ini dianggap noise ambient (bukan napas).
  /// Default: 45 dB — sesuaikan jika perlu.
  double _dbThreshold = 45.0;

  /// Decibel maksimum untuk mapping 100% power.
  /// Default: 80 dB.
  double _dbMax = 80.0;

  /// Riwayat breathing power untuk visualisasi wave (max 30 entries).
  final List<double> _powerHistory = [];
  List<double> get powerHistory => List.unmodifiable(_powerHistory);

  /// Status permission saat ini.
  MicPermissionStatus _permissionStatus = MicPermissionStatus.unknown;
  MicPermissionStatus get permissionStatus => _permissionStatus;

  // ── State tracking untuk exhale count ──
  bool _wasBreathing = false;

  /// Request permission mikrofon.
  ///
  /// Returns `true` jika granted, `false` jika tidak.
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    _updatePermissionStatus(status);
    return status.isGranted;
  }

  /// Cek apakah permission sudah granted tanpa meminta ulang.
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    _updatePermissionStatus(status);
    return status.isGranted;
  }

  /// Cek status permission.
  Future<MicPermissionStatus> checkPermissionStatus() async {
    final status = await Permission.microphone.status;
    _updatePermissionStatus(status);
    return _permissionStatus;
  }

  /// Buka settings aplikasi agar user bisa mengaktifkan mic manual.
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Mulai mendengarkan mikrofon.
  ///
  /// Returns `true` jika berhasil, `false` jika permission ditolak.
  Future<bool> startListening() async {
    if (_isListening) return true;

    final hasPerm = await hasPermission();
    if (!hasPerm) {
      final granted = await requestPermission();
      if (!granted) return false;
    }

    try {
      _subscription = _noiseMeter.noise.listen(
        _onNoiseReading,
        onError: _onError,
        onDone: _onDone,
      );
      _isListening = true;
      _peakBreathPower = 0;
      _stableBreathDurationMs = 0;
      _totalExhaleCount = 0;
      _powerHistory.clear();
      _wasBreathing = false;
      return true;
    } catch (e) {
      _isListening = false;
      return false;
    }
  }

  /// Berhenti mendengarkan mikrofon.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _latestBreathPower = 0;
    _latestDb = double.negativeInfinity;
  }

  /// Reset statistik sesi.
  void resetStats() {
    _peakBreathPower = 0;
    _stableBreathDurationMs = 0;
    _totalExhaleCount = 0;
    _powerHistory.clear();
    _wasBreathing = false;
  }

  /// Update threshold decibel (default 45 dB).
  void setDbThreshold(double threshold) {
    _dbThreshold = threshold;
  }

  /// Update max decibel untuk mapping 100% (default 80 dB).
  void setDbMax(double maxDb) {
    _dbMax = maxDb;
  }

  // ── Handler ─────────────────────────────────────────────────────────

  void _onNoiseReading(NoiseReading reading) {
    _latestDb = reading.meanDecibel;
    _latestBreathPower = _mapDbToPower(reading.meanDecibel);

    // Track peak
    if (_latestBreathPower > _peakBreathPower) {
      _peakBreathPower = _latestBreathPower;
    }

    // Track stable breathing (power 30-70%)
    if (_latestBreathPower >= 30 && _latestBreathPower <= 70) {
      // Setiap reading ≈ 100ms, jadi tambah ~100ms
      _stableBreathDurationMs += 100;
    }

    // Track exhale count (power naik > 10% lalu turun < 10%)
    final isBreathing = _latestBreathPower > 10;
    if (isBreathing && !_wasBreathing) {
      // Transisi dari tidak bernapas → bernapas
      _totalExhaleCount++;
    }
    _wasBreathing = isBreathing;

    // Simpan history (max 30 entries)
    _powerHistory.add(_latestBreathPower);
    if (_powerHistory.length > 30) {
      _powerHistory.removeAt(0);
    }
  }

  void _onError(Object error) {
    // Jika error, set power ke 0 dan stop
    _latestBreathPower = 0;
    _isListening = false;
  }

  void _onDone() {
    _isListening = false;
  }

  // ── Mapping ─────────────────────────────────────────────────────────

  /// Mapping decibel ke breathing power (0–100%).
  ///
  /// - Di bawah [_dbThreshold] → 0% (ambient noise, diabaikan)
  /// - [_dbThreshold] – [_dbMax] → 0% – 100% (linear)
  /// - Di atas [_dbMax] → 100%
  double _mapDbToPower(double db) {
    if (db < _dbThreshold) return 0;
    final normalized = ((db - _dbThreshold) / (_dbMax - _dbThreshold))
        .clamp(0.0, 1.0);
    return normalized * 100;
  }

  // ── Status ──────────────────────────────────────────────────────────

  void _updatePermissionStatus(PermissionStatus status) {
    if (status.isGranted) {
      _permissionStatus = MicPermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      _permissionStatus = MicPermissionStatus.permanentlyDenied;
    } else if (status.isDenied) {
      _permissionStatus = MicPermissionStatus.denied;
    } else {
      _permissionStatus = MicPermissionStatus.unknown;
    }
  }

  /// Dapatkan label teks untuk kekuatan napas.
  String getBreathingLabel(double power) {
    if (power <= 0) return 'Tiup lebih kuat';
    if (power < 20) return 'Tiup lebih kuat';
    if (power < 40) return 'Mulai terdeteksi';
    if (power < 60) return 'Bagus!';
    if (power < 80) return 'Mantap! 🔥';
    return '⚠️ Terlalu kuat!';
  }

  /// Dapatkan warna untuk indikator kekuatan napas.
  int getBreathingColorInt(double power) {
    if (power <= 0) return 0xFFBDC9C8; // grey
    if (power < 20) return 0xFFBDC9C8; // grey
    if (power < 40) return 0xFFFEA8A7; // light pink
    if (power < 60) return 0xFFCD2C58; // primary pink
    if (power < 80) return 0xFF006565; // teal
    return 0xFFFF5722; // orange/red — warning
  }

  /// Clean up resources. Panggil saat tidak lagi dibutuhkan.
  void dispose() {
    stopListening();
  }
}
