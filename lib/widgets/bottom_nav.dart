import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final String currentRoute;

  const BottomNav({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildItem(
            context,
            icon: Icons.home_outlined,
            label: 'HOME',
            isActive: currentRoute == '/home',
            route: '/home',
          ),
          _buildItem(
            context,
            icon: Icons.videogame_asset,
            label: 'GAMES',
            isActive: currentRoute == '/games',
            route: '/games',
          ),
          _buildItem(
            context,
            icon: Icons.assignment_outlined,
            label: 'BREATHING',
            isActive: currentRoute == '/breathing',
            route: '/breathing',
          ),
          _buildItem(
            context,
            icon: Icons.person_outline,
            label: 'PROFILE',
            isActive: currentRoute == '/profile',
            route: '/profile',
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    String? route,
  }) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: isActive
            ? _buildActiveItem(icon, label)
            : _buildInactiveItem(context, icon, label, route),
      ),
    );
  }

  Widget _buildActiveItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFC0004D),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4DC0004D),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveItem(
    BuildContext context,
    IconData icon,
    String label,
    String? route,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: route != null
            ? () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  route,
                  (route) => route.isFirst,
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF3E4949), size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF3E4949),
                  fontSize: 8,
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
}
