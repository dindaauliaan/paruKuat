import 'home_data.dart';

/// Interface repository untuk data Home Dashboard.
///
/// Abstraction layer — implementasi konkrit menggunakan Supabase
/// (atau bisa diganti mock untuk testing).
abstract interface class HomeRepository {
  /// Ambil semua data yang dibutuhkan home screen untuk [userId].
  ///
  /// Query internal:
  /// - `users` → nama & foto profil
  /// - `exercise_logs` 8 hari terakhir → metrik & tren
  /// - streak dikalkulasi dari tanggal `exercise_logs`
  Future<HomeData> getHomeData(int userId);
}
