import 'notification_item.dart';

/// Abstract interface untuk data notifikasi.
///
/// Implementasi konkret: [SupabaseNotificationRepository].
abstract interface class NotificationRepository {
  /// Ambil daftar notifikasi untuk user tertentu, diurutkan dari terbaru.
  Future<List<NotificationItem>> getNotifications(int userId);

  /// Tandai satu notifikasi sebagai sudah dibaca.
  Future<void> markAsRead(int notificationId);

  /// Tandai semua notifikasi user sebagai sudah dibaca.
  Future<void> markAllAsRead(int userId);
}
