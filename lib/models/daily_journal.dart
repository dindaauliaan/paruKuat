class DailyJournal {
  final int id;
  final int userId;
  final String content;
  final String? category;
  final DateTime? createdAt;

  DailyJournal({
    required this.id,
    required this.userId,
    required this.content,
    this.category,
    this.createdAt,
  });

  factory DailyJournal.fromJson(Map<String, dynamic> json) {
    return DailyJournal(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      category: json['category'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
