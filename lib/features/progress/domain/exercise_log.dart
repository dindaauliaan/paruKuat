/// Domain entity untuk log latihan pernapasan.
///
/// Data berasal dari tabel `exercise_logs` di Supabase.
class ExerciseLog {
  final int id;
  final int userId;
  final int exerciseTypeId;
  final double? vitalCapacityValue;
  final double? oxygenLevel;
  final double? breathingRate;
  final DateTime? completedAt;

  const ExerciseLog({
    required this.id,
    required this.userId,
    required this.exerciseTypeId,
    this.vitalCapacityValue,
    this.oxygenLevel,
    this.breathingRate,
    this.completedAt,
  });
}
