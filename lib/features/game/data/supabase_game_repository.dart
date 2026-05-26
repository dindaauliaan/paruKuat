import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/breath_session_stat.dart';
import '../domain/game_repository.dart';
import '../domain/game_stat.dart';

/// Implementasi [GameRepository] dengan Supabase Flutter SDK.
class SupabaseGameRepository implements GameRepository {
  final SupabaseClient client;

  SupabaseGameRepository({required this.client});

  @override
  Future<void> saveGameStat({
    required int userId,
    required int currentAltitude,
    required double breathingPower,
  }) async {
    await client.from('game_stats').insert({
      'user_id': userId,
      'current_altitude': currentAltitude,
      'breathing_power': breathingPower,
      'last_played_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> saveBreathSessionStat({
    required int userId,
    required BreathSessionStat stat,
  }) async {
    // Simpan ke tabel breath_sessions — akan dibuat jika diperlukan
    // atau simpan sebagai bagian dari game_stats
    await client.from('game_stats').update({
      'avg_breath_power': stat.averageBreathPower,
      'peak_breath_power': stat.peakBreathPower,
      'stable_breath_sec': stat.stableBreathDurationSec,
      'total_exhale_count': stat.totalExhaleCount,
      'used_microphone': stat.usedMicrophone,
    }).eq('user_id', userId).order('last_played_at', ascending: false).limit(1);
  }

  @override
  Future<GameStat?> getLastGameStat(int userId) async {
    final response = await client
        .from('game_stats')
        .select()
        .eq('user_id', userId)
        .order('last_played_at', ascending: false)
        .limit(1);

    if (response.isEmpty) return null;
    return _gameStatFromJson(response.first);
  }

  @override
  Future<double?> getAverageBreathingPower(int userId) async {
    final response = await client
        .from('game_stats')
        .select('avg_breath_power')
        .eq('user_id', userId)
        .order('last_played_at', ascending: false)
        .limit(5);

    if (response.isEmpty) return null;
    final values = response
        .map((r) => (r['avg_breath_power'] as num?)?.toDouble())
        .where((v) => v != null)
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a! + b!)! / values.length;
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
