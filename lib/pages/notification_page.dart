import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class NotificationParukuat extends StatefulWidget {
  const NotificationParukuat({super.key});

  @override
  State<NotificationParukuat> createState() => _NotificationParukuatState();
}

class _NotificationParukuatState extends State<NotificationParukuat> {
  // Daftar notifikasi dengan status read/unread
  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      icon: Icons.notifications_active,
      iconColor: const Color(0xFFCD2C58),
      title: 'Jangan lupa berlatih hari ini!',
      time: 'Today 07:00',
      isRead: false,
    ),
    _NotificationItem(
      icon: Icons.trending_up,
      iconColor: const Color(0xFF4CAF50),
      title: 'Kapasitas vital Anda meningkat 2%!',
      time: 'Yesterday 18:30',
      isRead: false,
    ),
    _NotificationItem(
      icon: Icons.emoji_events,
      iconColor: const Color(0xFFFFA000),
      title: 'Selamat! Anda mencapai target latihan 7 hari.',
      time: 'Yesterday 12:15',
      isRead: false,
    ),
    _NotificationItem(
      icon: Icons.spa,
      iconColor: const Color(0xFF9C27B0),
      title: 'Rekomendasi latihan baru tersedia untuk Anda.',
      time: '2 days ago 09:00',
      isRead: true,
    ),
    _NotificationItem(
      icon: Icons.water_drop,
      iconColor: const Color(0xFF2196F3),
      title: 'Pengingat: Minum air putih sebelum latihan.',
      time: '3 days ago 07:00',
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notif in _notifications) {
        notif.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai telah dibaca'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleRead(int index) {
    setState(() {
      _notifications[index].isRead = !_notifications[index].isRead;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFC7C7),
      body: SafeArea(
        child: Column(
          children: [
            // ==== APPBAR ====
            _buildAppBar(unreadCount),

            // ==== NOTIFICATION LIST ====
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(index);
                      },
                    ),
            ),

            // ==== BOTTOM NAV ====
            const BottomNav(currentRoute: '/notifications'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // APPBAR
  // ================================================================
  Widget _buildAppBar(int unreadCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C134E4A),
            blurRadius: 10,
            offset: Offset(0, 8),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: Color(0x0C134E4A),
            blurRadius: 25,
            offset: Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: back + title + app name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Color(0xFFCD2C58),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Notifikasi',
                      style: TextStyle(
                        color: Color(0xFFCD2C58),
                        fontSize: 20,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        height: 1.40,
                        letterSpacing: -0.45,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                spacing: 12,
                children: [
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFCD2C58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const Text(
                    'ParuKuat',
                    style: TextStyle(
                      color: Color(0xFFCD2C58),
                      fontSize: 24,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      height: 1.33,
                      letterSpacing: -1.20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Bottom row: mark all as read (if there are unread)
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _markAllAsRead,
                    child: const Text(
                      'Tandai semua telah dibaca',
                      style: TextStyle(
                        color: Color(0xFF0083FF),
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        height: 2.50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ================================================================
  // NOTIFICATION CARD
  // ================================================================
  Widget _buildNotificationCard(int index) {
    final notif = _notifications[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: notif.isRead
              ? Colors.white.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: notif.isRead
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.50),
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0x0C000000),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => _toggleRead(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: ShapeDecoration(
                    color: notif.isRead
                        ? const Color(0xFFCD2C58)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.5,
                        color: notif.isRead
                            ? const Color(0xFFCD2C58)
                            : const Color(0x66CD2C58),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: notif.isRead
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: ShapeDecoration(
                  color: notif.iconColor.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Icon(
                  notif.icon,
                  color: notif.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Title + time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        color: notif.isRead
                            ? const Color(0xFF8A7474)
                            : Colors.black,
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight:
                            notif.isRead ? FontWeight.w500 : FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.time,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.30),
                        fontSize: 11,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.30,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread dot
              if (!notif.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFCD2C58),
                    shape: OvalBorder(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // EMPTY STATE
  // ================================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: const Color(0xFFCD2C58).withValues(alpha: 0.30),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              color: Color(0xFF8A7474),
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda akan mendapat notifikasi saat ada\naktivitas atau pengingat latihan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB8A0A0),
              fontSize: 14,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// MODEL
// ================================================================
class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  bool isRead;

  _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    this.isRead = false,
  });
}
