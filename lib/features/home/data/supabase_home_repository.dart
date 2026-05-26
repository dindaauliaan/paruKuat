import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/home_data.dart';
import '../domain/home_repository.dart';

/// Implementasi [HomeRepository] dengan Supabase Flutter SDK.
///
/// Strategi query:
/// 1. Fetch `users` untuk nama & profil
/// 2. Fetch `exercise_logs` 8 hari terakhir (cukup untuk trending + streak)
/// 3. Semua kalkulasi (delta, streak, normalisasi) dilakukan di sisi Dart
class SupabaseHomeRepository implements HomeRepository {
  final SupabaseClient _client;

  SupabaseHomeRepository({required SupabaseClient client}) : _client = client;

  @override
  Future<HomeData> getHomeData(int userId) async {
    // ── 1. Ambil data user ────────────────────────────────────────
    final userData = await _client
        .from('users')
        .select('full_name, profile_picture')
        .eq('id', userId)
        .maybeSingle();

    final userName = userData?['full_name'] as String? ?? 'Pengguna';
    final profilePic = userData?['profile_picture'] as String?;

    // ── 2. Ambil exercise_logs 8 hari terakhir ────────────────────
    final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
    final logs = await _client
        .from('exercise_logs')
        .select('completed_at, vital_capacity_value, oxygen_level')
        .eq('user_id', userId)
        .gte('completed_at', eightDaysAgo.toIso8601String())
        .order('completed_at', ascending: false);

    final parsedLogs = logs.map((json) => _ParsedLog(
          completedAt: DateTime.parse(json['completed_at'] as String),
          vitalCapacity: (json['vital_capacity_value'] as num?)?.toDouble(),
          oxygenLevel: (json['oxygen_level'] as num?)?.toDouble(),
        )).toList();

    // ── 3. Latest & second latest ─────────────────────────────────
    final latestLog = parsedLogs.isNotEmpty ? parsedLogs.first : null;
    final secondLatestLog = parsedLogs.length > 1 ? parsedLogs[1] : null;

    // ── 4. Delta vital capacity ───────────────────────────────────
    final vitalDelta = _calculateDelta(latestLog, secondLatestLog);

    // ── 5. Status oksigen ─────────────────────────────────────────
    final oxygenStatus = _calculateOxygenStatus(latestLog?.oxygenLevel);

    // ── 6. Weekly trend (7 hari) ──────────────────────────────────
    final weeklyTrend = _buildWeeklyTrend(parsedLogs);

    // ── 7. Streak ─────────────────────────────────────────────────
    final streak = _calculateStreak(parsedLogs);

    // ── 8. Total sesi (dari data yang ada) ────────────────────────
    final totalSessions = parsedLogs.length;

    return HomeData(
      userName: userName,
      profilePictureUrl: profilePic,
      recommendationTitle: 'Latihan\nKapasitas Vital\nPagi Hari',
      recommendationDescription:
          '5 menit latihan terkontrol untuk\nmeningkatkan efisiensi oksigen Anda.',
      latestVitalCapacity: latestLog?.vitalCapacity,
      latestOxygenLevel: latestLog?.oxygenLevel,
      vitalCapacityDelta: vitalDelta,
      oxygenStatus: oxygenStatus,
      totalSessions: totalSessions,
      currentStreak: streak,
      weeklyTrend: weeklyTrend,
    );
  }

  // ================================================================
  // HELPERS
  // ================================================================

  /// Hitung persentase perubahan vital capacity antara log terakhir
  /// dan log sebelumnya.
  String _calculateDelta(_ParsedLog? latest, _ParsedLog? previous) {
    if (latest?.vitalCapacity == null || previous?.vitalCapacity == null) {
      return 'Belum ada data';
    }
    if (previous!.vitalCapacity! <= 0) return 'Belum ada data';

    final delta = ((latest!.vitalCapacity! - previous.vitalCapacity!) /
            previous.vitalCapacity! *
            100)
        .round();
    return '${delta >= 0 ? '+' : ''}$delta% vs Kemarin';
  }

  /// Tentukan status oksigen berdasarkan SpO2.
  /// - >= 95 → Optimal
  /// - >= 90 → Normal
  /// - < 90  → Perlu perhatian
  String _calculateOxygenStatus(double? oxygenLevel) {
    if (oxygenLevel == null) return 'Belum ada data';
    if (oxygenLevel >= 95) return 'Optimal';
    if (oxygenLevel >= 90) return 'Normal';
    return 'Perlu perhatian';
  }

  /// Bangun list 7 hari terakhir untuk bar chart.
  /// Nilai dinormalisasi 0.0 – 1.0 berdasarkan max value di 7 hari.
  List<TrendDataPoint> _buildWeeklyTrend(List<_ParsedLog> logs) {
    final today = DateTime.now();
    final dailyValues = <double>[];

    // Hitung rata-rata vital capacity per hari
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day - i);
      final dayLogs = logs.where((l) =>
          l.completedAt.year == date.year &&
          l.completedAt.month == date.month &&
          l.completedAt.day == date.day);

      final values =
          dayLogs.where((l) => l.vitalCapacity != null).map((l) => l.vitalCapacity!).toList();

      final avg =
          values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
      dailyValues.add(avg);
    }

    // Normalisasi 0.0 – 1.0
    final maxValue = dailyValues.reduce((a, b) => a > b ? a : b);
    final normalized = maxValue > 0
        ? dailyValues.map((v) => v / maxValue).toList()
        : List.filled(7, 0.05); // fallback kecil jika semua 0

    const dayLabels = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];

    return List.generate(7, (i) {
      final date = DateTime(today.year, today.month, today.day - (6 - i));
      return TrendDataPoint(
        dayLabel: dayLabels[date.weekday % 7],
        normalizedValue: normalized[i],
        actualValue: dailyValues[i],
        isToday: i == 6,
      );
    });
  }

  /// Hitung streak hari berturut-turut user berlatih.
  ///
  /// Logic:
  /// - Ambil unique dates dari logs
  /// - Sort descending
  /// - Hitung consecutive days dari hari ini (boleh include hari ini atau kemarin)
  int _calculateStreak(List<_ParsedLog> logs) {
    if (logs.isEmpty) return 0;

    final dates = logs
        .map((l) =>
            DateTime(l.completedAt.year, l.completedAt.month, l.completedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Streak bisa mulai dari hari ini atau kemarin
    final firstDate = dates.first;
    if (firstDate != todayDate &&
        firstDate != todayDate.subtract(const Duration(days: 1))) {
      return 0;
    }

    int streak = 1;
    DateTime expected = firstDate.subtract(const Duration(days: 1));

    for (int i = 1; i < dates.length; i++) {
      if (dates[i] == expected) {
        streak++;
        expected = dates[i].subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}

/// Data class ringan untuk hasil parse JSON exercise_logs.
/// Tidak perlu model penuh karena kita hanya pakai 3 field.
class _ParsedLog {
  final DateTime completedAt;
  final double? vitalCapacity;
  final double? oxygenLevel;

  _ParsedLog({
    required this.completedAt,
    this.vitalCapacity,
    this.oxygenLevel,
  });
}
