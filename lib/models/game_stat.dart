class GameStat {
  final int id;
  final int userId;
  final int? currentAltitude;
  final double? breathingPower;
  final DateTime? lastPlayedAt;

  GameStat({
    required this.id,
    required this.userId,
    this.currentAltitude,
    this.breathingPower,
    this.lastPlayedAt,
  });

  factory GameStat.fromJson(Map<String, dynamic> json) {
    return GameStat(
      id: json['id'],
      userId: json['user_id'],
      currentAltitude: json['current_altitude'],
      breathingPower: json['breathing_power'] != null ? (json['breathing_power'] as num).toDouble() : null,
      lastPlayedAt: json['last_played_at'] != null ? DateTime.parse(json['last_played_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'current_altitude': currentAltitude,
      'breathing_power': breathingPower,
      'last_played_at': lastPlayedAt?.toIso8601String(),
    };
  }
}
