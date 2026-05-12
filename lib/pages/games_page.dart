import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class GamesParukuat extends StatelessWidget {
  const GamesParukuat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFF0F0),
              Color(0xFFFFD4D4),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildStatCards(),
                      const SizedBox(height: 32),
                      _buildGameVisual(),
                      const SizedBox(height: 32),
                      _buildProgressBar(),
                      const SizedBox(height: 24),
                      _buildPauseButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              BottomNav(currentRoute: '/games'),
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
            onTap: () {
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Color(0xFFCD2C58), size: 20),
                SizedBox(width: 4),
                Text(
                  'Games',
                  style: TextStyle(
                    color: Color(0xFFCD2C58),
                    fontSize: 16,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'ParuKuat',
            style: TextStyle(
              color: Color(0xFFCD2C58),
              fontSize: 20,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STAT CARDS
  // ================================================================
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(child: _buildSingleStatCard('CURRENT ALTITUDE', '1,240', 'FT')),
        const SizedBox(width: 16),
        Expanded(child: _buildSingleStatCard('BREATHING POWER', '88', '%')),
      ],
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
            color: const Color(0xFFCD2C58).withValues(alpha: 0.05),
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
                  color: Color(0xFFCD2C58),
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
  // GAME VISUAL (Balloon)
  // ================================================================
  Widget _buildGameVisual() {
    return Container(
      width: double.infinity,
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCD2C58).withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Balloon strings
          Positioned(
            bottom: 45,
            child: Row(
              spacing: 24,
              children: [
                Container(width: 2, height: 28, color: const Color(0xFFE4A475)),
                Container(width: 2, height: 28, color: const Color(0xFFE4A475)),
              ],
            ),
          ),
          // Basket
          Positioned(
            bottom: 20,
            child: Container(
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFB56A41),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF763D1E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          // Balloon Body
          Positioned(
            top: 30,
            child: Container(
              width: 170,
              height: 220,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF7A7A),
                    Color(0xFFE55151),
                  ],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33C0004D),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(width: 1, color: Colors.white.withValues(alpha: 0.15)),
                  Container(width: 1, color: Colors.white.withValues(alpha: 0.15)),
                ],
              ),
            ),
          ),
          // Glass highlight top-right
          Positioned(
            top: 15,
            right: 25,
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // Glass highlight bottom-left
          Positioned(
            bottom: 70,
            left: 10,
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
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
  // PROGRESS BAR
  // ================================================================
  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.air, color: Color(0xFFCD2C58), size: 20),
            SizedBox(width: 8),
            Text(
              'Lung Expansion',
              style: TextStyle(
                color: Color(0xFFCD2C58),
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 220, // Example progress width
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8080), Color(0xFFE55151)],
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
  // PAUSE BUTTON
  // ================================================================
  Widget _buildPauseButton() {
    return Center(
      child: Container(
        width: 220,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE55D75), Color(0xFFCD2C58)],
          ),
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCD2C58).withValues(alpha: 0.4),
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
    );
  }

  // ================================================================
  // BOTTOM NAVIGATION
  // ================================================================
  // Using shared BottomNav widget from ../widgets/bottom_nav.dart
}
