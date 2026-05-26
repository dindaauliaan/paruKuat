import 'package:flutter/material.dart';

/// Semua color token ParuKuat.
/// Dikumpulkan dari UI existing — home, login, breathing, games, profile.
///
/// Gunakan token ini; jangan pakai raw Color(0xFF...) langsung di widget.
abstract final class AppColors {
  // ================================================================
  // PRIMARY — Pink / Rose (brand utama)
  // ================================================================

  /// Brand pink tua — logo, judul utama, active state
  static const Color primary = Color(0xFFCD2C58);

  /// Pink lebih terang — gradient awal button
  static const Color primaryLight = Color(0xFFD43A64);

  /// Pink lebih gelap — gradient akhir button / deep rose
  static const Color primaryDark = Color(0xFF9E1B3D);

  /// Pink sangat gelap — gradient CTA card
  static const Color primaryDeep = Color(0xFF7C233B);

  /// Pink untuk teks sekunder di atas background pink
  static const Color primaryMuted = Color(0xFFA42246);

  // ================================================================
  // BACKGROUND — Base page colors
  // ================================================================

  /// Background utama halaman (pink soft)
  static const Color bgPrimary = Color(0xFFFFC7C7);

  /// Background gradient tengah (cream white)
  static const Color bgSecondary = Color(0xFFFFF2F2);

  /// Background scaffold putih bersih
  static const Color bgWhite = Colors.white;

  // ================================================================
  // CARD — Glassmorphism surface
  // ================================================================

  /// Card surface semi-transparan (65% opacity)
  static Color get cardSurface => Colors.white.withValues(alpha: 0.65);

  /// Card border semi-transparan (30% opacity)
  static Color get cardBorder => Colors.white.withValues(alpha: 0.30);

  // ================================================================
  // TEXT — Semua warna teks
  // ================================================================

  /// Teks utama hampir hitam
  static const Color textPrimary = Color(0xFF181C1D);

  /// Teks sekunder dark teal/slate
  static const Color textSecondary = Color(0xFF3E4949);

  /// Teks tertier (label, caption)
  static const Color textTertiary = Color(0xFF6E7979);

  /// Teks placeholder / disabled
  static const Color textHint = Color(0xFFBDC9C8);

  /// Teks icon / prefixIcon field
  static const Color textIcon = Color(0xFF8E9999);

  /// Teks link cokelat (lupa kata sandi)
  static const Color textLink = Color(0xFF8B4823);

  // ================================================================
  // ACCENT — Warna pendukung metric cards
  // ================================================================

  /// Biru muda — icon box Kapasitas Vital
  static const Color accentBlue = Color(0xFFBEE9FF);

  /// Hijau mint — icon box Kualitas Oksigen
  static const Color accentGreen = Color(0xFF91FFD1);

  /// Teal gelap — icon & teks Kualitas Oksigen
  static const Color accentTeal = Color(0xFF006565);

  /// Pink muda transparan — pill badge "Mingguan"
  static const Color accentPinkBadge = Color(0x4CFEA8A7);

  // ================================================================
  // GRADIENT — Preset gradients yang sering dipakai
  // ================================================================

  /// Gradient background halaman utama (login, welcome, home)
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgPrimary, bgSecondary, bgPrimary],
    stops: [0.0, 0.4, 1.0],
  );

  /// Gradient tombol / CTA utama (pink → rose dark)
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment(0.20, -0.91),
    end: Alignment(0.80, 1.91),
    colors: [primaryLight, primaryDark],
  );

  /// Gradient CTA card rekomendasi (pink → deep)
  static const LinearGradient ctaCardGradient = LinearGradient(
    begin: Alignment(0.43, -0.43),
    end: Alignment(0.68, 2.17),
    colors: [Color(0xFFE2416D), primaryDeep],
  );

  // ================================================================
  // SHADOW — Box shadow colors
  // ================================================================

  /// Shadow card utama (teal tone — dari home_page)
  static const Color shadowCard = Color(0x0C134E4A);

  /// Shadow ringan umum (hitam transparan)
  static const Color shadowLight = Color(0x19000000);

  /// Shadow pink — card login
  static const Color shadowPink = Color(0x1EFF8C8C);

  // ================================================================
  // CHART — Warna bar chart trend pernapasan
  // ================================================================

  /// Bar aktif (hari ini)
  static const Color chartBarActive = primary;

  /// Bar non-aktif (semi-transparan)
  static const Color chartBarInactive = Color(0x66CD2C58);

  // ================================================================
  // DIVIDER
  // ================================================================

  /// Garis divider tipis
  static const Color divider = Color(0x4CBDC9C8);

  /// Border input field
  static const Color inputBorder = Color(0x33BDC9C8);
}
