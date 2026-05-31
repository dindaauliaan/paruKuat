import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../widgets/bottom_nav.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../progress/presentation/progress_provider.dart';

/// Halaman Profile — menampilkan data user real dari Supabase,
/// statistik latihan, dan tombol logout fungsional.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoggingOut = false;
  bool _isUpdatingPhoto = false;
  final _picker = ImagePicker();

  bool _notificationsEnabled = false;
  int _reminderHour = 8;
  int _reminderMinute = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(sharedPreferencesProvider);
      setState(() {
        _notificationsEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
        _reminderHour = prefs.getInt('daily_reminder_hour') ?? 8;
        _reminderMinute = prefs.getInt('daily_reminder_minute') ?? 0;
      });
    });
  }

  Future<void> _updateNotificationSettings({
    bool? enabled,
    int? hour,
    int? minute,
  }) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final notificationService = LocalNotificationService();

    if (enabled != null) {
      _notificationsEnabled = enabled;
      await prefs.setBool('daily_reminder_enabled', enabled);
    }
    if (hour != null) {
      _reminderHour = hour;
      await prefs.setInt('daily_reminder_hour', hour);
    }
    if (minute != null) {
      _reminderMinute = minute;
      await prefs.setInt('daily_reminder_minute', minute);
    }

    setState(() {});

    if (_notificationsEnabled) {
      final granted = await notificationService.requestPermissions();
      if (granted) {
        await notificationService.scheduleDailyReminder(_reminderHour, _reminderMinute);
      } else {
        setState(() {
          _notificationsEnabled = false;
        });
        await prefs.setBool('daily_reminder_enabled', false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin notifikasi ditolak. Pengingat tidak dapat dijadwalkan.'),
              backgroundColor: Color(0xFFC0004D),
            ),
          );
        }
      }
    } else {
      await notificationService.cancelDailyReminder();
    }
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFC0004D),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF231919),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      await _updateNotificationSettings(hour: picked.hour, minute: picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: authState is AuthAuthenticated
                  ? _buildContent(authState)
                  : const _LoadingIndicator(),
            ),
            const BottomNav(currentRoute: '/profile'),
            const SizedBox(height: AppSizes.bottomNavPadding),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // APP BAR
  // ================================================================
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.appBarHorizontal,
        16,
        AppSizes.appBarHorizontal,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: const Row(
              children: [
                SizedBox(width: 4),
                Text('Profile', style: AppTextStyles.brandLarge),
              ],
            ),
          ),
          const Text('ParuKuat', style: AppTextStyles.brandLarge),
        ],
      ),
    );
  }

  // ================================================================
  // CONTENT
  // ================================================================
  Widget _buildContent(AuthAuthenticated authState) {
    final user = authState.user;
    final progressAsync = ref.watch(progressDataProvider(user.id));

    return RefreshIndicator(
      color: const Color(0xFFC0004D),
      backgroundColor: Colors.white,
      onRefresh: () async {
        ref.invalidate(progressDataProvider(user.id));
        try {
          await ref.read(progressDataProvider(user.id).future);
        } catch (_) {}
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          spacing: 28,
          children: [
            const SizedBox(height: 16),

            // Profile Header
            _buildProfileHeader(user),

            // Stats Card
            progressAsync.when(
              loading: () => _buildStatsCard(null),
              error: (_, _) => _buildStatsCard(null),
              data: (data) => _buildStatsCard(data),
            ),

            // Personal Information
            _buildPersonalInfoSection(user),

            // App Settings
            _buildAppSettingsSection(),

            // Logout
            _buildLogoutSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // PROFILE HEADER
  // ================================================================
  Widget _buildProfileHeader(dynamic user) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 128,
                height: 128,
                padding: const EdgeInsets.all(4),
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, 1.00),
                    end: Alignment(1.00, 0.00),
                    colors: [Color(0xFFC0004D), Color(0xFFFFD9DF)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF8F7),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4), // Tebal border putih
                  child: ClipOval(
                    child: _buildAvatarImage(user.profilePicture),
                  ),
                ),
              ),
              // Edit badge
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _isUpdatingPhoto ? null : _pickProfilePicture,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      color: _isUpdatingPhoto
                          ? const Color(0xFFD8C2C2)
                          : const Color(0xFFC0004D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 15,
                          offset: Offset(0, 10),
                          spreadRadius: -3,
                        ),
                      ],
                    ),
                    child: _isUpdatingPhoto
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSizes.sm,
            runSpacing: AppSizes.xs,
            children: [
              Text(
                user.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFC0004D),
                  fontSize: 30,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  height: 1.20,
                  letterSpacing: -0.75,
                ),
              ),
            ],
          ),
          // Text(
          //   user.fullName,
          //   textAlign: TextAlign.center,
          //   style: const TextStyle(
          //     color: Color(0xFFC0004D),
          //     fontSize: 30,
          //     fontFamily: 'Manrope',
          //     fontWeight: FontWeight.w800,
          //     height: 1.20,
          //     letterSpacing: -0.75,
          //   ),
          // ),
          const SizedBox(height: 8),

          // Member badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFD9DF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
            ),
            child: const Text(
              'PARUKUAT MEMBER',
              style: TextStyle(
                color: Color(0xFFC0004D),
                fontSize: 10,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STATS CARD
  // ================================================================

  /// Menampilkan foto profil dari Supabase Storage (https://) atau
  /// path lokal (fallback), atau ikon placeholder jika null.
  ///
  /// URL Supabase di-cache-bust per menit agar gambar terbaru langsung
  /// tampil setelah upload tanpa perlu restart app.
  Widget _buildAvatarImage(String? picturePath) {
    if (picturePath == null || picturePath.isEmpty) {
      return const Icon(Icons.person, size: 60, color: Color(0xFFC0004D));
    }

    // Fallback path lokal (sebelum Storage aktif)
    if (!picturePath.startsWith('http')) {
      return Image.file(
        File(picturePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, _) =>
            const Icon(Icons.person, size: 60, color: Color(0xFFC0004D)),
      );
    }

    // URL Supabase Storage — cache-buster per menit
    final cacheBustedUrl =
        '$picturePath?t=${DateTime.now().millisecondsSinceEpoch ~/ 60000}';

    return Image.network(
      cacheBustedUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, _) =>
          const Icon(Icons.person, size: 60, color: Color(0xFFC0004D)),
    );
  }

  Widget _buildStatsCard(dynamic progressData) {
    final totalSessions = progressData?.totalSessions ?? 0;
    final avgVC = progressData?.averageVitalCapacity ?? 0.0;
    final xp = progressData?.totalXP ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 33),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.50),
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0FC0004D),
            blurRadius: 50,
            offset: Offset(0, 20),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(value: '$totalSessions', label: 'LATIHAN'),
          Container(width: 1, height: 55, color: const Color(0x4CD8C2C2)),
          _statItemSuffix(
            value: avgVC > 0 ? avgVC.toStringAsFixed(1) : '--',
            suffix: 'L',
            label: 'VITAL',
          ),
          Container(width: 1, height: 55, color: const Color(0x4CD8C2C2)),
          _statItemSuffix(value: '$xp', suffix: '', label: 'XP'),
        ],
      ),
    );
  }

  Widget _statItem({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFC0004D),
            fontSize: 30,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            height: 1.20,
            letterSpacing: -1.50,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A7474),
            fontSize: 10,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _statItemSuffix({
    required String value,
    required String suffix,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFC0004D),
                fontSize: 30,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                height: 1.20,
                letterSpacing: -1.50,
              ),
            ),
            if (suffix.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    color: Color(0xFFC0004D),
                    fontSize: 12,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A7474),
            fontSize: 10,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // PERSONAL INFORMATION
  // ================================================================
  Widget _buildPersonalInfoSection(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'PERSONAL INFORMATION',
            style: TextStyle(
              color: Color(0xFF8A7474),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              letterSpacing: 1.65,
            ),
          ),
        ),
        _infoCard([
          _infoRow(
            icon: Icons.email_outlined,
            label: 'EMAIL',
            value: user.email,
            onTap: () => _showEditEmailSheet(user.email),
          ),
          _divider(),
          _infoRow(
            icon: Icons.phone_outlined,
            label: 'PHONE NUMBER',
            value: user.phoneNumber ?? 'Belum diisi',
            onTap: () => _showEditPhoneSheet(user.phoneNumber),
          ),
          _divider(),
          _infoRow(
            icon: Icons.calendar_today_outlined,
            label: 'DATE OF BIRTH',
            value: user.birthDate != null
                ? '${user.birthDate!.day} ${_monthName(user.birthDate!.month)} ${user.birthDate!.year}'
                : 'Belum diisi',
            onTap: () => _showEditDobSheet(user.birthDate),
          ),
        ]),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.50),
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 30,
            offset: Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: const Color(0xFFFCE8E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Icon(icon, color: const Color(0xFFC0004D), size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF8A7474),
                      fontSize: 10,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.25,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF231919),
                      fontSize: 15,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: onTap != null
                  ? const Color(0xFFC0004D)
                  : const Color(0xFFD8C2C2),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: const Color(0x19D8C2C2));

  // ================================================================
  // APP SETTINGS
  // ================================================================
  Widget _buildAppSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'APP SETTINGS',
            style: TextStyle(
              color: Color(0xFF8A7474),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              letterSpacing: 1.65,
            ),
          ),
        ),
        _infoCard([
          _toggleRow(
            icon: Icons.notifications_outlined,
            title: 'Daily Reminder',
            isActive: _notificationsEnabled,
            onChanged: (val) => _updateNotificationSettings(enabled: val),
          ),
          if (_notificationsEnabled) ...[
            _divider(),
            _settingRow(
              icon: Icons.access_time_outlined,
              title: 'Reminder Time',
              trailing: '${_reminderHour.toString().padLeft(2, '0')}:${_reminderMinute.toString().padLeft(2, '0')}',
              onTap: _selectReminderTime,
            ),
          ],
        ]),
      ],
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String title,
    required bool isActive,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!isActive),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF8ECEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Icon(icon, color: const Color(0xFFC0004D), size: 24),
                ),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF231919),
                    fontSize: 15,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              width: 56,
              height: 32,
              decoration: ShapeDecoration(
                color: isActive
                    ? const Color(0xFFC0004D)
                    : const Color(0xFFF4DDDD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: isActive ? 28 : 4,
                    top: 4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFFD1D5DB),
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: const Color(0xFFF8ECEA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Icon(icon, color: const Color(0xFFC0004D), size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF231919),
                  fontSize: 15,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing,
                style: const TextStyle(
                  color: Color(0xFF8A7474),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: Color(0xFFD8C2C2), size: 24),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // LOGOUT
  // ================================================================
  Widget _buildLogoutSection() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // Logout button
          GestureDetector(
            onTap: _isLoggingOut ? null : _confirmLogout,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: ShapeDecoration(
                color: Colors.white.withValues(alpha: 0.50),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.60),
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Center(
                child: _isLoggingOut
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFC0004D),
                        ),
                      )
                    : const Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFC0004D),
                          fontSize: 15,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.38,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'PARUKUAT V1.0.0 • BUILT FOR SANCTUARY',
            style: TextStyle(
              color: Color.fromARGB(255, 117, 117, 117),
              fontSize: 9,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 2.25,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PROFILE PICTURE — Pick & Upload ke Supabase Storage
  // ================================================================
  Future<void> _pickProfilePicture() async {
    // Tampilkan pilihan sumber gambar
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ImageSourceSheet(),
    );
    if (source == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUpdatingPhoto = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .uploadAndSaveProfilePicture(imageFile: File(picked.path));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            backgroundColor: Color(0xFFC0004D),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingPhoto = false);
    }
  }

  // ================================================================
  // EDIT EMAIL BOTTOM SHEET
  // ================================================================
  void _showEditEmailSheet(String currentEmail) {
    final ctrl = TextEditingController(text: currentEmail);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditFieldSheet(
        title: 'Edit Email',
        icon: Icons.email_outlined,
        controller: ctrl,
        keyboardType: TextInputType.emailAddress,
        hint: 'Masukkan email baru',
        onSave: (value) async {
          await ref
              .read(authNotifierProvider.notifier)
              .updateProfile(email: value);
        },
      ),
    );
  }

  // ================================================================
  // EDIT PHONE BOTTOM SHEET
  // ================================================================
  void _showEditPhoneSheet(String? currentPhone) {
    final ctrl = TextEditingController(text: currentPhone ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditFieldSheet(
        title: 'Edit Nomor Telepon',
        icon: Icons.phone_outlined,
        controller: ctrl,
        keyboardType: TextInputType.phone,
        hint: 'Contoh: 08123456789',
        onSave: (value) async {
          await ref
              .read(authNotifierProvider.notifier)
              .updateProfile(phoneNumber: value);
        },
      ),
    );
  }

  // ================================================================
  // EDIT DATE OF BIRTH BOTTOM SHEET
  // ================================================================
  void _showEditDobSheet(DateTime? currentDob) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDob ?? DateTime(now.year - 25),
      firstDate: DateTime(1930),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFC0004D),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF231919),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .updateProfile(birthDate: picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal lahir berhasil diperbarui!'),
            backgroundColor: Color(0xFFC0004D),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar?',
          style: TextStyle(fontFamily: 'Manrope'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _performLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) context.go(AppRoutes.login);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal logout. Silakan coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }
}

// ====================================================================
// WIDGET — Pilih sumber gambar profil
// ====================================================================
class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ganti Foto Profil',
            style: TextStyle(
              color: Color(0xFF231919),
              fontSize: 18,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih sumber gambar',
            style: TextStyle(
              color: Color(0xFF8A7474),
              fontSize: 13,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Kamera',
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeri',
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF8A7474),
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE8E8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFC0004D), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFC0004D),
                fontSize: 13,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// WIDGET — Edit Field Bottom Sheet (email / phone)
// ====================================================================
class _EditFieldSheet extends StatefulWidget {
  final String title;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hint;
  final Future<void> Function(String value) onSave;

  const _EditFieldSheet({
    required this.title,
    required this.icon,
    required this.controller,
    required this.keyboardType,
    required this.hint,
    required this.onSave,
  });

  @override
  State<_EditFieldSheet> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends State<_EditFieldSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _save() async {
    final value = widget.controller.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Field tidak boleh kosong');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onSave(value);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.title} berhasil diperbarui!'),
            backgroundColor: const Color(0xFFC0004D),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE8E8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.icon,
                  color: const Color(0xFFC0004D),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFF231919),
                  fontSize: 18,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            autofocus: true,
            style: const TextStyle(
              color: Color(0xFF231919),
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFFD8C2C2),
                fontFamily: 'Manrope',
              ),
              errorText: _error,
              filled: true,
              fillColor: const Color(0xFFFFF8F7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFC0004D),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFD8C2C2)),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Color(0xFF8A7474),
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC0004D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// WIDGET — Loading Indicator
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
