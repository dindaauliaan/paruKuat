import 'exercise_type.dart';

/// Abstract interface untuk data breathing.
///
/// Implementasi konkret: [SupabaseBreathingRepository].
abstract interface class BreathingRepository {
  /// Ambil daftar jenis latihan pernapasan dari Supabase.
  Future<List<ExerciseType>> getExerciseTypes();

  /// Simpan log latihan ke Supabase setelah sesi selesai.
  Future<void> saveExerciseLog({
    required int userId,
    required int exerciseTypeId,
    double? vitalCapacityValue,
    double? oxygenLevel,
    double? breathingRate,
  });
}
