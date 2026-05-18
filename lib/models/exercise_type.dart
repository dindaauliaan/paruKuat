class ExerciseType {
  final int id;
  final String name;
  final String? description;
  final String? recommendationText;
  final int durationSeconds;

  ExerciseType({
    required this.id,
    required this.name,
    this.description,
    this.recommendationText,
    required this.durationSeconds,
  });

  factory ExerciseType.fromJson(Map<String, dynamic> json) {
    return ExerciseType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      recommendationText: json['recommendation_text'],
      durationSeconds: json['duration_seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'recommendation_text': recommendationText,
      'duration_seconds': durationSeconds,
    };
  }
}
