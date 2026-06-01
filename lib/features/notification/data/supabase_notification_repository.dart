import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/notification_item.dart';
import '../domain/notification_repository.dart';

/// Implementasi [NotificationRepository] dengan Supabase Flutter SDK.
class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _client;

  SupabaseNotificationRepository({required SupabaseClient client})
      : _client = client;

  @override
  Future<List<NotificationItem>> getNotifications(int userId) async {
    final data = await _client
        .from('notifications')
        .select('id, user_id, title, message, is_read, sent_at')
        .eq('user_id', userId)
        .order('sent_at', ascending: false);

    return data.map((json) => _fromJson(json)).toList();
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead(int userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<void> addNotification(int userId, String title, String message, {DateTime? sentAt}) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'is_read': false,
      'sent_at': (sentAt ?? DateTime.now()).toIso8601String(),
    });
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    await _client.from('notifications').delete().eq('id', notificationId);
  }

  @override
  Future<void> deleteOldNotifications(int userId, Duration olderThan) async {
    final threshold = DateTime.now().subtract(olderThan);
    await _client
        .from('notifications')
        .delete()
        .eq('user_id', userId)
        .lt('sent_at', threshold.toIso8601String());
  }

  // ================================================================
  // HELPER — Map JSON ke domain entity
  // ================================================================
  NotificationItem _fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : DateTime.now(),
    );
  }
}
