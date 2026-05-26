import 'package:supabase_flutter/supabase_flutter.dart';

import '../../game/domain/game_stat.dart';
import '../domain/exercise_log.dart';
import '../domain/progress_data.dart';
import '../domain/progress_repository.dart';

/// Implementasi [ProgressRepository] dengan Supabase Flutter SDK.
class SupabaseProgressRepository implements ProgressRepository {
  final SupabaseClient _client;

  SupabaseProgressRepository({required SupabaseClient client}) : _client = client;

  @override
  Future<ProgressData> getProgressData(int userId) async {
    // Fetch exercise_logs
    final breathingLogs = await _client
        .from('exercise_logs')
        .select('id, user_id, exercise_type_id, vital_capacity_value, oxygen_level, breathing_rate, completed_at')
        .eq('user_id', userId)
        .order('completed_at', ascending: false);

    final parsedBreathing = breathingLogs
        .map((json) => _exerciseLogFromJson(json))
        .toList();

    // Fetch game_stats
    final gameLogs = await _client
        .from('game_stats')
        .select('id, user_id, current_altitude, breathing_power, last_played_at')
        .eq('user_id', userId)
        .order('last_played_at', ascending: false);

    final parsedGames = gameLogs
        .map((json) => _gameStatFromJson(json))
        .toList();

    // Stats
    final totalBreathing = parsedBreathing.length;
    final totalGames = parsedGames.length;
    final totalSessions = totalBreathing + totalGames;

    final avgVC = _averageOf(parsedBreathing.map((e) => e.vitalCapacityValue).toList());
    final avgO2 = _averageOf(parsedBreathing.map((e) => e.oxygenLevel).toList());
    final avgPower = _averageOf(parsedGames.map((g) => g.breathingPower).toList());
    final highestAlt = parsedGames
        .map((g) => g.currentAltitude ?? 0)
        .fold(0, (int max, int alt) => alt > max ? alt : max);

    // Trend
    final weeklyTrend = _buildDailyTrend(parsedBreathing, parsedGames, days: 7);
    final monthlyTrend = _buildDailyTrend(parsedBreathing, parsedGames, days: 30);

    // Streak
    final streakDates = _collectUniqueDates(parsedBreathing, parsedGames);
    final currentStreak = _calculateCurrentStreak(streakDates);
    final longestStreak = _calculateLongestStreak(streakDates);

    // XP
    final totalXP = _calculateXP(
      totalBreathing: totalBreathing,
      totalGames: totalGames,
      currentStreak: currentStreak,
      logs: parsedBreathing,
      gameLogs: parsedGames,
    );

    final level = _calculateLevel(totalXP);
    final xpForNext = _xpForNextLevel(level, totalXP);

    // Achievements
    final achievements = _checkAchievements(
      totalBreathing: totalBreathing,
      totalGames: totalGames,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalSessions: totalSessions,
    );

    return ProgressData(
      totalBreathingSessions: totalBreathing,
      totalGameSessions: totalGames,
      totalSessions: totalSessions,
      averageVitalCapacity: avgVC,
      averageOxygenLevel: avgO2,
      averageBreathingPower: avgPower,
      highestAltitude: highestAlt,
      weeklyTrend: weeklyTrend,
      monthlyTrend: monthlyTrend,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalXP: totalXP,
      currentLevel: level,
      xpForNextLevel: xpForNext,
      achievements: achievements,
    );
  }

  double _averageOf(List<double?> values) {
    final valid = values.whereType<double>().toList();
    if (valid.isEmpty) return 0.0;
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  List<DailyTrend> _buildDailyTrend(
    List<ExerciseLog> breathingLogs,
    List<GameStat> gameLogs, {
    required int days,
  }) {
    final today = DateTime.now();
    const dayLabels = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];

    final vcValues = <double>[];
    final o2Values = <double>[];
    final sessionCounts = <int>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day - i);

      final dayBreathing = breathingLogs.where((l) =>
          l.completedAt != null &&
          l.completedAt!.year == date.year &&
          l.completedAt!.month == date.month &&
          l.completedAt!.day == date.day).toList();

      final dayGames = gameLogs.where((g) =>
          g.lastPlayedAt != null &&
          g.lastPlayedAt!.year == date.year &&
          g.lastPlayedAt!.month == date.month &&
          g.lastPlayedAt!.day == date.day).toList();

      final vcList = dayBreathing
          .where((l) => l.vitalCapacityValue != null)
          .map((l) => l.vitalCapacityValue!)
          .toList();
      final o2List = dayBreathing
          .where((l) => l.oxygenLevel != null)
          .map((l) => l.oxygenLevel!)
          .toList();

      vcValues.add(vcList.isEmpty ? 0.0 : vcList.reduce((a, b) => a + b) / vcList.length);
      o2Values.add(o2List.isEmpty ? 0.0 : o2List.reduce((a, b) => a + b) / o2List.length);
      sessionCounts.add(dayBreathing.length + dayGames.length);
    }

    final maxVC = vcValues.reduce((a, b) => a > b ? a : b);
    final maxO2 = o2Values.reduce((a, b) => a > b ? a : b);

    return List.generate(days, (i) {
      final date = DateTime(today.year, today.month, today.day - (days - 1 - i));
      return DailyTrend(
        label: dayLabels[date.weekday % 7],
        vitalCapacity: vcValues[i],
        oxygenLevel: o2Values[i],
        sessionCount: sessionCounts[i],
        isToday: i == days - 1,
        normalizedVC: maxVC > 0 ? (vcValues[i] / maxVC).clamp(0.05, 1.0) : 0.05,
        normalizedO2: maxO2 > 0 ? (o2Values[i] / maxO2).clamp(0.05, 1.0) : 0.05,
      );
    });
  }

  List<DateTime> _collectUniqueDates(
    List<ExerciseLog> breathingLogs,
    List<GameStat> gameLogs,
  ) {
    final dates = <DateTime>{};
    for (final log in breathingLogs) {
      if (log.completedAt != null) {
        dates.add(DateTime(log.completedAt!.year, log.completedAt!.month, log.completedAt!.day));
      }
    }
    for (final game in gameLogs) {
      if (game.lastPlayedAt != null) {
        dates.add(DateTime(game.lastPlayedAt!.year, game.lastPlayedAt!.month, game.lastPlayedAt!.day));
      }
    }
    return dates.toList()..sort((a, b) => b.compareTo(a));
  }

  int _calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (dates.first != todayDate && dates.first != todayDate.subtract(const Duration(days: 1))) return 0;

    int streak = 1;
    DateTime expected = dates.first.subtract(const Duration(days: 1));
    for (int i = 1; i < dates.length; i++) {
      if (dates[i] == expected) { streak++; expected = dates[i].subtract(const Duration(days: 1)); }
      else { break; }
    }
    return streak;
  }

  int _calculateLongestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    int longest = 1, current = 1;
    final sorted = dates.reversed.toList();
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) { current++; longest = current > longest ? current : longest; }
      else { current = 1; }
    }
    return longest;
  }

  int _calculateXP({
    required int totalBreathing,
    required int totalGames,
    required int currentStreak,
    required List<ExerciseLog> logs,
    required List<GameStat> gameLogs,
  }) {
    int xp = 0;
    xp += totalBreathing * 10; // +10 per sesi breathing
    xp += totalGames * 15;     // +15 per sesi game
    final uniqueDays = _collectUniqueDates(logs, gameLogs).length;
    xp += uniqueDays * 5;      // +5 per hari aktif
    if (currentStreak >= 3) xp += 20;
    if (currentStreak >= 7) xp += 50;
    return xp;
  }

  int _calculateLevel(int totalXP) {
    for (int l = 10; l >= 1; l--) {
      if (totalXP >= (levelThresholds[l] ?? 0)) return l;
    }
    return 1;
  }

  int _xpForNextLevel(int currentLevel, int totalXP) {
    final nextThreshold = levelThresholds[currentLevel + 1];
    if (nextThreshold == null) return 0;
    return nextThreshold - totalXP;
  }

  List<Achievement> _checkAchievements({
    required int totalBreathing,
    required int totalGames,
    required int currentStreak,
    required int longestStreak,
    required int totalSessions,
  }) {
    return achievementDefs.map((def) {
      final unlocked = _isAchievementUnlocked(def.id,
          totalBreathing: totalBreathing, totalGames: totalGames,
          currentStreak: currentStreak, longestStreak: longestStreak, totalSessions: totalSessions);
      return Achievement(id: def.id, title: def.title, description: def.description, emoji: def.emoji, isUnlocked: unlocked);
    }).toList();
  }

  bool _isAchievementUnlocked(String id, {required int totalBreathing, required int totalGames, required int currentStreak, required int longestStreak, required int totalSessions}) {
    switch (id) {
      case 'first_breathing': return totalBreathing >= 1;
      case 'first_game': return totalGames >= 1;
      case 'streak_3': return longestStreak >= 3;
      case 'streak_7': return longestStreak >= 7;
      case 'total_10': return totalSessions >= 10;
      default: return false;
    }
  }

  /// Mapping data Supabase ke domain [ExerciseLog].
  static ExerciseLog _exerciseLogFromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      exerciseTypeId: json['exercise_type_id'] as int,
      vitalCapacityValue: json['vital_capacity_value'] != null
          ? (json['vital_capacity_value'] as num).toDouble()
          : null,
      oxygenLevel: json['oxygen_level'] != null
          ? (json['oxygen_level'] as num).toDouble()
          : null,
      breathingRate: json['breathing_rate'] != null
          ? (json['breathing_rate'] as num).toDouble()
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  /// Mapping data Supabase ke domain [GameStat].
  static GameStat _gameStatFromJson(Map<String, dynamic> json) {
    return GameStat(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      currentAltitude: json['current_altitude'] as int?,
      breathingPower: json['breathing_power'] != null
          ? (json['breathing_power'] as num).toDouble()
          : null,
      lastPlayedAt: json['last_played_at'] != null
          ? DateTime.parse(json['last_played_at'] as String)
          : null,
    );
  }
}
