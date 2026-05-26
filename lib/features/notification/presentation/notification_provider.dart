import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase_notification_repository.dart';
import '../domain/notification_item.dart';
import '../domain/notification_repository.dart';

// ====================================================================
// PROVIDERS
// ====================================================================

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return SupabaseNotificationRepository(client: Supabase.instance.client);
});

/// FutureProvider.family — fetch notifikasi berdasarkan [userId].
final notificationListProvider =
    FutureProvider.family<List<NotificationItem>, int>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications(userId);
});

/// Provider sinkron — hitung jumlah notifikasi belum dibaca.
///
/// Tergantung [notificationListProvider]. Mengembalikan 0 jika masih loading.
final unreadCountProvider = Provider.family<int, int>((ref, userId) {
  final notifications = ref.watch(notificationListProvider(userId));
  return notifications.when(
    data: (list) => list.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});
