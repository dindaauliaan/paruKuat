/// Domain entity untuk jenis latihan pernapasan.
///
/// Data berasal dari tabel `exercise_types` di Supabase.
class ExerciseType {
  final int id;
  final String name;
  final String? description;
  final String? recommendationText;
  final int durationSeconds;

  const ExerciseType({
    required this.id,
    required this.name,
    this.description,
    this.recommendationText,
    required this.durationSeconds,
  });
}
