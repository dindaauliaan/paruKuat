import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_routes.dart';
import '../../../widgets/bottom_nav.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../domain/balloon_game_state.dart';
import 'game_provider.dart';

// ====================================================================
// GAME SCREEN
// ====================================================================

/// Balloon Breathing Game — menggantikan [GamesParukuat].
///
/// State: idle → playing → (paused) → completed / gameOver
/// Interaksi:
///   - Mode Mikrofon: tiup ke mic untuk mengembangkan balon
///   - Mode Tap: tap & hold untuk exhale (mengembangkan balon)
///   - Fallback otomatis ke tap mode jika mic tidak tersedia
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──
            _buildAppBar(context),

            // ── Game Content ──
            Expanded(
              child: Stack(
                children: [
                  // Main game area
                  _buildGameArea(gameState, authState),

                  // Overlay states (pause, completion)
                  if (gameState.isPaused) _buildPauseOverlay(context),
                  if (gameState.isCompleted)
                    _buildCompletionOverlay(context, gameState, authState),
                  if (gameState.isGameOver && !gameState.isCompleted)
                    _buildGameOverOverlay(context, gameState, authState),
                ],
              ),
            ),

            // ── Bottom Nav ──
            const BottomNav(currentRoute: '/games'),
            const SizedBox(height: AppSizes.bottomNavPadding),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // APPBAR
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
                Text('Games', style: AppTextStyles.brandLarge),
              ],
            ),
          ),
          const Text('ParuKuat', style: AppTextStyles.brandLarge),
        ],
      ),
    );
  }

  // ================================================================
  // GAME AREA — Conditional rendering based on state
  // ================================================================
  Widget _buildGameArea(BalloonGameState gameState, AuthState authState) {
    // IDLE STATE
    if (!gameState.isGameActive &&
        !gameState.isGameOver &&
        !gameState.isCompleted) {
      return _buildIdleState(context);
    }

    // PLAYING STATE
    return _buildPlayingState(gameState);
  }

  // ================================================================
  // IDLE STATE — Preview + Start Button
  // ================================================================
  Widget _buildIdleState(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final isMicDenied = gameState.micPermissionStatus == 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Instruction text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppSizes.radiusCard),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Balloon Breathing Game',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isMicDenied
                      ? 'Tap & hold untuk mengembangkan balon\n'
                            'dengan napas Anda.\n\n'
                            'Jaga balon tetap terbang selama 60 detik\n'
                            'tanpa membuatnya meledak!'
                      : 'Tiup ke mikrofon untuk mengembangkan\n'
                            'balon dengan napas Anda.\n\n'
                            'Jaga balon tetap terbang selama 60 detik\n'
                            'tanpa membuatnya meledak!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                // Mode badge
                _buildModeBadge(isMicDenied),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Preview balloon (static small)
          _buildBalloonPreview(),
          const SizedBox(height: 32),
          // Start button
          _buildStartButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Badge yang menunjukkan mode input (mic / tap & hold).
  Widget _buildModeBadge(bool isMicDenied) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isMicDenied ? const Color(0xFFFFE0E0) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMicDenied ? Icons.touch_app : Icons.mic,
            size: 16,
            color: isMicDenied ? AppColors.primary : AppColors.accentTeal,
          ),
          const SizedBox(width: 6),
          Text(
            isMicDenied ? 'Mode Tap & Hold' : 'Mode Mikrofon',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isMicDenied ? AppColors.primary : AppColors.accentTeal,
            ),
          ),
        ],
      ),
    );
  }

  /// Small static balloon preview for idle state.
  Widget _buildBalloonPreview() {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Strings
          Positioned(
            bottom: 60,
            child: Row(
              spacing: 20,
              children: [
                Container(width: 2, height: 24, color: const Color(0xFFE4A475)),
                Container(width: 2, height: 24, color: const Color(0xFFE4A475)),
              ],
            ),
          ),
          // Basket
          Positioned(
            bottom: 35,
            child: Container(
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFB56A41),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF763D1E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          // Balloon body
          _buildBalloonBody(size: 0.45),
        ],
      ),
    );
  }

  // ================================================================
  // PLAYING STATE — Active game with balloon + HUD
  // ================================================================
  Widget _buildPlayingState(BalloonGameState gameState) {
    // Di mic mode, tap tidak melakukan apa-apa (biarkan GestureDetector
    // tetap ada tapi startExhale/stopExhale akan di-ignore oleh notifier).
    // Di tap mode, tap & hold untuk inflate.
    return GestureDetector(
      onTapDown: (_) {
        ref.read(gameNotifierProvider.notifier).startExhale();
      },
      onTapUp: (_) {
        ref.read(gameNotifierProvider.notifier).stopExhale();
      },
      onTapCancel: () {
        ref.read(gameNotifierProvider.notifier).stopExhale();
      },
      child: Stack(
        children: [
          // Scrollable game content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Stat cards row
                _buildGameStatCards(gameState),
                const SizedBox(height: 24),
                // Balloon area
                _buildBalloonWithAnimation(gameState),
                const SizedBox(height: 16),
                // Lung expansion progress
                _buildLungExpansionBar(gameState),
                const SizedBox(height: 16),
                // Instruction hint
                _buildBreathingHint(gameState),
                const SizedBox(height: 16),
                // Control buttons
                _buildGameControlButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STAT CARDS — Altitude & Breathing Power
  // ================================================================
  Widget _buildGameStatCards(BalloonGameState gameState) {
    return Row(
      children: [
        Expanded(
          child: _buildAltitudeWithTimerCard(gameState),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSingleStatCard(
            'BREATHING POWER',
            '${gameState.breathingPower.round()}',
            '%',
          ),
        ),
      ],
    );
  }

  /// Timer card — menggantikan Current Altitude, ukuran sama dengan
  /// card Breathing Power di sebelahnya.
  Widget _buildAltitudeWithTimerCard(BalloonGameState gameState) {
    final isLowTime = gameState.remainingTime <= 10;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label
          Text(
            'REMAINING TIME',
            style: const TextStyle(
              color: Color(0xFFC46A7A),
              fontSize: 8,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Timer value (large)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(
                Icons.timer_outlined,
                color: isLowTime ? Colors.redAccent : AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                gameState.formattedRemainingTime,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isLowTime ? Colors.redAccent : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleStatCard(String title, String value, String unit) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFC46A7A),
              fontSize: 8,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: Color(0xFFFEA8A7),
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
  // BALLOON — Animated with float effect
  // ================================================================
  Widget _buildBalloonWithAnimation(BalloonGameState gameState) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset =
            math.sin(_floatController.value * math.pi * 2) * 4.0;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: child,
        );
      },
      child: SizedBox(
        height: 340,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Clouds (background decoration)
            ..._buildClouds(),
            // Strings
            Positioned(
              bottom: 50 + (gameState.balloonSize * 20),
              child: Row(
                spacing: 16 + (gameState.balloonSize * 10),
                children: [
                  Container(
                    width: 2,
                    height: 20 + (gameState.balloonSize * 10),
                    color: const Color(0xFFE4A475),
                  ),
                  Container(
                    width: 2,
                    height: 20 + (gameState.balloonSize * 10),
                    color: const Color(0xFFE4A475),
                  ),
                ],
              ),
            ),
            // Basket
            Positioned(
              bottom: 20,
              child: Container(
                width: 40 + (gameState.balloonSize * 16),
                height: 24 + (gameState.balloonSize * 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB56A41),
                  borderRadius: BorderRadius.circular(
                    12 + (gameState.balloonSize * 4),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 10 + (gameState.balloonSize * 4),
                    height: 6 + (gameState.balloonSize * 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF763D1E),
                      borderRadius: BorderRadius.circular(
                        4 + (gameState.balloonSize * 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Balloon body
            _buildBalloonBody(
              size: gameState.balloonSize,
              isPopped: gameState.isBalloonPopped,
            ),
          ],
        ),
      ),
    );
  }

  /// Decorative cloud elements.
  List<Widget> _buildClouds() {
    return [
      Positioned(
        top: 40,
        left: 20,
        child: Container(
          width: 40,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      Positioned(
        top: 80,
        right: 30,
        child: Container(
          width: 50,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      Positioned(
        top: 160,
        left: 10,
        child: Container(
          width: 30,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ];
  }

  /// The balloon body itself — scales with balloonSize.
  Widget _buildBalloonBody({required double size, bool isPopped = false}) {
    // size: 0.05 (kempis) - 1.0 (maks)
    final balloonWidth = 80 + (size * 160);
    final balloonHeight = 100 + (size * 210);

    return Container(
      width: balloonWidth,
      height: balloonHeight,
      decoration: BoxDecoration(
        gradient: isPopped
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFB3B3), Color(0xFFFF6B6B)],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFFFF9A9A),
                    const Color(0xFFFF6B6B),
                    size,
                  )!,
                  Color.lerp(
                    const Color(0xFFE55151),
                    const Color(0xFFCC3333),
                    size,
                  )!,
                ],
              ),
        borderRadius: BorderRadius.circular(balloonWidth / 2),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0x33C0004D,
            ).withValues(alpha: 0.2 + (size * 0.3)),
            blurRadius: 15 + (size * 10),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Vertical texture lines
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(width: 1, color: Colors.white.withValues(alpha: 0.12)),
              Container(width: 1, color: Colors.white.withValues(alpha: 0.12)),
            ],
          ),
          // Glass highlight (top-right)
          Positioned(
            top: balloonHeight * 0.05,
            right: balloonWidth * 0.08,
            child: Container(
              width: balloonWidth * 0.45,
              height: balloonHeight * 0.18,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(balloonWidth * 0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.7),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          // Glass highlight (bottom-left)
          Positioned(
            bottom: balloonHeight * 0.2,
            left: balloonWidth * 0.05,
            child: Container(
              width: balloonWidth * 0.35,
              height: balloonHeight * 0.15,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(balloonWidth * 0.12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LUNG EXPANSION PROGRESS BAR
  // ================================================================
  Widget _buildLungExpansionBar(BalloonGameState gameState) {
    final progress = (gameState.balloonSize / 1.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.air, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Lung Expansion',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFD4D4D4),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.centerLeft,
            child: Container(
              width: (progress * 300).clamp(12.0, double.infinity),
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(
                      const Color(0xFFFF8080),
                      const Color(0xFFCC3333),
                      progress,
                    )!,
                    Color.lerp(
                      const Color(0xFFE55151),
                      const Color(0xFFAA2222),
                      progress,
                    )!,
                  ],
                ),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // TIMER sudah dipindah ke dalam card Current Altitude.
  // ================================================================

  // ================================================================
  // BREATHING HINT — Feedback berdasarkan mode & kondisi
  // ================================================================
  Widget _buildBreathingHint(BalloonGameState gameState) {
    final isLow = gameState.balloonSize < 0.3;
    final isHigh = gameState.balloonSize > 0.8;
    final isMicMode = gameState.useMicMode;

    String hint;
    Color hintColor;

    if (gameState.isBalloonPopped) {
      hint = 'Balloon popped! Let\'s try again.';
      hintColor = Colors.redAccent;
    } else if (isHigh) {
      hint = '⚠️ Almost full! Release to cool down.';
      hintColor = Colors.orangeAccent;
    } else if (isLow && isMicMode) {
      hint = 'Tiup lebih kuat ke mikrofon!';
      hintColor = const Color.fromARGB(255, 255, 255, 255);
    } else if (isLow) {
      hint = 'Tap & hold to inflate the balloon!';
      hintColor = const Color.fromARGB(255, 255, 255, 255);
    } else if (isMicMode && gameState.breathLabel.isNotEmpty) {
      // Gunakan label dari breath detector di mic mode
      hint = gameState.breathLabel;
      hintColor = Color(_breathDetectorColor(gameState.breathingPower));
    } else {
      hint = 'Keep going! You\'re doing great! 🌟';
      hintColor = AppColors.accentTeal;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        hint,
        key: ValueKey<String>('$hint-${gameState.timeElapsed}'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: hintColor,
        ),
      ),
    );
  }

  /// Dapatkan warna dari breathing power.
  int _breathDetectorColor(double power) {
    if (power <= 0) return 0xFFBDC9C8;
    if (power < 20) return 0xFFBDC9C8;
    if (power < 40) return 0xFFFEA8A7;
    if (power < 60) return 0xFFCD2C58;
    if (power < 80) return 0xFF006565;
    return 0xFFFF5722;
  }

  // ================================================================
  // CONTROL BUTTONS
  // ================================================================
  Widget _buildGameControlButtons() {
    return Center(
      child: GestureDetector(
        onTap: () {
          ref.read(gameNotifierProvider.notifier).pauseGame();
        },
        child: Container(
          width: 220,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryButtonGradient,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pause_circle_filled, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Pause Training',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // START BUTTON
  // ================================================================
  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        ref.read(gameNotifierProvider.notifier).startGame();
      },
      child: Container(
        width: 220,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryButtonGradient,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Mulai Game',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // PAUSE OVERLAY
  // ================================================================
  Widget _buildPauseOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 30,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_outline,
                color: AppColors.primary,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Game Paused',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  ref.read(gameNotifierProvider.notifier).resumeGame();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Center(
                    child: Text(
                      'Resume',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  ref.read(gameNotifierProvider.notifier).resetGame();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Quit Game',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // COMPLETION OVERLAY — Success (survived 60s)
  // ================================================================
  Widget _buildCompletionOverlay(
    BuildContext context,
    BalloonGameState gameState,
    AuthState authState,
  ) {
    // Trigger save once
    if (!gameState.isGameSaved && authState is AuthAuthenticated) {
      Future.microtask(
        () => ref
            .read(gameNotifierProvider.notifier)
            .saveGameStat(authState.user.id),
      );
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.2),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(48),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF91FFD1).withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.accentTeal,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Latihan Selesai!',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kamu berhasil menjaga balon tetap terbang\nselama 60 detik!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats grid
                _buildResultStatRow(
                  Icons.height,
                  'Altitude Tertinggi',
                  '${gameState.altitude.round()} FT',
                ),
                const SizedBox(height: 12),
                _buildResultStatRow(
                  Icons.favorite_outline,
                  'Breathing Power',
                  '${gameState.breathingPower.round()}%',
                ),
                const SizedBox(height: 12),
                _buildResultStatRow(
                  Icons.star_outline,
                  'Skor',
                  '${gameState.score} pts',
                ),
                const SizedBox(height: 24),
                // Buttons
                GestureDetector(
                  onTap: () {
                    ref.read(gameNotifierProvider.notifier).startGame();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Center(
                      child: Text(
                        'Main Lagi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    ref.read(gameNotifierProvider.notifier).resetGame();
                    context.go(AppRoutes.home);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // GAME OVER OVERLAY — Balloon popped or fell
  // ================================================================
  Widget _buildGameOverOverlay(
    BuildContext context,
    BalloonGameState gameState,
    AuthState authState,
  ) {
    // Trigger save once
    if (!gameState.isGameSaved && authState is AuthAuthenticated) {
      Future.microtask(
        () => ref
            .read(gameNotifierProvider.notifier)
            .saveGameStat(authState.user.id),
      );
    }

    final message = gameState.isBalloonPopped
        ? 'Balon meledak karena terlalu\npenuh! Coba atur napas lebih baik.'
        : 'Balon kehilangan udara!\nCoba tap & hold lebih lama.';

    return Container(
      color: Colors.black.withValues(alpha: 0.2),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(48),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game over icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB3B3).withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    gameState.isBalloonPopped
                        ? Icons.broken_image_outlined
                        : Icons.airline_seat_flat,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  gameState.isBalloonPopped ? 'Balon Meledak!' : 'Balon Jatuh!',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Stats
                _buildResultStatRow(
                  Icons.timer_outlined,
                  'Durasi',
                  gameState.formattedTimeElapsed,
                ),
                const SizedBox(height: 12),
                _buildResultStatRow(
                  Icons.favorite_outline,
                  'Breathing Power',
                  '${gameState.breathingPower.round()}%',
                ),
                const SizedBox(height: 24),
                // Buttons
                GestureDetector(
                  onTap: () {
                    ref.read(gameNotifierProvider.notifier).startGame();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Center(
                      child: Text(
                        'Coba Lagi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    ref.read(gameNotifierProvider.notifier).resetGame();
                    context.go(AppRoutes.home);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // RESULT STAT ROW — reusable
  // ================================================================
  Widget _buildResultStatRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
