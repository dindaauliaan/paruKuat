import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class HomeParukuat extends StatelessWidget {
  const HomeParukuat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC7C7),
      body: SafeArea(
        child: Column(
          children: [
            // ==== APPBAR ====
            _buildAppBar(context),

            // ==== SCROLLABLE CONTENT ====
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 28,
                    children: [
                      const SizedBox(height: 16),
                      // Greeting
                      _buildGreeting(),
                      // Cards
                      _buildRecommendationCard(context),
                      _buildVitalCapacityCard(),
                      _buildOxygenQualityCard(),
                      _buildBreathingTrendCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // ==== BOTTOM NAV (fixed) ====
            BottomNav(currentRoute: '/home'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // APPBAR
  // ================================================================
  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Row(
            spacing: 16,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  color: Colors.white.withValues(alpha: 0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(9999)),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: Image.network(
                    "https://placehold.co/40x40",
                    width: 40,
                    height: 40,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      color: Color(0xFFCD2C58),
                    ),
                  ),
                ),
              ),
              // Notification bell
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF3E4949),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // GREETING
  // ================================================================
  Widget _buildGreeting() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 7,
      children: [
        Text(
          'Halo, Syauqy',
          style: TextStyle(
            color: Color(0xFFCD2C58),
            fontSize: 36,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            height: 1.33,
            letterSpacing: -1.20,
          ),
        ),
        Text(
          'Kondisi paru-paru Anda stabil pagi ini.\n'
          'Sudah siap untuk latihan pernapasan hari\nini?',
          style: TextStyle(
            color: Color(0xFFA42246),
            fontSize: 16,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
            height: 1.83,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // RECOMMENDATION CARD
  // ================================================================
  Widget _buildRecommendationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 397,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.30),
          ),
          borderRadius: BorderRadius.circular(48),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C134E4A),
            blurRadius: 50,
            offset: Offset(0, 25),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(33),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            const Text(
              'REKOMENDASI HARI INI',
              style: TextStyle(
                color: Color(0xFFCD2C58),
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.50,
                letterSpacing: 1.60,
              ),
            ),
            const SizedBox(height: 8),
            // Title
            const Text(
              'Latihan\nKapasitas Vital\nPagi Hari',
              style: TextStyle(
                color: Color(0xFF181C1D),
                fontSize: 36,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            const Text(
              '5 menit latihan terkontrol untuk\n'
              'meningkatkan efisiensi oksigen Anda.',
              style: TextStyle(
                color: Color(0xFF3E4949),
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
            const Spacer(),
            // Button
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/games'),
              child: Container(
                width: 203.42,
                height: 60,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.43, -0.43),
                    end: Alignment(0.68, 2.17),
                    colors: [Color(0xFFE2416D), Color(0xFF7C233B)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Mulai Latihan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // VITAL CAPACITY CARD
  // ================================================================
  Widget _buildVitalCapacityCard() {
    return Container(
      width: double.infinity,
      height: 154,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.30),
          ),
          borderRadius: BorderRadius.circular(48),
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
      child: Row(
        children: [
          const SizedBox(width: 32),
          // Icon box
          Container(
            width: 80,
            height: 80,
            decoration: ShapeDecoration(
              color: const Color(0xFFBEE9FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.air_outlined,
                size: 40,
                color: Color(0xFF3E4949),
              ),
            ),
          ),
          const SizedBox(width: 27),
          // Info
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '+2% vs Kemarin',
                style: TextStyle(
                  color: Color(0xFF3E4949),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  height: 2,
                ),
              ),
              Text(
                'Kapasitas Vital',
                style: TextStyle(
                  color: Color(0xFF3E4949),
                  fontSize: 20,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '4.2',
                    style: TextStyle(
                      color: Color(0xFF181C1D),
                      fontSize: 36,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      height: 1.11,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      'Liters',
                      style: TextStyle(
                        color: Color(0xFF3E4949),
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        height: 1.43,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // OXYGEN QUALITY CARD
  // ================================================================
  Widget _buildOxygenQualityCard() {
    return Container(
      width: double.infinity,
      height: 159,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.30),
          ),
          borderRadius: BorderRadius.circular(48),
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
      child: Row(
        children: [
          const SizedBox(width: 32),
          // Icon box
          Container(
            width: 80,
            height: 80,
            decoration: ShapeDecoration(
              color: const Color(0xFF91FFD1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.favorite_outline_rounded,
                size: 40,
                color: Color(0xFF006565),
              ),
            ),
          ),
          const SizedBox(width: 27),
          // Info
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Optimal',
                style: TextStyle(
                  color: Color(0xFF006565),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w400,
                  height: 2,
                ),
              ),
              Text(
                'Kualitas Oksigen',
                style: TextStyle(
                  color: Color(0xFF3E4949),
                  fontSize: 20,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '98',
                    style: TextStyle(
                      color: Color(0xFF181C1D),
                      fontSize: 36,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      height: 1.11,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      '% SpO2',
                      style: TextStyle(
                        color: Color(0xFF3E4949),
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        height: 1.43,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BREATHING TREND CARD
  // ================================================================
  Widget _buildBreathingTrendCard() {
    return Container(
      width: double.infinity,
      height: 366,
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.white.withValues(alpha: 0.30),
          ),
          borderRadius: BorderRadius.circular(48),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(33, 33, 33, 0),
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
                    Text(
                      'Tren Pernapasan',
                      style: TextStyle(
                        color: Color(0xFF181C1D),
                        fontSize: 20,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Konsistensi dalam 7 hari\nterakhir',
                      style: TextStyle(
                        color: Color(0xFF3E4949),
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
                // Mingguan pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: ShapeDecoration(
                    color: const Color(0x4CFEA8A7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: const Text(
                    'Mingguan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFCD2C58),
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                      height: 1.43,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Bar chart
            SizedBox(
              height: 192,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar('SEN', 0.3, false),
                  _buildBar('SEL', 0.5, false),
                  _buildBar('RAB', 0.4, false),
                  _buildBar('KAM', 0.8, true),
                  _buildBar('JUM', 0.6, false),
                  _buildBar('SAB', 0.35, false),
                  _buildBar('MIN', 0.45, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String day, double heightFactor, bool isActive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bar
            Container(
              width: double.infinity,
              height: 140 * heightFactor,
              decoration: ShapeDecoration(
                color: isActive
                    ? const Color(0xFFCD2C58)
                    : const Color(0x66CD2C58),
                shape: RoundedRectangleBorder(
                  side: isActive
                      ? const BorderSide(width: 4, color: Color(0xFFCD2C58))
                      : BorderSide.none,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(9999),
                    topRight: Radius.circular(9999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              day,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFFCD2C58)
                    : const Color(0xFF3E4949),
                fontSize: 10,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // BOTTOM NAVIGATION
  // ================================================================
  // Using shared BottomNav widget from ../widgets/bottom_nav.dart
}
