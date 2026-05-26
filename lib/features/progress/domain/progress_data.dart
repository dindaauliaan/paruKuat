/// Ringkasan data progress untuk ditampilkan di halaman Progress.
///
/// Mencakup statistik sesi, tren harian, dan data gamifikasi
/// (XP, streak, achievements) — semua dihitung dari data existing
/// di `exercise_logs` dan `game_stats`.
class ProgressData {
  // ── Statistik Sesi ─────────────────────────────────────────────
  final int totalBreathingSessions;
  final int totalGameSessions;
  final int totalSessions;

  // ── Rata-rata Metrik ───────────────────────────────────────────
  final double averageVitalCapacity;
  final double averageOxygenLevel;
  final double averageBreathingPower;
  final int highestAltitude;

  // ── Tren ───────────────────────────────────────────────────────
  final List<DailyTrend> weeklyTrend;
  final List<DailyTrend> monthlyTrend;

  // ── Gamifikasi ─────────────────────────────────────────────────
  final int currentStreak;
  final int longestStreak;
  final int totalXP;
  final int currentLevel;
  final int xpForNextLevel;
  final List<Achievement> achievements;

  const ProgressData({
    required this.totalBreathingSessions,
    required this.totalGameSessions,
    required this.totalSessions,
    required this.averageVitalCapacity,
    required this.averageOxygenLevel,
    required this.averageBreathingPower,
    required this.highestAltitude,
    required this.weeklyTrend,
    required this.monthlyTrend,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXP,
    required this.currentLevel,
    required this.xpForNextLevel,
    required this.achievements,
  });
}

/// Satu titik data untuk chart tren harian.
class DailyTrend {
  /// Label: "MIN", "SEN", "SEL", ...
  final String label;

  /// Rata-rata vital capacity hari itu
  final double vitalCapacity;

  /// Rata-rata oxygen level hari itu
  final double oxygenLevel;

  /// Jumlah sesi hari itu (breathing + game)
  final int sessionCount;

  /// Apakah ini hari ini
  final bool isToday;

  /// Nilai ternormalisasi 0.0–1.0 untuk tinggi bar
  final double normalizedVC;
  final double normalizedO2;

  const DailyTrend({
    required this.label,
    required this.vitalCapacity,
    required this.oxygenLevel,
    required this.sessionCount,
    required this.isToday,
    required this.normalizedVC,
    required this.normalizedO2,
  });
}

/// Sebuah pencapaian yang bisa di-unlock user.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.isUnlocked,
    this.unlockedAt,
  });
}

/// Level thresholds — XP kumulatif yang dibutuhkan per level.
const Map<int, int> levelThresholds = {
  1: 0,
  2: 100,
  3: 250,
  4: 500,
  5: 800,
  6: 1200,
  7: 1700,
  8: 2300,
  9: 3000,
  10: 4000,
};

// ── Achievement Definitions ────────────────────────────────────────
const List<AchievementDef> achievementDefs = [
  AchievementDef(
    id: 'first_breathing',
    title: 'Napas Pertama',
    description: 'Selesaikan sesi latihan pernapasan pertama',
    emoji: '🌬️',
  ),
  AchievementDef(
    id: 'first_game',
    title: 'Balon Terbang',
    description: 'Selesaikan permainan balon pertama',
    emoji: '🎈',
  ),
  AchievementDef(
    id: 'streak_3',
    title: '3 Hari Berturut',
    description: 'Latihan 3 hari berturut-turut',
    emoji: '🔥',
  ),
  AchievementDef(
    id: 'streak_7',
    title: 'Seminggu Kuat',
    description: 'Latihan 7 hari berturut-turut',
    emoji: '💪',
  ),
  AchievementDef(
    id: 'total_10',
    title: 'Konsisten',
    description: 'Total 10 sesi latihan',
    emoji: '⭐',
  ),
];

class AchievementDef {
  final String id;
  final String title;
  final String description;
  final String emoji;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });
}
