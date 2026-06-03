import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_routes.dart';
import '../../../widgets/bottom_nav.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../domain/notification_item.dart';
import 'notification_provider.dart';

/// Halaman Notifikasi — menampilkan daftar notifikasi real dari Supabase.
///
/// Menggantikan [NotificationParukuat] di `pages/notification_page.dart`.
/// Perubahan utama:
/// - Data dari [notificationListProvider] (bukan hardcoded)
/// - Mark as read / mark all as read via [NotificationRepository]
/// - Pull-to-refresh
/// - Loading & error state
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  /// ID user aktif dari auth state.
  int? _userId;

  /// Set notifikasi yang sedang di-mark-as-read (loading state per item).
  final Set<int> _markingIds = {};

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final userId = authState is AuthAuthenticated ? authState.user.id : null;
    _userId = userId;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ==== APPBAR ====
            _buildAppBar(userId),

            // ==== CONTENT ====
            Expanded(
              child: userId != null
                  ? _buildContent(userId)
                  : const _LoadingIndicator(),
            ),

            // ==== BOTTOM NAV ====
            const BottomNav(currentRoute: '/notifications'),
            const SizedBox(height: AppSizes.bottomNavPadding),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // APPBAR
  // ================================================================
  Widget _buildAppBar(int? userId) {
    final unreadCount = userId != null
        ? ref.watch(unreadCountProvider(userId))
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.appBarHorizontal,
        vertical: AppSizes.appBarVertical,
      ),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ParuKuat', style: AppTextStyles.brandLarge),
          Row(
            spacing: AppSizes.lg,
            children: [
              // Avatar
              Consumer(
                builder: (context, ref, _) {
                  final authState = ref.watch(authNotifierProvider);
                  final profileUrl = authState is AuthAuthenticated
                      ? authState.user.profilePicture
                      : null;
                  return GestureDetector(
                    onTap: () => context.go(AppRoutes.profile),
                    child: _AvatarWidget(profilePictureUrl: profileUrl),
                  );
                },
              ),
              // Notification bell with badge
              GestureDetector(
                onTap: () => context.go(AppRoutes.notifications),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textSecondary,
                      size: AppSizes.iconMd,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const ShapeDecoration(
                            color: AppColors.primary,
                            shape: OvalBorder(),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CONTENT — Data-driven
  // ================================================================
  Widget _buildContent(int userId) {
    final notificationsAsync = ref.watch(notificationListProvider(userId));

    return notificationsAsync.when(
      loading: () => const _LoadingIndicator(),
      error: (error, _) => _ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(notificationListProvider(userId)),
      ),
      data: (notifications) {
        if (notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationListProvider(userId));
              try {
                await ref.read(notificationListProvider(userId).future);
              } catch (_) {}
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: _buildEmptyState(),
              ),
            ),
          );
        }
        return _buildNotificationList(userId, notifications);
      },
    );
  }

  // ================================================================
  // NOTIFICATION LIST
  // ================================================================
  Widget _buildNotificationList(
    int userId,
    List<NotificationItem> notifications,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(notificationListProvider(userId));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return _buildNotificationCard(notif);
        },
      ),
    );
  }

  // ================================================================
  // NOTIFICATION CARD
  // ================================================================
  Widget _buildNotificationCard(NotificationItem notif) {
    final isLoading = _markingIds.contains(notif.id);

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
          shadows: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (!notif.isRead)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: const ShapeDecoration(
                    color: AppColors.primary,
                    shape: OvalBorder(),
                  ),
                )
              else
                const SizedBox(height: 18),
              const SizedBox(width: 16),

              // Icon — pilih ikon berdasarkan kata kunci di title
              Container(
                width: 48,
                height: 48,
                decoration: ShapeDecoration(
                  color: _iconColor(notif).withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Icon(
                  _iconData(notif),
                  color: _iconColor(notif),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Title + message + time
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
                        fontWeight: notif.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                        height: 1.30,
                      ),
                    ),
                    if (notif.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: notif.isRead
                              ? const Color(0xFFB8A0A0)
                              : const Color(0xFF6E7979),
                          fontSize: 12,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                          height: 1.30,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      notif.formattedTime,
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

              // Unread dot & Delete Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: isLoading ? null : () => _deleteNotification(notif),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFB8A0A0),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // ACTIONS — Delete
  // ================================================================

  Future<void> _deleteNotification(NotificationItem notif) async {
    setState(() => _markingIds.add(notif.id)); // Reuse markingIds for loading
    try {
      await ref
          .read(notificationRepositoryProvider)
          .deleteNotification(notif.id);
      if (_userId != null) {
        ref.invalidate(notificationListProvider(_userId!));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi berhasil dihapus'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus notifikasi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _markingIds.remove(notif.id));
    }
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
            color: AppColors.primary.withValues(alpha: 0.30),
          ),
          const SizedBox(height: AppSizes.lg),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              color: Color(0xFF8A7474),
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
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

  // ================================================================
  // HELPER — Ikon & warna berdasarkan konten notifikasi
  // ================================================================
  IconData _iconData(NotificationItem notif) {
    final title = notif.title.toLowerCase();
    final message = notif.message.toLowerCase();
    final combined = '$title $message';

    if (combined.contains('latihan') ||
        combined.contains('berlatih') ||
        combined.contains('napas')) {
      return Icons.spa;
    }
    if (combined.contains('target') ||
        combined.contains('pencapaian') ||
        combined.contains('selamat')) {
      return Icons.emoji_events;
    }
    if (combined.contains('meningkat') ||
        combined.contains('kapasitas') ||
        combined.contains('progres')) {
      return Icons.trending_up;
    }
    if (combined.contains('rekomendasi') || combined.contains('rekomendasi')) {
      return Icons.lightbulb_outline;
    }
    if (combined.contains('air') || combined.contains('minum')) {
      return Icons.water_drop;
    }
    if (combined.contains('pengingat') || combined.contains('reminder')) {
      return Icons.notifications_active;
    }
    return Icons.notifications_outlined;
  }

  Color _iconColor(NotificationItem notif) {
    final title = notif.title.toLowerCase();
    final message = notif.message.toLowerCase();
    final combined = '$title $message';

    if (combined.contains('latihan') ||
        combined.contains('berlatih') ||
        combined.contains('napas')) {
      return const Color(0xFF9C27B0); // Purple
    }
    if (combined.contains('target') ||
        combined.contains('pencapaian') ||
        combined.contains('selamat')) {
      return const Color(0xFFFFA000); // Amber
    }
    if (combined.contains('meningkat') ||
        combined.contains('kapasitas') ||
        combined.contains('progres')) {
      return const Color(0xFF4CAF50); // Green
    }
    if (combined.contains('rekomendasi')) {
      return const Color(0xFF2196F3); // Blue
    }
    if (combined.contains('air') || combined.contains('minum')) {
      return const Color(0xFF2196F3); // Blue
    }
    if (combined.contains('pengingat') || combined.contains('reminder')) {
      return AppColors.primary; // Pink
    }
    return AppColors.primary;
  }
}

// ====================================================================
// LOADING INDICATOR
// ====================================================================
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 3,
      ),
    );
  }
}

// ====================================================================
// ERROR STATE
// ====================================================================
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Gagal memuat notifikasi',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionRegular,
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// AVATAR WIDGET
// ====================================================================
class _AvatarWidget extends StatelessWidget {
  final String? profilePictureUrl;

  const _AvatarWidget({this.profilePictureUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.avatarSize,
      height: AppSizes.avatarSize,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusFull)),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: profilePictureUrl != null
            ? Image.network(
                profilePictureUrl!,
                width: AppSizes.avatarSize,
                height: AppSizes.avatarSize,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: AppColors.primary),
              )
            : const Icon(Icons.person, color: AppColors.primary),
      ),
    );
  }
}
