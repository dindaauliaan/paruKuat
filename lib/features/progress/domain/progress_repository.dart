import 'progress_data.dart';

/// Abstract interface untuk data progress dan gamifikasi.
///
/// Implementasi akan fetch data dari `exercise_logs` dan `game_stats`,
/// lalu menghitung XP, level, streak, dan achievements.
abstract class ProgressRepository {
  /// Ambil ringkasan progress untuk user.
  Future<ProgressData> getProgressData(int userId);
}
