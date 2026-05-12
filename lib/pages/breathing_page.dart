import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class BreathingParukuat extends StatelessWidget {
  const BreathingParukuat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFDFE8), // soft pink
              Color(0xFFFFFFFF), // white
              Color(0xFFFFDFE8), // soft pink
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
            // ==== APPBAR ====
            _buildAppBar(context),

            // ==== SCROLLABLE CONTENT ====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Badge
                    _buildBadge(),
                    const SizedBox(height: 16),
                    // Inhale title
                    _buildInhaleTitle(),
                    const SizedBox(height: 8),
                    // Instruction
                    const Text(
                      'Breathe slowly through your nose',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 18,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        height: 1.56,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Breathing circle visual
                    _buildBreathingCircle(),
                    const SizedBox(height: 32),
                    // Stat cards
                    _buildStatCards(),
                    const SizedBox(height: 32),
                    // Breathing phase indicator
                    _buildPhaseIndicator(),
                    const SizedBox(height: 32),
                    // Play button
                    _buildPlayButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            BottomNav(currentRoute: '/breathing'),
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Color(0xFFCD2C58), size: 20),
                SizedBox(width: 4),
                Text(
                  'Breathing',
                  style: TextStyle(
                    color: Color(0xFFCD2C58),
                    fontSize: 20,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    height: 1.60,
                    letterSpacing: -1.20,
                  ),
                ),
              ],
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
    );
  }

  // ================================================================
  // BADGE
  // ================================================================
  Widget _buildBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: ShapeDecoration(
          color: const Color(0x19CD2C58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: const Text(
          'DEEP LUNG RECOVERY',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFE06B80),
            fontSize: 12,
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
  // INHALE TITLE
  // ================================================================
  Widget _buildInhaleTitle() {
    return const Center(
      child: Text(
        'Inhale',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFCD2C58),
          fontSize: 48,
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: -1.20,
        ),
      ),
    );
  }

  // ================================================================
  // BREATHING CIRCLE
  // ================================================================
  Widget _buildBreathingCircle() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: OvalBorder(),
          shadows: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Placeholder for Lung image
            const Icon(
              Icons.spa_rounded, 
              size: 100, 
              color: Color(0xFFF48FB1),
            ),
            const SizedBox(height: 16),
            _buildTimer(),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // TIMER
  // ================================================================
  Widget _buildTimer() {
    return const Column(
      children: [
        Text(
          '00:30',
          style: TextStyle(
            color: Color(0xFFCD2C58),
            fontSize: 36,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            height: 1.11,
            letterSpacing: -1.80,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'REMAINING',
          style: TextStyle(
            color: Color(0xFFE87EA5),
            fontSize: 10,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.50,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // STAT CARDS
  // ================================================================
  Widget _buildStatCards() {
    return Row(
      spacing: 16,
      children: [
        Expanded(child: _buildSessionProgressCard()),
        Expanded(child: _buildBreathingRateCard()),
      ],
    );
  }

  Widget _buildSessionProgressCard() {
    return Container(
      height: 141,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.50),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.30),
          ),
          borderRadius: BorderRadius.circular(48),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SESSION\nPROGRESS',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: 1.10,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Cycle 4',
                style: TextStyle(
                  color: Color(0xFF181C1D),
                  fontSize: 24,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  height: 1.33,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '/ 12',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 6,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFE6E9E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 37.66,
                height: 6,
                decoration: ShapeDecoration(
                  color: const Color(0xFFCD2C58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingRateCard() {
    return Container(
      height: 141,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.50),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.30),
          ),
          borderRadius: BorderRadius.circular(48),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BREATHING RATE',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: 1.10,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '6.0',
                style: TextStyle(
                  color: Color(0xFF181C1D),
                  fontSize: 24,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  height: 1.33,
                ),
              ),
              SizedBox(width: 4),
              Text(
                'BPM',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: Color(0xFFCD2C58)),
              SizedBox(width: 4),
              Text(
                'Optimal Rhythm',
                style: TextStyle(
                  color: Color(0xFFCD2C58),
                  fontSize: 11,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BREATHING PHASE INDICATOR
  // ================================================================
  Widget _buildPhaseIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildPhaseDot(isActive: false, label: 'Hold'),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
          _buildPhaseDot(isActive: true, label: 'Inhale'),
          const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
          _buildPhaseDot(isActive: false, label: 'Exhale'),
        ],
      ),
    );
  }

  Widget _buildPhaseDot({required bool isActive, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: ShapeDecoration(
            color: isActive ? const Color(0xFFCD2C58) : const Color(0xFF94A3B8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFCD2C58) : const Color(0xFF64748B).withValues(alpha: 0.40),
            fontSize: 9,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // PLAY BUTTON
  // ================================================================
  Widget _buildPlayButton() {
    return Center(
      child: Container(
        width: 64,
        height: 64,
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
              offset: Offset(0, 8),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: Color(0x66CD2C58),
              blurRadius: 25,
              offset: Offset(0, 20),
              spreadRadius: -5,
            ),
          ],
        ),
        child: const Icon(
          Icons.pause_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}