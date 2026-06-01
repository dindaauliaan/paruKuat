import 'notification_item.dart';

/// Abstract interface untuk data notifikasi.
///
/// Implementasi konkret: [SupabaseNotificationRepository].
abstract interface class NotificationRepository {
  /// Ambil daftar notifikasi untuk user tertentu, diurutkan dari terbaru.
  Future<List<NotificationItem>> getNotifications(int userId);

  /// Tambah notifikasi ke history (Supabase)
  Future<void> addNotification(int userId, String title, String message, {DateTime? sentAt});

  /// Hapus satu notifikasi.
  Future<void> deleteNotification(int notificationId);

  /// Hapus otomatis notifikasi yang lebih tua dari batas waktu (misal: 24 jam).
  Future<void> deleteOldNotifications(int userId, Duration olderThan);

  /// Tandai satu notifikasi sebagai sudah dibaca.
  Future<void> markAsRead(int notificationId);

  /// Tandai semua notifikasi user sebagai sudah dibaca.
  Future<void> markAllAsRead(int userId);
}
