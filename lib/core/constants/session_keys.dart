/// Key constants untuk SharedPreferences.
/// Dipakai oleh router (auth guard) dan auth feature (simpan/hapus session).
abstract final class SessionKeys {
  /// ID user yang sedang login. Null jika belum login.
  static const String userId = 'session_user_id';

  /// Nama lengkap user — cache untuk greeting UI.
  static const String userName = 'session_user_name';

  /// Email user — cache ringan untuk profile.
  static const String userEmail = 'session_user_email';
}
