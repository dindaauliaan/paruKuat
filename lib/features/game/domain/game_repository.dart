import 'breath_session_stat.dart';
import 'game_stat.dart';

/// Abstract interface untuk game data layer.
///
/// Implementasi konkret: [SupabaseGameRepository].
abstract class GameRepository {
  /// Simpan GameStat setelah game selesai.
  Future<void> saveGameStat({
    required int userId,
    required int currentAltitude,
    required double breathingPower,
  });

  /// Simpan BreathSessionStat untuk tracking konsistensi napas.
  Future<void> saveBreathSessionStat({
    required int userId,
    required BreathSessionStat stat,
  });

  /// Ambil GameStat terakhir user (untuk resume / display).
  Future<GameStat?> getLastGameStat(int userId);

  /// Ambil rata-rata breathing power dari sesi terakhir (untuk progress).
  Future<double?> getAverageBreathingPower(int userId);
}
