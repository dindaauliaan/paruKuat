import 'package:flutter/material.dart';

class WelcomePageParukuat extends StatefulWidget {
  const WelcomePageParukuat({super.key});

  @override
  State<WelcomePageParukuat> createState() => _WelcomePageParukuatState();
}

class _WelcomePageParukuatState extends State<WelcomePageParukuat>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              // ==== LAPISAN ATAS: Ilustrasi & Gelombang ====
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.55,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF5F5),
                        Color(0xFFFFEBEB),
                        Color(0xFFFFF0F0),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Lingkaran dekoratif
                      Positioned(
                        top: -60,
                        right: -60,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEB4C4C).withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.08,
                        left: -30,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFEA8A7).withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // Ilustrasi paru-paru
                      Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.06),
                            child: Image.asset(
                              'assets/images/LogoParuKuat.png',
                              width: 300,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.air_outlined,
                                  size: 120,
                                  color: const Color(0xFFEB4C4C).withValues(alpha: 0.2),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Gelombang bawah
                      Positioned(
                        bottom: -1,
                        left: 0,
                        right: 0,
                        child: CustomPaint(
                          size: Size(screenWidth, 60),
                          painter: _WavePainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==== LAPISAN BAWAH: Konten ====
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Logo teks "Paru Kuat"
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Paru',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w300,
                                      color: const Color(0xFFEB4C4C),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Kuat',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFEB4C4C),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Jaga kesehatan paru-parumu\nuntuk hidup yang lebih baik',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                height: 1.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Tombol Mulai
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/login',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFEB4C4C),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: const Color(0xFFEB4C4C)
                                    .withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: const Text(
                                'Mulai',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==== Wave Painter untuk gelombang ====
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF5F5),
          Color(0xFFFFFFFF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.3);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.2,
    );
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
