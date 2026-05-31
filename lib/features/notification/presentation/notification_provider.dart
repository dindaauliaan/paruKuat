
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/presentation/auth_notifier.dart';
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
    FutureProvider.family<List<NotificationItem>, int>((ref, userId) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final prefs = ref.read(sharedPreferencesProvider);
  
  // Hapus otomatis notifikasi yang usianya lebih dari 24 jam sebelum fetch
  try {
    await repository.deleteOldNotifications(userId, const Duration(hours: 24));
  } catch (_) {
    // Abaikan jika error saat menghapus
  }

  // --- SINKRONISASI PENGINGAT HARIAN ---
  final enabled = prefs.getBool('daily_reminder_enabled') ?? false;
  if (enabled) {
    final hour = prefs.getInt('daily_reminder_hour');
    final minute = prefs.getInt('daily_reminder_minute');
    if (hour != null && minute != null) {
      final now = DateTime.now();
      
      final lastLoggedStr = prefs.getString('last_logged_reminder_$userId');
      DateTime? lastLogged;
      if (lastLoggedStr != null) {
        lastLogged = DateTime.parse(lastLoggedStr);
      }

      // Mulai cek dari hari setelah terakhir dilog, ATAU hari ini jika belum pernah
      DateTime checkDate = lastLogged != null 
          ? lastLogged.add(const Duration(days: 1)) 
          : DateTime(now.year, now.month, now.day);
          
      // Setel jam & menit sesuai setting alarm
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day, hour, minute);

      bool synced = false;
      if (checkDate.isBefore(now) || checkDate.isAtSameMomentAs(now)) {
        while (checkDate.isBefore(now) || checkDate.isAtSameMomentAs(now)) {
          try {
            await repository.addNotification(
              userId,
              'Waktunya Latihan Pernapasan! 🫁',
              'Mari luangkan waktu sejenak untuk melatih paru-paru Anda agar tetap sehat dan kuat.',
              sentAt: checkDate,
            );
            await prefs.setString('last_logged_reminder_$userId', checkDate.toIso8601String());
            synced = true;
          } catch (_) {}
          // Lanjut ke hari berikutnya
          checkDate = checkDate.add(const Duration(days: 1));
        }
      }
      
      if (synced) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
  
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
