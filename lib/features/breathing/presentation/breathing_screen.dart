import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_routes.dart';
import '../../../widgets/bottom_nav.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../home/presentation/home_provider.dart';
import '../domain/breathing_phase.dart';
import '../domain/breathing_state.dart';
import '../domain/exercise_type.dart';
import 'breathing_provider.dart';

/// Guided Breathing Screen — interactive breathing therapy.
///
/// Menggantikan [BreathingParukuat] di `pages/breathing_page.dart`.
/// Fitur:
/// - Timer siklus pernapasan real-time (inhale → hold → exhale → rest)
/// - Animasi lingkaran mengembang/mengempis
/// - Perubahan warna smooth
/// - Pemilih jenis latihan dari Supabase
/// - Simpan ExerciseLog setelah sesi selesai
class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breathingNotifierProvider);
    final exerciseTypesAsync = ref.watch(exerciseTypesProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFDFE8),
              Color(0xFFFFFFFF),
              Color(0xFFFFDFE8),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==== APPBAR ====
              _buildAppBar(context),

              // ==== MAIN CONTENT ====
              // Gunakan Expanded + LayoutBuilder supaya konten
              // menyesuaikan tinggi layar yang tersedia (tidak overflow)
              Expanded(
                child: state.isCompleted
                    ? _buildCompletionView(context)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Hitung ukuran circle berdasarkan ruang tersedia
                          // Maksimal 200, minimal 140 agar muat di layar kecil
                          final circleSize =
                              (constraints.maxHeight * 0.30).clamp(140.0, 200.0);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.pageHorizontal,
                            ),
                            // SingleChildScrollView hanya aktif jika konten
                            // melebihi ruang (physics NeverScrollable jika muat)
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  // Paksa Column mengisi minimal tinggi yang ada
                                  minHeight: constraints.maxHeight,
                                ),
                                child: IntrinsicHeight(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Badge exercise type
                                      _buildExerciseBadge(
                                          exerciseTypesAsync, state),

                                      // Phase title + instruction
                                      if (state.isRunning) ...[
                                        _buildPhaseTitle(state),
                                        _buildInstruction(state),
                                      ] else ...[
                                        _buildIdleTitle(),
                                        const Text(
                                          'Pilih jenis latihan dan mulai sesi\npernapasan Anda',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 14,
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],

                                      // Lingkaran pernapasan (ukuran adaptif)
                                      _buildBreathingCircle(
                                          state, circleSize),

                                      // Stat cards
                                      _buildStatCards(state),

                                      // Pace badge & phase indicator (saat running)
                                      if (state.isRunning)
                                        _buildPaceBadge(state),
                                      if (state.isRunning)
                                        _buildPhaseIndicator(state),

                                      // Exercise selector (saat idle)
                                      if (!state.isRunning)
                                        _buildExerciseSelector(
                                            exerciseTypesAsync, state),

                                      // Tombol play/pause
                                      _buildControlButton(state),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // ==== BOTTOM NAV ====
              const BottomNav(currentRoute: '/breathing'),
              const SizedBox(height: AppSizes.bottomNavPadding),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // APPBAR
  // ================================================================
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              final notifier = ref.read(breathingNotifierProvider.notifier);
              final currentState = ref.read(breathingNotifierProvider);
              final authState = ref.read(authNotifierProvider);

              // Simpan hasil latihan — baik parsial (running) maupun selesai (completed)
              if (!currentState.sessionSaved &&
                  currentState.totalSecondsElapsed > 0 &&
                  authState is AuthAuthenticated) {
                await notifier.saveSession(authState.user.id);
                // Invalidate home data agar grafik tren langsung update
                ref.invalidate(homeDataProvider(authState.user.id));
              }

              if (currentState.isRunning) {
                notifier.stopSession();
              }
              if (context.mounted) {
                context.go(AppRoutes.home);
              }
            },
            child: const Row(
              children: [
                SizedBox(width: AppSizes.xs),
                Text('Breathing', style: AppTextStyles.brandLarge),
              ],
            ),
          ),
          const Text('ParuKuat', style: AppTextStyles.brandLarge),
        ],
      ),
    );
  }

  // ================================================================
  // BADGE — Nama Exercise Type
  // ================================================================
  Widget _buildExerciseBadge(
    AsyncValue<List<ExerciseType>> exerciseTypesAsync,
    BreathingState state,
  ) {
    return exerciseTypesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => _buildBadgeLabel('DEEP LUNG RECOVERY'),
      data: (types) {
        final selected =
            types.where((t) => t.id == state.selectedExerciseTypeId);
        final label = selected.isNotEmpty
            ? selected.first.name.toUpperCase()
            : 'DEEP LUNG RECOVERY';
        return _buildBadgeLabel(label);
      },
    );
  }

  Widget _buildBadgeLabel(String label) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.xs,
        ),
        decoration: ShapeDecoration(
          color: const Color(0x19CD2C58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFE06B80),
            fontSize: 11,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.33,
            letterSpacing: 2.40,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PHASE TITLE
  // ================================================================
  Widget _buildPhaseTitle(BreathingState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        state.phase.label,
        key: ValueKey(state.phase),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: state.currentColor,
          fontSize: 28,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: -1.0,
        ),
      ),
    );
  }

  Widget _buildIdleTitle() {
    return const Text(
      'Siap Memulai',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.primary,
        fontSize: 20,
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: -1.0,
      ),
    );
  }

  // ================================================================
  // INSTRUCTION
  // ================================================================
  Widget _buildInstruction(BreathingState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        state.phase.instruction,
        key: ValueKey(state.phase),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }

  // ================================================================
  // BREATHING CIRCLE — ukuran adaptif via parameter [size]
  // ================================================================
  Widget _buildBreathingCircle(BreathingState state, double size) {
    final iconSize = size * 0.32;
    final fontSize = size * 0.14;

    return Center(
      child: AnimatedScale(
        scale: state.circleScale,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phase icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Icon(
                  _phaseIcon(state.phase),
                  key: ValueKey(state.phase),
                  size: iconSize,
                  color: state.currentColor,
                ),
              ),
              const SizedBox(height: 8),
              // Timer display
              Text(
                _formatTime(
                  state.isRunning || state.isCompleted
                      ? state.totalSecondsElapsed
                      : 0,
                ),
                style: TextStyle(
                  color: state.isRunning || state.isCompleted
                      ? state.currentColor
                      : AppColors.primary,
                  fontSize: fontSize,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                state.isRunning || state.isCompleted ? 'ELAPSED' : 'READY',
                style: const TextStyle(
                  color: Color(0xFFE87EA5),
                  fontSize: 10,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _phaseIcon(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return Icons.air_outlined;
      case BreathingPhase.hold:
        return Icons.pause_circle_outline_rounded;
      case BreathingPhase.exhale:
        return Icons.wind_power_outlined;
      case BreathingPhase.rest:
        return Icons.spa_rounded;
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ================================================================
  // STAT CARDS
  // ================================================================
  Widget _buildStatCards(BreathingState state) {
    return Row(
      spacing: AppSizes.md,
      children: [
        Expanded(child: _buildSessionProgressCard(state)),
      ],
    );
  }

  Widget _buildSessionProgressCard(BreathingState state) {
    final progress = state.isRunning || state.isCompleted
        ? state.totalSecondsElapsed / state.totalSessionDuration
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.50),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.30),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'SESSION PROGRESS',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Cycle ${state.currentCycle}',
                style: const TextStyle(
                  color: Color(0xFF181C1D),
                  fontSize: 18,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ ${state.totalCycles}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 5,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFE6E9E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 5,
                  decoration: ShapeDecoration(
                    color: state.currentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingRateCard(BreathingState state) {
    final bpm = state.isRunning || state.isCompleted
        ? (state.totalCycles /
            (state.totalSecondsElapsed > 0
                ? state.totalSecondsElapsed / 60
                : 1))
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.50),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.30),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'BREATHING RATE',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bpm > 0 ? bpm.toStringAsFixed(1) : '--',
                style: const TextStyle(
                  color: Color(0xFF181C1D),
                  fontSize: 18,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'BPM',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                state.isRunning || state.isCompleted
                    ? 'Active Session'
                    : 'Ready',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PACE BADGE
  // ================================================================
  Widget _buildPaceBadge(BreathingState state) {
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: ShapeDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed, size: 12, color: Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              'Pace',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B).withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: ShapeDecoration(
                color: state.currentColor.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Text(
                state.pace.label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: state.currentColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${state.pace.cycleDuration}s/cycle',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // PHASE INDICATOR
  // ================================================================
  Widget _buildPhaseIndicator(BreathingState state) {
    final phases = [
      ('Inhale', state.phase == BreathingPhase.inhale),
      ('Hold', state.phase == BreathingPhase.hold),
      ('Exhale', state.phase == BreathingPhase.exhale),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: phases.map((p) {
          final isActive = p.$2;
          final label = p.$1;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (label != 'Inhale')
                      Expanded(
                        child: Divider(
                          color: const Color(0xFFE2E8F0),
                          thickness: 1,
                        ),
                      ),
                    Container(
                      width: isActive ? 10 : 7,
                      height: isActive ? 10 : 7,
                      decoration: ShapeDecoration(
                        color: isActive
                            ? state.currentColor
                            : const Color(0xFF94A3B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                    if (label != 'Exhale')
                      Expanded(
                        child: Divider(
                          color: const Color(0xFFE2E8F0),
                          thickness: 1,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? state.currentColor
                        : const Color(0xFF64748B).withValues(alpha: 0.40),
                    fontSize: 9,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================================================================
  // EXERCISE TYPE SELECTOR
  // ================================================================
  Widget _buildExerciseSelector(
    AsyncValue<List<ExerciseType>> exerciseTypesAsync,
    BreathingState state,
  ) {
    return exerciseTypesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
      ),
      error: (_, _) => _buildFallbackSelector(state),
      data: (types) => types.isEmpty
          ? _buildFallbackSelector(state)
          : _buildSelectorList(types, state),
    );
  }

  Widget _buildFallbackSelector(BreathingState state) {
    final fallbackTypes = <ExerciseType>[
      ExerciseType(id: 1, name: 'Deep Lung Recovery', durationSeconds: 112),
      ExerciseType(id: 2, name: 'Pursed Lip Breathing', durationSeconds: 112),
      ExerciseType(
          id: 3, name: 'Diaphragmatic Breathing', durationSeconds: 168),
    ];
    return _buildSelectorList(fallbackTypes, state);
  }

  Widget _buildSelectorList(List<ExerciseType> types, BreathingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Pilih Jenis Latihan',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: types.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final type = types[index];
              final isSelected = state.selectedExerciseTypeId == type.id;
              final pace = paceForExerciseType(type.id);
              return GestureDetector(
                onTap: () {
                  ref
                      .read(breathingNotifierProvider.notifier)
                      .selectExerciseType(type.id);
                },
                child: Container(
                  width: 155,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: ShapeDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.50),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.30),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF181C1D),
                          fontSize: 12,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${type.durationSeconds ~/ 60} menit',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white70
                              : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        pace.description,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white54
                              : const Color(0xFF94A3B8)
                                  .withValues(alpha: 0.7),
                          fontSize: 9,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================================================================
  // CONTROL BUTTON
  // ================================================================
  Widget _buildControlButton(BreathingState state) {
    if (state.isCompleted) return const SizedBox.shrink();

    IconData icon;
    VoidCallback? onTap;

    if (state.isRunning) {
      icon = Icons.pause_rounded;
      onTap = () async {
        final notifier = ref.read(breathingNotifierProvider.notifier);
        final authState = ref.read(authNotifierProvider);

        // Simpan hasil latihan parsial saat pause
        if (authState is AuthAuthenticated) {
          await notifier.saveSession(authState.user.id);
        }
        notifier.pauseSession();
      };
    } else if (state.totalSecondsElapsed > 0) {
      icon = Icons.play_arrow_rounded;
      onTap = () {
        ref.read(breathingNotifierProvider.notifier).resumeSession();
      };
    } else {
      icon = Icons.play_arrow_rounded;
      onTap = () {
        ref.read(breathingNotifierProvider.notifier).startSession();
      };
    }

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment(0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [Color(0xFFCD2C58), Color(0xFFD94D6B)],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x66CD2C58),
                blurRadius: 10,
                offset: Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // ================================================================
  // COMPLETION VIEW
  // ================================================================
  Widget _buildCompletionView(BuildContext context) {
    final state = ref.read(breathingNotifierProvider);
    final authState = ref.read(authNotifierProvider);

    // Save session log — trigger sekali via microtask (hanya jika belum tersimpan)
    if (!state.sessionSaved && authState is AuthAuthenticated) {
      Future.microtask(() {
        ref
            .read(breathingNotifierProvider.notifier)
            .saveSession(authState.user.id);
      });
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              width: 100,
              height: 100,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: OvalBorder(),
                shadows: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Latihan Selesai! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                height: 1.20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${state.totalCycles} cycles completed\n${_formatTime(state.totalSecondsElapsed)} total duration',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                height: 1.60,
              ),
            ),
            const Spacer(flex: 1),
            GestureDetector(
              onTap: () async {
                final notifier = ref.read(breathingNotifierProvider.notifier);
                final currentAuth = ref.read(authNotifierProvider);

                // 1. Simpan hasil latihan dulu — tunggu sampai selesai
                if (!state.sessionSaved && currentAuth is AuthAuthenticated) {
                  await notifier.saveSession(currentAuth.user.id);
                }

                // 2. Stop sesi
                notifier.stopSession();

                // 3. Invalidate home data agar refetch data terbaru
                if (currentAuth is AuthAuthenticated) {
                  ref.invalidate(homeDataProvider(currentAuth.user.id));
                }

                // 4. Navigasi ke home
                if (context.mounted) {
                  context.go(AppRoutes.home);
                }
              },
              child: Container(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                decoration: ShapeDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x66CD2C58),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Kembali ke Beranda',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.buttonPrimary,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}