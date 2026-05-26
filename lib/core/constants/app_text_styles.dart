import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semua text style ParuKuat.
/// Font utama: Manrope (via google_fonts atau fontFamily string).
///
/// Konvensi penamaan:
///   display   → teks besar hero (36px+)
///   heading   → judul section (20-28px)
///   body      → konten biasa (14-16px)
///   label     → label kecil uppercase (10-12px)
///   caption   → teks pendukung kecil
abstract final class AppTextStyles {
  static const String _font = 'Manrope';

  // ================================================================
  // DISPLAY — Hero & branding text
  // ================================================================

  /// Logo brand "ParuKuat" di AppBar (24px, ExtraBold)
  static const TextStyle brandLarge = TextStyle(
    fontFamily: _font,
    color: AppColors.primary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.33,
    letterSpacing: -1.20,
  );

  /// Logo brand di header auth (30px, ExtraBold)
  static const TextStyle brandXLarge = TextStyle(
    fontFamily: _font,
    color: AppColors.primary,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.20,
    letterSpacing: -1.50,
  );

  /// Greeting utama / hero title (36px, ExtraBold)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _font,
    color: AppColors.primary,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.33,
    letterSpacing: -1.20,
  );

  /// Display title gelap — judul card rekomendasi (36px, Bold)
  static const TextStyle displayDark = TextStyle(
    fontFamily: _font,
    color: AppColors.textPrimary,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  /// Nilai metrik besar — angka kapasitas vital / SpO2 (36px, Bold)
  static const TextStyle metricValue = TextStyle(
    fontFamily: _font,
    color: AppColors.textPrimary,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.11,
  );

  // ================================================================
  // HEADING — Section titles
  // ================================================================

  /// Judul section card (20px, Bold)
  static const TextStyle headingMedium = TextStyle(
    fontFamily: _font,
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.40,
  );

  /// Judul metric label di card (20px, Bold, secondary color)
  static const TextStyle headingSecondary = TextStyle(
    fontFamily: _font,
    color: AppColors.textSecondary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.20,
  );

  // ================================================================
  // BODY — Konten utama
  // ================================================================

  /// Body default — deskripsi, subtitle (16px, Regular)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _font,
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
  );

  /// Body medium weight — footer text, link (16px, Medium)
  static const TextStyle bodyMediumWeight = TextStyle(
    fontFamily: _font,
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.50,
  );

  /// Body primary color — greeting subtitle (16px, Regular)
  static const TextStyle bodyPrimary = TextStyle(
    fontFamily: _font,
    color: AppColors.primaryMuted,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.83,
  );

  // ================================================================
  // BUTTON — CTA text
  // ================================================================

  /// Teks tombol utama (18px, ExtraBold)
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: _font,
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.56,
  );

  /// Teks tombol sekunder / CTA card (18px, Bold)
  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: _font,
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.56,
  );

  // ================================================================
  // LABEL — Uppercase small labels
  // ================================================================

  /// Label uppercase kecil — "REKOMENDASI HARI INI" (16px, Bold, tracked)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _font,
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 1.60,
  );

  /// Label uppercase kecil — "EMAIL", "KATA SANDI" (11px, Bold, tracked)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _font,
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 1.10,
  );

  /// Label divider — "ATAU MASUK DENGAN" (11px, Bold)
  static const TextStyle labelDivider = TextStyle(
    fontFamily: _font,
    color: AppColors.textTertiary,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 1.10,
  );

  // ================================================================
  // CAPTION — Teks pendukung kecil
  // ================================================================

  /// Caption section subtitle (14px, Regular)
  static const TextStyle captionRegular = TextStyle(
    fontFamily: _font,
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  /// Caption semibold — satuan / unit (14px, SemiBold)
  static const TextStyle captionSemiBold = TextStyle(
    fontFamily: _font,
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
  );

  /// Caption link — "Daftar" / "Lupa Kata Sandi?" (14px, Bold)
  static const TextStyle captionBold = TextStyle(
    fontFamily: _font,
    color: AppColors.textLink,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  /// Caption primary badge — teks pill "Mingguan" (14px, SemiBold)
  static const TextStyle captionBadge = TextStyle(
    fontFamily: _font,
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
  );

  /// Caption teal — status oksigen "Optimal" (12px, Regular)
  static const TextStyle captionTeal = TextStyle(
    fontFamily: _font,
    color: AppColors.accentTeal,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 2,
  );

  /// Caption muted — delta "+2% vs Kemarin" (12px, Regular)
  static const TextStyle captionMuted = TextStyle(
    fontFamily: _font,
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 2,
  );

  // ================================================================
  // CHART
  // ================================================================

  /// Label bar chart hari (10px, Bold)
  static const TextStyle chartLabel = TextStyle(
    fontFamily: _font,
    color: AppColors.textSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.50,
  );

  /// Label bar chart hari — active state
  static const TextStyle chartLabelActive = TextStyle(
    fontFamily: _font,
    color: AppColors.primary,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.50,
  );

  // ================================================================
  // INPUT
  // ================================================================

  /// Teks input field aktif (16px, Medium)
  static const TextStyle inputText = TextStyle(
    fontFamily: _font,
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// Placeholder / hint text (16px, Medium)
  static const TextStyle inputHint = TextStyle(
    fontFamily: _font,
    color: AppColors.textHint,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}
