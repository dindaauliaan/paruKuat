import 'package:flutter_test/flutter_test.dart';
import 'package:paru_kuat/features/notification/domain/notification_item.dart';

void main() {
  group('NotificationItem', () {
    final baseNotif = NotificationItem(
      id: 1,
      userId: 42,
      title: 'Latihan Selesai',
      message: 'Bagus! Latihanmu selesai.',
      isRead: false,
      sentAt: DateTime(2026, 5, 19, 10, 0, 0),
    );

    group('formattedTime', () {
      test('Baru saja — kurang dari 1 menit', () {
        final now = DateTime.now();
        final notif = baseNotif.copyWith(
          sentAt: now.subtract(const Duration(seconds: 30)),
        );
        expect(notif.formattedTime, 'Baru saja');
      });

      test('Xm yang lalu — kurang dari 1 jam', () {
        final now = DateTime.now();
        final notif = baseNotif.copyWith(
          sentAt: now.subtract(const Duration(minutes: 5)),
        );
        expect(notif.formattedTime, '5m yang lalu');
      });

      test('1m yang lalu — tepat 1 menit', () {
        final now = DateTime.now();
        final notif = baseNotif.copyWith(
          sentAt: now.subtract(const Duration(minutes: 1)),
        );
        expect(notif.formattedTime, '1m yang lalu');
      });

      test('Xj yang lalu — kurang dari 24 jam', () {
        final now = DateTime.now();
        final notif = baseNotif.copyWith(
          sentAt: now.subtract(const Duration(hours: 3)),
        );
        expect(notif.formattedTime, '3j yang lalu');
      });

      test('Kemarin HH:MM — lebih dari 24 jam', () {
        final now = DateTime.now();
        // 26 jam yang lalu → pasti kemarin
        final yesterday = now.subtract(const Duration(hours: 26));
        final hour = yesterday.hour.toString().padLeft(2, '0');
        final minute = yesterday.minute.toString().padLeft(2, '0');
        final notif = baseNotif.copyWith(sentAt: yesterday);
        expect(notif.formattedTime, 'Kemarin $hour:$minute');
      });

      test('X hari yang lalu — 3 hari', () {
        final now = DateTime.now();
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        final notif = baseNotif.copyWith(sentAt: threeDaysAgo);
        expect(notif.formattedTime, '3 hari yang lalu');
      });

      test('X hari yang lalu — 6 hari', () {
        final now = DateTime.now();
        final sixDaysAgo = now.subtract(const Duration(days: 6));
        final notif = baseNotif.copyWith(sentAt: sixDaysAgo);
        expect(notif.formattedTime, '6 hari yang lalu');
      });

      test('tanggal — lebih dari seminggu', () {
        final sentAt = DateTime(2026, 5, 10, 9, 15);
        final notif = baseNotif.copyWith(sentAt: sentAt);
        // Asumsi sekarang setelah 17 Mei, jadi lebih dari seminggu
        expect(notif.formattedTime, '10 Mei 09:15');
      });
    });

    group('copyWith', () {
      test('mengubah isRead', () {
        final notif = baseNotif.copyWith(
          sentAt: DateTime(2026, 5, 19),
          isRead: true,
        );
        expect(notif.isRead, true);
        expect(notif.title, 'Latihan Selesai');
      });

      test('tanpa parameter → sama', () {
        final notif = baseNotif.copyWith(
          sentAt: DateTime(2026, 5, 19),
        );
        final copied = notif.copyWith();
        expect(copied.id, notif.id);
        expect(copied.userId, notif.userId);
        expect(copied.title, notif.title);
        expect(copied.message, notif.message);
        expect(copied.isRead, notif.isRead);
        expect(copied.sentAt, notif.sentAt);
      });
    });
  });
}
