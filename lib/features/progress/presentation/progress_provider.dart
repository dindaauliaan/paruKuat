import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/progress_data.dart';
import '../domain/progress_repository.dart';
import '../data/supabase_progress_repository.dart';

// ====================================================================
// PROVIDERS
// ====================================================================

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return SupabaseProgressRepository(client: Supabase.instance.client);
});

/// FutureProvider.family — fetch [ProgressData] berdasarkan [userId].
final progressDataProvider = FutureProvider.family<ProgressData, int>((ref, userId) {
  final repository = ref.watch(progressRepositoryProvider);
  return repository.getProgressData(userId);
});
