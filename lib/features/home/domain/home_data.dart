/// Entity untuk semua data yang ditampilkan di Home Dashboard.
///
/// Dibangun oleh [HomeRepository.getHomeData] berdasarkan query ke
/// `users`, `exercise_logs`, dan kalkulasi streak.
class HomeData {
  /// Nama lengkap user (dari `users.full_name`)
  final String userName;

  /// URL foto profil (dari `users.profile_picture`)
  final String? profilePictureUrl;

  // ── Rekomendasi ─────────────────────────────────────────────────
  final String recommendationTitle;
  final String recommendationDescription;

  // ── Metrik ──────────────────────────────────────────────────────
  final double? latestVitalCapacity;
  final double? latestOxygenLevel;

  /// Teks delta seperti "+2% vs Kemarin"
  final String vitalCapacityDelta;

  /// Teks status oksigen: "Optimal" / "Normal" / "Perlu perhatian"
  final String oxygenStatus;

  // ── Statistik ───────────────────────────────────────────────────
  final int totalSessions;
  final int currentStreak;

  /// Data 7 hari terakhir untuk bar chart
  final List<TrendDataPoint> weeklyTrend;

  const HomeData({
    required this.userName,
    this.profilePictureUrl,
    required this.recommendationTitle,
    required this.recommendationDescription,
    this.latestVitalCapacity,
    this.latestOxygenLevel,
    required this.vitalCapacityDelta,
    required this.oxygenStatus,
    required this.totalSessions,
    required this.currentStreak,
    required this.weeklyTrend,
  });
}

/// Satu titik data untuk bar chart tren pernapasan 7 hari.
class TrendDataPoint {
  /// Label hari: "SEN", "SEL", "RAB", ...
  final String dayLabel;

  /// Nilai sudah dinormalisasi 0.0 – 1.0 untuk tinggi bar.
  /// Berdasarkan rata-rata vital_capacity_value per hari.
  final double normalizedValue;

  /// Nilai asli (liter) untuk ditampilkan di tooltip / label
  final double actualValue;

  /// Apakah ini hari ini (bar aktif dengan border)
  final bool isToday;

  const TrendDataPoint({
    required this.dayLabel,
    required this.normalizedValue,
    required this.actualValue,
    required this.isToday,
  });
}
