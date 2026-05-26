import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

// ====================================================================
// AUTH STATE — sealed classes
// ====================================================================
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AppAuthUser user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ====================================================================
// PROVIDERS
// ====================================================================
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider harus di-override di main');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SupabaseAuthRepository(
    client: Supabase.instance.client,
    prefs: prefs,
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// ====================================================================
// AUTH NOTIFIER
// ====================================================================
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthInitial()) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = const AuthLoading();
    try {
      final user = await _repository.getActiveSession();
      state = user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthAuthenticated(user);
    } on Exception catch (e) {
      state = AuthError(_parseError(e));
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    DateTime? birthDate,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
      );
      state = AuthAuthenticated(user);
    } on Exception catch (e) {
      state = AuthError(_parseError(e));
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _repository.logout();
      state = const AuthUnauthenticated();
    } on Exception catch (e) {
      state = AuthError(_parseError(e));
    }
  }

  /// Update email, phone, atau birth date user.
  /// Mengembalikan [true] jika berhasil.
  Future<bool> updateProfile({
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
  }) async {
    final current = state;
    if (current is! AuthAuthenticated) return false;

    try {
      final updated = await _repository.updateProfile(
        userId: current.user.id,
        email: email,
        phoneNumber: phoneNumber,
        birthDate: birthDate,
      );
      state = AuthAuthenticated(updated);
      return true;
    } on Exception catch (e) {
      // Jangan reset ke error agar UI tetap bisa menampilkan data lama
      throw Exception(_parseError(e));
    }
  }

  /// Upload file gambar ke Supabase Storage, simpan public URL ke DB.
  /// Mengembalikan [true] jika berhasil.
  Future<bool> uploadAndSaveProfilePicture({required File imageFile}) async {
    final current = state;
    if (current is! AuthAuthenticated) return false;

    final repo = _repository;
    if (repo is! SupabaseAuthRepository) {
      throw Exception('Repository tidak mendukung upload storage.');
    }

    try {
      final updated = await repo.uploadAndSaveProfilePicture(
        userId: current.user.id,
        currentPictureUrl: current.user.profilePicture ?? '',
        imageFile: imageFile,
      );
      state = AuthAuthenticated(updated);
      return true;
    } on Exception catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// Update profile picture dari URL (dipakai jika URL sudah tersedia).
  /// Mengembalikan [true] jika berhasil.
  Future<bool> updateProfilePicture({required String pictureUrl}) async {
    final current = state;
    if (current is! AuthAuthenticated) return false;

    try {
      final updated = await _repository.updateProfilePicture(
        userId: current.user.id,
        pictureUrl: pictureUrl,
      );
      state = AuthAuthenticated(updated);
      return true;
    } on Exception catch (e) {
      throw Exception(_parseError(e));
    }
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }

  String _parseError(Exception e) {
    final raw = e.toString();
    if (raw.startsWith('Exception: ')) return raw.replaceFirst('Exception: ', '');
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
