import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class ProfileParukuat extends StatelessWidget {
  const ProfileParukuat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC7C7),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    spacing: 28,
                    children: [
                      const SizedBox(height: 16),

                      // Profile Header (avatar + name + badge)
                      _buildProfileHeader(),

                      // Stats card (latihan, vital, skor)
                      _buildStatsCard(),

                      // Personal Information
                      _buildPersonalInfoSection(),

                      // App Settings
                      _buildAppSettingsSection(),

                      // Logout & Version
                      _buildLogoutSection(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            const BottomNav(currentRoute: '/profile'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // APP BAR
  // ================================================================
  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                color: Color(0xFFC0004D),
                fontSize: 20,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                height: 1.40,
                letterSpacing: -0.45,
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
    );
  }

  // ================================================================
  // PROFILE HEADER
  // ================================================================
  Widget _buildProfileHeader() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // Avatar with gradient ring + edit badge
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
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: Container(
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 4,
                          color: Color(0xFFFFF8F7),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(9999)),
                      ),
                    ),
                    child: Image.network(
                      "https://placehold.co/120x120",
                      width: 120,
                      height: 120,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFFC0004D),
                      ),
                    ),
                  ),
                ),
              ),
              // Edit badge
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFC0004D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
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
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          const Text(
            'Syauqy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFC0004D),
              fontSize: 30,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              height: 1.20,
              letterSpacing: -0.75,
            ),
          ),
          const SizedBox(height: 8),

          // Premium Member badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: ShapeDecoration(
              color: const Color(0xFFFFD9DF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: const Text(
              'PREMIUM MEMBER',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFC0004D),
                fontSize: 10,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                height: 1.50,
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
  Widget _buildStatsCard() {
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
          // Latihan
          _buildStatItem(
            value: '24',
            label: 'LATIHAN',
          ),
          // Divider
          Container(
            width: 1,
            height: 55,
            color: const Color(0x4CD8C2C2),
          ),
          // Vital
          _buildStatItemWithSuffix(
            value: '4.2',
            suffix: 'L',
            label: 'VITAL',
          ),
          // Divider
          Container(
            width: 1,
            height: 55,
            color: const Color(0x4CD8C2C2),
          ),
          // Skor
          _buildStatItemWithSuffix(
            value: '92',
            suffix: '%',
            label: 'SKOR',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
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
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A7474),
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

  Widget _buildStatItemWithSuffix({
    required String value,
    required String suffix,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC0004D),
                fontSize: 30,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w800,
                height: 1.20,
                letterSpacing: -1.50,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                suffix,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFC0004D),
                  fontSize: 12,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8A7474),
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
  // PERSONAL INFORMATION SECTION
  // ================================================================
  Widget _buildPersonalInfoSection() {
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
              height: 1.50,
              letterSpacing: 1.65,
            ),
          ),
        ),
        Container(
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
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'EMAIL',
                value: 'syauqy@it.pens.ac.id',
              ),
              _buildDivider(),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'PHONE NUMBER',
                value: '+62 812 3456 7890',
              ),
              _buildDivider(),
              _buildInfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'DATE OF BIRTH',
                value: '14 August 1995',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
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
                    height: 1.50,
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
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFD8C2C2),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0x19D8C2C2),
    );
  }

  // ================================================================
  // APP SETTINGS SECTION
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
              height: 1.50,
              letterSpacing: 1.65,
            ),
          ),
        ),
        Container(
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
          child: Column(
            children: [
              _buildToggleRow(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                isActive: true,
              ),
              _buildDivider(),
              _buildSettingRow(
                icon: Icons.language_outlined,
                title: 'Language',
                trailing: 'English',
              ),
              _buildDivider(),
              _buildSettingRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                trailing: null,
              ),
              _buildDivider(),
              _buildSettingRow(
                icon: Icons.help_outline,
                title: 'Help Center',
                trailing: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool isActive,
  }) {
    return Padding(
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
                  height: 1.50,
                ),
              ),
            ],
          ),
          // Toggle switch
          Container(
            width: 56,
            height: 32,
            decoration: ShapeDecoration(
              color: isActive
                  ? const Color(0xFFC0004D)
                  : const Color(0xFFF4DDDD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
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
                        borderRadius: BorderRadius.circular(9999),
                      ),
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

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? trailing,
  }) {
    return Padding(
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
                height: 1.50,
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
                height: 1.43,
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFD8C2C2),
            size: 24,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LOGOUT SECTION
  // ================================================================
  Widget _buildLogoutSection() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // Logout button
          Container(
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
            child: const Center(
              child: Text(
                'Logout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC0004D),
                  fontSize: 15,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                  letterSpacing: 0.38,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'PARUKUAT V2.4.0 • BUILT FOR SANCTUARY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD8C2C2),
              fontSize: 9,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              height: 1.50,
              letterSpacing: 2.25,
            ),
          ),
        ],
      ),
    );
  }
}
