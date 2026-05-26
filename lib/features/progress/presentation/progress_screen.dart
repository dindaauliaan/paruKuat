import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/bottom_nav.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../domain/progress_data.dart';
import 'progress_provider.dart';

/// Halaman Progress — menampilkan statistik, tren chart,
/// XP progression, dan achievement badges.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  bool _isWeekly = true; // true = 7 hari, false = 30 hari

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: authState is AuthAuthenticated
                  ? _buildAuthenticatedContent(authState.user.id)
                  : const _LoadingIndicator(),
            ),
            const BottomNav(currentRoute: '/progress'),
            const SizedBox(height: AppSizes.bottomNavPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Progress', style: AppTextStyles.headingMedium),
          const Text('ParuKuat', style: AppTextStyles.brandLarge),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedContent(int userId) {
    final progressAsync = ref.watch(progressDataProvider(userId));

    return progressAsync.when(
      loading: () => const _LoadingIndicator(),
      error: (error, _) => _ErrorState(message: error.toString()),
      data: (data) => _buildContent(data),
    );
  }

  Widget _buildContent(ProgressData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.sectionGap,
        children: [
          const SizedBox(height: AppSizes.lg),

          // ── Stats Cards ──
          _StatsRow(data: data),

          // ── XP Progress Card ──
          _XpCard(data: data),

          // ── Breathing Trend Chart ──
          _TrendChartSection(
            data: data,
            isWeekly: _isWeekly,
            onToggle: () => setState(() => _isWeekly = !_isWeekly),
          ),

          // ── Achievement Badges ──
          _AchievementSection(achievements: data.achievements),

          // ── Game Stats ──
          _GameStatsCard(data: data),

          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }
}

// ====================================================================
// STATS ROW
// ====================================================================
class _StatsRow extends StatelessWidget {
  final ProgressData data;
  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withValues(alpha: 0.30)),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: const [BoxShadow(color: AppColors.shadowCard, blurRadius: 50, offset: Offset(0, 25), spreadRadius: -12)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(value: '${data.totalSessions}', label: 'SESI'),
          _divider(),
          _statItemWithSuffix(value: data.averageVitalCapacity > 0 ? data.averageVitalCapacity.toStringAsFixed(1) : '--', suffix: 'L', label: 'VITAL'),
          _divider(),
          _statItemWithSuffix(value: data.averageOxygenLevel > 0 ? data.averageOxygenLevel.toStringAsFixed(0) : '--', suffix: '%', label: 'OKSIGEN'),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 55, color: const Color(0x4CD8C2C2));

  Widget _statItem({required String value, required String label}) {
    return Column(children: [
      Text(value, style: AppTextStyles.metricValue.copyWith(color: AppColors.primary)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Color(0xFF8A7474), fontSize: 10, fontFamily: 'Manrope', fontWeight: FontWeight.w700, letterSpacing: 1)),
    ]);
  }

  Widget _statItemWithSuffix({required String value, required String suffix, required String label}) {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: AppTextStyles.metricValue.copyWith(color: AppColors.primary)),
        Padding(padding: const EdgeInsets.only(top: 6), child: Text(suffix, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontFamily: 'Manrope', fontWeight: FontWeight.w700))),
      ]),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Color(0xFF8A7474), fontSize: 10, fontFamily: 'Manrope', fontWeight: FontWeight.w700, letterSpacing: 1)),
    ]);
  }
}

// ====================================================================
// XP CARD
// ====================================================================
class _XpCard extends StatelessWidget {
  final ProgressData data;
  const _XpCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final level = data.currentLevel;
    final xp = data.totalXP;
    final xpNext = data.xpForNextLevel;
    final progress = xpNext > 0 ? (xp - _levelMinXp(level)) / (_levelMinXp(level + 1) - _levelMinXp(level)) : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.cardPaddingLarge),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withValues(alpha: 0.30)),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: const [BoxShadow(color: Color(0x0C134E4A), blurRadius: 50, offset: Offset(0, 25), spreadRadius: -12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Level', style: AppTextStyles.labelLarge),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: ShapeDecoration(
                color: AppColors.accentPinkBadge,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('Streak $streakText', style: AppTextStyles.captionBadge),
              ]),
            ),
          ]),
          const SizedBox(height: AppSizes.md),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$level', style: AppTextStyles.metricValue.copyWith(color: AppColors.primary, fontSize: 48)),
            Padding(padding: const EdgeInsets.only(left: 8, bottom: 8), child: Text('/ 10', style: AppTextStyles.captionSemiBold)),
            const Spacer(),
            Text('$xp XP', style: AppTextStyles.headingSecondary.copyWith(fontSize: 16)),
          ]),
          const SizedBox(height: AppSizes.sm),
          // XP Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0x4CBDC9C8),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            xpNext > 0 ? '$xpNext XP menuju Level ${level + 1}' : 'Level maksimum tercapai! 🎉',
            style: AppTextStyles.captionMuted,
          ),
        ],
      ),
    );
  }

  String get streakText {
    if (data.currentStreak >= 7) return '${data.currentStreak} Hari! 🔥';
    if (data.currentStreak >= 3) return '${data.currentStreak} Hari';
    if (data.currentStreak > 0) return '${data.currentStreak} Hari';
    return '0 Hari';
  }
}

int _levelMinXp(int level) {
  switch (level) {
    case 1: return 0;
    case 2: return 100;
    case 3: return 250;
    case 4: return 500;
    case 5: return 800;
    case 6: return 1200;
    case 7: return 1700;
    case 8: return 2300;
    case 9: return 3000;
    case 10: return 4000;
    default: return 0;
  }
}

// ====================================================================
// TREND CHART
// ====================================================================
class _TrendChartSection extends StatelessWidget {
  final ProgressData data;
  final bool isWeekly;
  final VoidCallback onToggle;

  const _TrendChartSection({
    required this.data,
    required this.isWeekly,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final trend = isWeekly ? data.weeklyTrend : data.monthlyTrend;
    final label = isWeekly ? 'Mingguan' : 'Bulanan';
    const subtitle = 'Riwayat Kapasitas Vital';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withValues(alpha: 0.30)),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
          BoxShadow(color: AppColors.shadowLight, blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tren Pernapasan', style: AppTextStyles.headingMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.captionRegular),
            ]),
            // Toggle pill
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: ShapeDecoration(
                  color: AppColors.accentPinkBadge,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
                ),
                child: Text(label, style: AppTextStyles.captionBadge),
              ),
            ),
          ]),
          const SizedBox(height: AppSizes.xl),
          // fl_chart BarChart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1.0,
                minY: 0,
                barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final idx = group.x.toInt();
                    if (idx < trend.length) {
                      final item = trend[idx];
                      return BarTooltipItem(
                        '${item.label}\n${item.vitalCapacity.toStringAsFixed(1)} L\n${item.sessionCount} sesi',
                        const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Manrope'),
                      );
                    }
                    return null;
                  },
                )),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= trend.length) return const SizedBox.shrink();
                      // Show subset of labels for monthly
                      if (!isWeekly && trend.length > 7 && idx % 5 != 0 && idx != trend.length - 1) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(trend[idx].label, style: AppTextStyles.chartLabel),
                      );
                    },
                    reservedSize: 28,
                  )),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(trend.length, (i) {
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: trend[i].normalizedVC,
                      color: trend[i].isToday ? AppColors.chartBarActive : AppColors.chartBarInactive,
                      width: isWeekly ? 18 : 6,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          // Legend
          Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 16, children: [
            _legendItem(color: AppColors.chartBarActive, label: 'Hari Ini'),
            _legendItem(color: AppColors.chartBarInactive, label: 'Sebelumnya'),
          ]),
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: ShapeDecoration(color: color, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))))),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.chartLabel),
    ]);
  }
}

// ====================================================================
// ACHIEVEMENT SECTION
// ====================================================================
class _AchievementSection extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementSection({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text('PENCAPAIAN', style: AppTextStyles.labelLarge)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: achievements.map((a) => _AchievementBadge(achievement: a)).toList(),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final opacity = achievement.isUnlocked ? 1.0 : 0.35;
    return Opacity(
      opacity: opacity,
      child: Tooltip(
        message: achievement.isUnlocked
            ? '${achievement.title}\n${achievement.description}'
            : '???\n${achievement.description}',
        child: Container(
          width: 64,
          height: 80,
          decoration: ShapeDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: achievement.isUnlocked
                  ? const BorderSide(color: AppColors.primary, width: 1.5)
                  : BorderSide.none,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(achievement.isUnlocked ? achievement.emoji : '🔒', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                achievement.isUnlocked ? achievement.title : '???',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: achievement.isUnlocked ? AppColors.primary : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// GAME STATS CARD
// ====================================================================
class _GameStatsCard extends StatelessWidget {
  final ProgressData data;
  const _GameStatsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.cardPaddingLarge),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withValues(alpha: 0.30)),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        shadows: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
          BoxShadow(color: AppColors.shadowLight, blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balloon Game', style: AppTextStyles.headingMedium),
          const SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _gameStatItem(icon: Icons.height, value: '${data.highestAltitude}', unit: 'FT', label: 'Tertinggi'),
              Container(width: 1, height: 40, color: const Color(0x4CD8C2C2)),
              _gameStatItem(icon: Icons.monitor_heart_outlined, value: data.averageBreathingPower.toStringAsFixed(0), unit: '%', label: 'Rata-rata Power'),
              Container(width: 1, height: 40, color: const Color(0x4CD8C2C2)),
              _gameStatItem(icon: Icons.sports_esports_outlined, value: '${data.totalGameSessions}', unit: '', label: 'Game Dimainkan'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gameStatItem({required IconData icon, required String value, required String unit, required String label}) {
    return Column(children: [
      Icon(icon, color: AppColors.primary, size: 20),
      const SizedBox(height: 4),
      Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: const TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
        if (unit.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 2, bottom: 2), child: Text(unit, style: AppTextStyles.captionMuted.copyWith(fontSize: 10))),
      ]),
      Text(label, style: AppTextStyles.chartLabel),
    ]);
  }
}

// ====================================================================
// LOADING & ERROR
// ====================================================================
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3));
  }
}

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
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.primary),
            const SizedBox(height: AppSizes.lg),
            const Text('Gagal memuat data progress', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: AppSizes.sm),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.captionRegular),
          ],
        ),
      ),
    );
  }
}
