class ExerciseLog {
  final int id;
  final int userId;
  final int exerciseTypeId;
  final double? vitalCapacityValue;
  final double? oxygenLevel;
  final double? breathingRate;
  final DateTime? completedAt;

  ExerciseLog({
    required this.id,
    required this.userId,
    required this.exerciseTypeId,
    this.vitalCapacityValue,
    this.oxygenLevel,
    this.breathingRate,
    this.completedAt,
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      id: json['id'],
      userId: json['user_id'],
      exerciseTypeId: json['exercise_type_id'],
      vitalCapacityValue: json['vital_capacity_value'] != null ? (json['vital_capacity_value'] as num).toDouble() : null,
      oxygenLevel: json['oxygen_level'] != null ? (json['oxygen_level'] as num).toDouble() : null,
      breathingRate: json['breathing_rate'] != null ? (json['breathing_rate'] as num).toDouble() : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_type_id': exerciseTypeId,
      'vital_capacity_value': vitalCapacityValue,
      'oxygen_level': oxygenLevel,
      'breathing_rate': breathingRate,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
