/// Semua spacing, radius, ukuran, dan shadow token ParuKuat.
/// Dikumpulkan dari UI existing — konsisten di semua halaman.
///
/// Gunakan token ini; jangan hardcode angka langsung di widget.
abstract final class AppSizes {
  // ================================================================
  // SPACING — Padding & margin
  // ================================================================

  /// 4px — gap sangat kecil (icon-text gap, delta label)
  static const double xs = 4.0;

  /// 8px — gap kecil (SizedBox antar elemen kecil)
  static const double sm = 8.0;

  /// 12px — gap sedang-kecil
  static const double md = 12.0;

  /// 16px — gap standar (padding horizontal page, SizedBox umum)
  static const double lg = 16.0;

  /// 20px — gap sedang
  static const double xl = 20.0;

  /// 24px — padding horizontal halaman auth, gap form fields
  static const double xxl = 24.0;

  /// 20px — gap icon ke info di metric cards
  static const double iconToInfo = 20.0;

  /// 24px — Column spacing di home_page
  static const double sectionGap = 24.0;

  /// 20px — padding card content, side padding metric card
  static const double cardPaddingInner = 20.0;

  /// 24px — padding card besar (recommendation, trend cards)
  static const double cardPaddingLarge = 24.0;

  /// 40px — gap antara form section di login card
  static const double formSectionGap = 40.0;

  // ================================================================
  // PAGE PADDING
  // ================================================================

  /// Horizontal padding halaman utama (home, breathing, game)
  static const double pageHorizontal = 15.0;

  /// Horizontal padding halaman auth (login, register, welcome)
  static const double pageHorizontalAuth = 24.0;

  /// Padding top/bottom AppBar
  static const double appBarVertical = 16.0;

  /// Padding horizontal AppBar
  static const double appBarHorizontal = 24.0;

  // ================================================================
  // BORDER RADIUS
  // ================================================================

  /// Radius penuh — pill / circle (tombol, input, badge)
  static const double radiusFull = 9999.0;

  /// Radius besar — card utama (recommendation, trend, auth cards)
  static const double radiusCard = 48.0;

  /// Radius medium — icon box di metric cards
  static const double radiusIconBox = 15.0;

  // ================================================================
  // ICON SIZES
  // ================================================================

  /// Icon standar AppBar / navigation
  static const double iconSm = 20.0;

  /// Icon standar body / action
  static const double iconMd = 24.0;

  /// Icon besar — icon box metric cards
  static const double iconLg = 28.0;

  // ================================================================
  // COMPONENT SIZES
  // ================================================================

  /// Avatar user di AppBar
  static const double avatarSize = 40.0;

  /// Icon box metric cards (width & height)
  static const double metricIconBox = 60.0;

  /// Tinggi tombol CTA standar
  static const double buttonHeight = 60.0;

  /// Tinggi tombol secondary (Google button)
  static const double buttonHeightSm = 46.0;

  /// Tinggi input field
  static const double inputHeight = 56.0;

  // ================================================================
  // CARD HEIGHTS — Fixed heights dari existing cards
  // ================================================================

  /// Tinggi card rekomendasi harian
  static const double cardRecommendation = 310.0;

  /// Tinggi card Kapasitas Vital
  static const double cardVitalCapacity = 120.0;

  /// Tinggi card Kualitas Oksigen
  static const double cardOxygenQuality = 120.0;

  /// Tinggi card Tren Pernapasan
  static const double cardBreathingTrend = 300.0;

  /// Tinggi bar chart di Tren Pernapasan
  static const double chartBarMaxHeight = 140.0;

  // ================================================================
  // BOTTOM NAV
  // ================================================================

  /// Padding bawah setelah BottomNav
  static const double bottomNavPadding = 16.0;

  // ================================================================
  // CARD BORDER WIDTH
  // ================================================================

  /// Border width card glassmorphism
  static const double cardBorderWidth = 1.0;

  /// Border width bar aktif chart
  static const double chartActiveBorderWidth = 4.0;
}
