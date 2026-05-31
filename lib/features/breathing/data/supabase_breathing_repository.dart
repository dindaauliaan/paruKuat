import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/breathing_repository.dart';
import '../domain/exercise_type.dart';

/// Implementasi [BreathingRepository] dengan Supabase Flutter SDK.
class SupabaseBreathingRepository implements BreathingRepository {
  final SupabaseClient _client;

  SupabaseBreathingRepository({required SupabaseClient client})
      : _client = client;

  @override
  Future<List<ExerciseType>> getExerciseTypes() async {
    try {
      final data = await _client
          .from('exercise_types')
          .select('id, name, description, recommendation_text, duration_seconds')
          .order('id', ascending: true);

      // Jika tabel kosong, seed dengan data default
      if (data.isEmpty) {
        await _seedExerciseTypes();
        return _defaultExerciseTypes();
      }

      return data.map((json) => _exerciseTypeFromJson(json)).toList();
    } catch (_) {
      // Fallback hardcoded jika query gagal
      return _defaultExerciseTypes();
    }
  }

  /// Seed tabel `exercise_types` dengan data default jika kosong.
  Future<void> _seedExerciseTypes() async {
    final defaults = _defaultExerciseTypes();
    for (final type in defaults) {
      await _client.from('exercise_types').upsert(
        {
          'id': type.id,
          'name': type.name,
          'description': type.description,
          'recommendation_text': type.recommendationText,
          'duration_seconds': type.durationSeconds,
        },
        onConflict: 'id',
      );
    }
    debugPrint('✅ exercise_types table seeded with ${defaults.length} entries');
  }

  @override
  Future<void> saveExerciseLog({
    required int userId,
    required int exerciseTypeId,
    double? vitalCapacityValue,
    double? oxygenLevel,
    double? breathingRate,
  }) async {
    // Pastikan exercise_type_id valid dengan upsert terlebih dulu
    await _ensureExerciseTypeExists(exerciseTypeId);

    await _client.from('exercise_logs').insert({
      'user_id': userId,
      'exercise_type_id': exerciseTypeId,
      'vital_capacity_value': vitalCapacityValue,
      'oxygen_level': oxygenLevel,
      'breathing_rate': breathingRate,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Pastikan row dengan [exerciseTypeId] ada di tabel `exercise_types`.
  /// Jika belum ada, insert data default agar FK constraint tidak gagal.
  Future<void> _ensureExerciseTypeExists(int exerciseTypeId) async {
    final existing = await _client
        .from('exercise_types')
        .select('id')
        .eq('id', exerciseTypeId)
        .maybeSingle();

    if (existing != null) return; // sudah ada

    // Cari dari default list
    final defaults = _defaultExerciseTypes();
    final match = defaults.where((t) => t.id == exerciseTypeId);
    if (match.isNotEmpty) {
      final type = match.first;
      await _client.from('exercise_types').upsert(
        {
          'id': type.id,
          'name': type.name,
          'description': type.description,
          'recommendation_text': type.recommendationText,
          'duration_seconds': type.durationSeconds,
        },
        onConflict: 'id',
      );
      debugPrint('✅ exercise_type id=$exerciseTypeId inserted on-the-fly');
    }
  }

  /// Data default exercise types (hardcoded fallback).
  List<ExerciseType> _defaultExerciseTypes() {
    return [
      ExerciseType(
        id: 1,
        name: 'Deep Lung Recovery',
        description:
            'Latihan pernapasan dalam untuk memulihkan kapasitas paru secara bertahap.',
        recommendationText:
            'Cocok dilakukan setiap pagi untuk meningkatkan efisiensi oksigen.',
        durationSeconds: 112, // 8 cycles × 14s
      ),
      ExerciseType(
        id: 2,
        name: 'Pursed Lip Breathing',
        description:
            'Teknik pernapasan dengan bibir mengerucut untuk mengontrol napas.',
        recommendationText:
            'Membantu mengurangi sesak napas saat aktivitas ringan.',
        durationSeconds: 112,
      ),
      ExerciseType(
        id: 3,
        name: 'Diaphragmatic Breathing',
        description:
            'Latihan pernapasan perut untuk memperkuat diafragma.',
        recommendationText:
            'Baik dilakukan sebelum tidur untuk relaksasi maksimal.',
        durationSeconds: 168, // 12 cycles × 14s
      ),
    ];
  }

  /// Simulasi nilai vital capacity (2.5–4.0 L) berdasarkan sesi.
  ///
  /// Nilai ini adalah estimasi latihan, BUKAN alat diagnosis medis.
  static double simulateVitalCapacity(int totalCycles) {
    final rng = Random();
    return 2.5 + (rng.nextDouble() * 1.5);
  }

  /// Simulasi oxygen level (94–99%) berdasarkan sesi.
  static double simulateOxygenLevel() {
    final rng = Random();
    return 94 + (rng.nextDouble() * 5);
  }

  /// Hitung breathing rate (BPM) dari total cycles & durasi.
  ///
  /// Setiap cycle = 1 napas, total napas = totalCycles.
  /// Durasi total = totalCycles × 14 detik.
  /// BPM = (total napas / durasi menit).
  static double calculateBreathingRate(int totalCycles, int totalSeconds) {
    if (totalSeconds <= 0) return 0;
    final minutes = totalSeconds / 60;
    return (totalCycles / minutes);
  }

  /// Mapping data Supabase ke domain [ExerciseType].
  static ExerciseType _exerciseTypeFromJson(Map<String, dynamic> json) {
    return ExerciseType(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      recommendationText: json['recommendation_text'] as String?,
      durationSeconds: json['duration_seconds'] as int,
    );
  }
}
