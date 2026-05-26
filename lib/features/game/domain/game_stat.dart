/// Domain entity untuk statistik game balon.
///
/// Data berasal dari tabel `game_stats` di Supabase.
class GameStat {
  final int id;
  final int userId;
  final int? currentAltitude;
  final double? breathingPower;
  final DateTime? lastPlayedAt;

  const GameStat({
    required this.id,
    required this.userId,
    this.currentAltitude,
    this.breathingPower,
    this.lastPlayedAt,
  });
}
