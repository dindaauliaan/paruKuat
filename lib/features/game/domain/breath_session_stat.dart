/// Statistik sesi napas dari game balon.
///
/// Data ini dikumpulkan oleh [BreathDetectorService] selama sesi game
/// dan bisa dipakai untuk:
/// - progress chart
/// - breathing consistency
/// - adaptive difficulty
/// - XP bonus untuk napas stabil
class BreathSessionStat {
  /// Rata-rata kekuatan napas selama sesi.
  final double averageBreathPower;

  /// Kekuatan napas puncak.
  final double peakBreathPower;

  /// Durasi napas stabil (power antara 30-70%) dalam detik.
  final int stableBreathDurationSec;

  /// Jumlah total hembusan napas.
  final int totalExhaleCount;

  /// Apakah sesi menggunakan mikrofon atau tap & hold.
  final bool usedMicrophone;

  const BreathSessionStat({
    required this.averageBreathPower,
    required this.peakBreathPower,
    required this.stableBreathDurationSec,
    required this.totalExhaleCount,
    required this.usedMicrophone,
  });
}
