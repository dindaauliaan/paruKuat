/// Domain entity untuk notifikasi.
///
/// Data berasal dari tabel `notifications` di Supabase.
/// Tidak bergantung pada framework atau library eksternal.
class NotificationItem {
  final int id;
  final int userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime sentAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.sentAt,
  });

  /// Buat salinan dengan field tertentu diubah.
  NotificationItem copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    bool? isRead,
    DateTime? sentAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  /// Format waktu relatif user-friendly.
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(sentAt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    if (diff.inDays == 1) return 'Kemarin ${_formatHour(sentAt)}';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

    // Lebih dari seminggu — tampilkan tanggal
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${sentAt.day} ${months[sentAt.month - 1]} ${_formatHour(sentAt)}';
  }

  String _formatHour(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
