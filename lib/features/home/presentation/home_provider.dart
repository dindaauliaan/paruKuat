import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase_home_repository.dart';
import '../domain/home_data.dart';
import '../domain/home_repository.dart';

// ====================================================================
// PROVIDERS
// ====================================================================

/// Repository instance — bisa di-override untuk testing.
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return SupabaseHomeRepository(client: Supabase.instance.client);
});

/// FutureProvider.family — fetch HomeData berdasarkan [userId].
///
/// Keuntungan:
/// - `AsyncValue` sudah handle loading / error / data
/// - `family` otomatis refresh jika userId berubah (misal logout → login beda user)
/// - Tidak perlu StateNotifier manual untuk kasus simple load
final homeDataProvider = FutureProvider.family.autoDispose<HomeData, int>((ref, userId) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getHomeData(userId);
});
