import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_routes.dart';
import '../../../widgets/bottom_nav.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../notification/presentation/notification_provider.dart';
import '../domain/home_data.dart';
import 'home_provider.dart';

/// Home Dashboard — menampilkan data real dari Supabase.
///
/// Menggantikan [HomeParukuat] di `pages/home_page.dart`.
/// Perubahan utama:
/// - Data dari [homeDataProvider] (bukan hardcoded)
/// - Nama user dari [authNotifierProvider]
/// - Navigation via GoRouter `context.go()`
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ==== APPBAR ====
            _buildAppBar(context),

            // ==== SCROLLABLE CONTENT ====
            Expanded(
              child: authState is AuthAuthenticated
                  ? _buildAuthenticatedContent(authState.user.id)
                  : const _LoadingIndicator(),
            ),

            // ==== BOTTOM NAV ====
            const BottomNav(currentRoute: '/home'),
            const SizedBox(height: AppSizes.bottomNavPadding),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // AUTHENTICATED CONTENT — Fetch data
  // ================================================================
  Widget _buildAuthenticatedContent(int userId) {
    final homeAsync = ref.watch(homeDataProvider(userId));

    return homeAsync.when(
      loading: () => const _LoadingIndicator(),
      error: (error, _) => _ErrorState(message: error.toString()),
      data: (homeData) => _HomeContent(homeData: homeData, userId: userId),
    );
  }

  // ================================================================
  // APPBAR
  // ================================================================
  Widget _buildAppBar(BuildContext context) {
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
                  return _AvatarWidget(profilePictureUrl: profileUrl);
                },
              ),
              // Notification bell with badge
              Consumer(
                builder: (context, ref, _) {
                  final authState = ref.watch(authNotifierProvider);
                  final userId = authState is AuthAuthenticated
                      ? authState.user.id
                      : null;
                  final unreadCount = userId != null
                      ? ref.watch(unreadCountProvider(userId))
                      : 0;

                  return GestureDetector(
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
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// HOME CONTENT — Data-driven body
// ====================================================================
class _HomeContent extends ConsumerWidget {
  final HomeData homeData;
  final int userId;

  const _HomeContent({required this.homeData, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        // Melakukan invalidate agar provider di-fetch ulang
        ref.invalidate(homeDataProvider(userId));
        try {
          await ref.read(homeDataProvider(userId).future);
        } catch (_) {}
      },
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Memastikan scroll selalu aktif agar bisa ditarik
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.pageHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSizes.sectionGap,
          children: [
            const SizedBox(height: AppSizes.lg),
            _GreetingSection(
              userName: homeData.userName,
              streak: homeData.currentStreak,
            ),
            _RecommendationCard(
              title: homeData.recommendationTitle,
              description: homeData.recommendationDescription,
            ),
            _VitalCapacityCard(
              value: homeData.latestVitalCapacity,
              delta: homeData.vitalCapacityDelta,
            ),
            _OxygenQualityCard(
              value: homeData.latestOxygenLevel,
              status: homeData.oxygenStatus,
            ),
            _BreathingTrendCard(trend: homeData.weeklyTrend),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// GREETING
// ====================================================================
class _GreetingSection extends StatelessWidget {
  final String userName;
  final int streak;

  const _GreetingSection({required this.userName, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 7,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: AppSizes.md),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSizes.sm,
            runSpacing: AppSizes.xs,
            children: [
              Text(
                'Halo, $userName',
                style: AppTextStyles.displayLarge,
              ),
              if (streak > 0)
                const _StreakBadge(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: AppSizes.md),
          child: Text(
            streak > 0
                ? 'Streak $streak hari! Hari yang luar biasa! 🔥\nSudah siap untuk latihan pernapasan hari ini?'
                : 'Kondisi paru-paru Anda stabil hari ini.\nSudah siap untuk latihan pernapasan hari ini?',
            style: AppTextStyles.bodyPrimary,
          ),
        ),
      ],
    );
  }
}

/// Badge streak kecil di samping greeting.
class _StreakBadge extends StatelessWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: AppColors.accentPinkBadge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
      ),
      child: const Text(
        '🔥 Streak',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ====================================================================
// RECOMMENDATION CARD
// ====================================================================
class _RecommendationCard extends StatelessWidget {
  final String title;
  final String description;

  const _RecommendationCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSizes.cardRecommendation,
      decoration: ShapeDecoration(
        color: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: AppSizes.cardBorderWidth,
            color: AppColors.cardBorder,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowCard,
            blurRadius: 50,
            offset: Offset(0, 25),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.cardPaddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REKOMENDASI HARI INI', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSizes.sm),
            Text(title, style: AppTextStyles.displayDark),
            const SizedBox(height: AppSizes.sm),
            Text(description, style: AppTextStyles.bodyMedium),
            const Spacer(),
            // Button
            GestureDetector(
              onTap: () => context.go(AppRoutes.breathing),
              child: Container(
                width: 203.42,
                height: AppSizes.buttonHeight,
                decoration: ShapeDecoration(
                  gradient: AppColors.ctaCardGradient,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Mulai Latihan',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.buttonSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// VITAL CAPACITY CARD
// ====================================================================
class _VitalCapacityCard extends StatelessWidget {
  final double? value;
  final String delta;

  const _VitalCapacityCard({required this.value, required this.delta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSizes.cardVitalCapacity,
      decoration: ShapeDecoration(
        color: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: AppSizes.cardBorderWidth,
            color: AppColors.cardBorder,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSizes.cardPaddingInner),
          // Icon box
          Container(
            width: AppSizes.metricIconBox,
            height: AppSizes.metricIconBox,
            decoration: ShapeDecoration(
              color: AppColors.accentBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusIconBox),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.air_outlined,
                size: AppSizes.iconLg,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.iconToInfo),
          // Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(delta, style: AppTextStyles.captionMuted),
                Text('Kapasitas Vital', style: AppTextStyles.headingSecondary),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value != null ? value!.toStringAsFixed(1) : '--',
                      style: AppTextStyles.metricValue,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        'Liters',
                        style: AppTextStyles.captionSemiBold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// OXYGEN QUALITY CARD
// ====================================================================
class _OxygenQualityCard extends StatelessWidget {
  final double? value;
  final String status;

  const _OxygenQualityCard({required this.value, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSizes.cardOxygenQuality,
      decoration: ShapeDecoration(
        color: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: AppSizes.cardBorderWidth,
            color: AppColors.cardBorder,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSizes.cardPaddingInner),
          // Icon box
          Container(
            width: AppSizes.metricIconBox,
            height: AppSizes.metricIconBox,
            decoration: ShapeDecoration(
              color: AppColors.accentGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusIconBox),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.favorite_outline_rounded,
                size: AppSizes.iconLg,
                color: AppColors.accentTeal,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.iconToInfo),
          // Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: AppTextStyles.captionTeal),
                Text('Kualitas Oksigen', style: AppTextStyles.headingSecondary),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value != null ? value!.toStringAsFixed(0) : '--',
                      style: AppTextStyles.metricValue,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        '% SpO2',
                        style: AppTextStyles.captionSemiBold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// BREATHING TREND CARD
// ====================================================================
class _BreathingTrendCard extends StatelessWidget {
  final List<TrendDataPoint> trend;

  const _BreathingTrendCard({required this.trend});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmall = screenWidth < 360;
    final dataPoints = trend;

    return Container(
      width: double.infinity,
      height: AppSizes.cardBreathingTrend,
      decoration: ShapeDecoration(
        color: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: AppSizes.cardBorderWidth,
            color: AppColors.cardBorder,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.cardPaddingLarge,
          AppSizes.cardPaddingLarge,
          AppSizes.cardPaddingLarge,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tren Pernapasan', style: AppTextStyles.headingMedium),
                    SizedBox(height: 4),
                    Text(
                      'Konsistensi dalam 7 hari\nterakhir',
                      style: AppTextStyles.captionRegular,
                    ),
                  ],
                ),
                // Mingguan pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? AppSizes.sm : AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  decoration: ShapeDecoration(
                    color: AppColors.accentPinkBadge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                  ),
                  child: Text(
                    'Mingguan',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.captionBadge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),
            // Bar chart
            SizedBox(
              height: AppSizes.chartBarMaxHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dataPoints.map((point) {
                  return _buildBar(
                    point.dayLabel,
                    point.normalizedValue,
                    point.isToday,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String day, double heightFactor, bool isActive) {
    // Clamp heightFactor ke 0.05 minimum agar bar tetap terlihat
    final clampedHeight = (heightFactor * AppSizes.chartBarMaxHeight * 0.7)
        .clamp(4.0, AppSizes.chartBarMaxHeight * 0.7);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: clampedHeight,
              decoration: ShapeDecoration(
                color: isActive
                    ? AppColors.chartBarActive
                    : AppColors.chartBarInactive,
                shape: RoundedRectangleBorder(
                  side: isActive
                      ? const BorderSide(
                          width: 4,
                          color: AppColors.chartBarActive,
                        )
                      : BorderSide.none,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusFull),
                    topRight: Radius.circular(AppSizes.radiusFull),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              day,
              style: isActive
                  ? AppTextStyles.chartLabelActive
                  : AppTextStyles.chartLabel,
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
  const _ErrorState({required this.message});

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
              'Gagal memuat data',
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
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Import untuk TrendDataPoint (dari domain)
// Kita perlu type-safe, gunakan import eksplisit
// ================================================================
// TrendDataPoint sudah di-import via home_provider.dart → home_data.dart
