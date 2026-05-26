import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/session_keys.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Nama bucket Supabase Storage yang sudah diaktifkan.
const _kAvatarBucket = 'avatars';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;
  final SharedPreferences _prefs;

  SupabaseAuthRepository({required SupabaseClient client, required SharedPreferences prefs})
      : _client = client,
        _prefs = prefs;

  @override
  Future<AppAuthUser> login({required String email, required String password}) async {
    final response = await _client
        .from('users')
        .select()
        .eq('email', email.trim().toLowerCase())
        .eq('password', password)
        .maybeSingle();

    if (response == null) throw Exception('Email atau kata sandi salah.');

    final user = _toAppAuthUser(response);
    await _saveSession(user);
    return user;
  }

  @override
  Future<AppAuthUser> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    DateTime? birthDate,
  }) async {
    final existing = await _client
        .from('users')
        .select('id')
        .eq('email', email.trim().toLowerCase())
        .maybeSingle();

    if (existing != null) throw Exception('Email sudah terdaftar. Silakan gunakan email lain.');

    final response = await _client
        .from('users')
        .insert({
          'full_name': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'phone_number': phoneNumber?.trim(),
          'birth_date': birthDate?.toIso8601String().split('T').first,
          'is_premium': false,
        })
        .select()
        .single();

    final user = _toAppAuthUser(response);
    await _saveSession(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(SessionKeys.userId);
    await _prefs.remove(SessionKeys.userName);
    await _prefs.remove(SessionKeys.userEmail);
  }

  @override
  Future<AppAuthUser?> getActiveSession() async {
    final userId = _prefs.getInt(SessionKeys.userId);
    if (userId == null || userId <= 0) return null;

    try {
      final response = await _client.from('users').select().eq('id', userId).maybeSingle();
      if (response == null) {
        await logout();
        return null;
      }
      return _toAppAuthUser(response);
    } catch (_) {
      // Offline fallback dari cache
      final cachedName = _prefs.getString(SessionKeys.userName);
      final cachedEmail = _prefs.getString(SessionKeys.userEmail);
      if (cachedName != null && cachedEmail != null) {
        return AppAuthUser(id: userId, fullName: cachedName, email: cachedEmail);
      }
      return null;
    }
  }

  @override
  Future<AppAuthUser> updateProfile({
    required int userId,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
  }) async {
    final updates = <String, dynamic>{};
    if (email != null) updates['email'] = email.trim().toLowerCase();
    if (phoneNumber != null) updates['phone_number'] = phoneNumber.trim();
    if (birthDate != null) {
      updates['birth_date'] = birthDate.toIso8601String().split('T').first;
    }

    if (updates.isEmpty) {
      // Tidak ada yang diubah, kembalikan data terkini
      final current = await _client.from('users').select().eq('id', userId).single();
      return _toAppAuthUser(current);
    }

    final response = await _client
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    final user = _toAppAuthUser(response);
    await _saveSession(user);
    return user;
  }

  @override
  Future<AppAuthUser> updateProfilePicture({
    required int userId,
    required String pictureUrl,
  }) async {
    final response = await _client
        .from('users')
        .update({'profile_picture': pictureUrl})
        .eq('id', userId)
        .select()
        .single();

    final user = _toAppAuthUser(response);
    await _saveSession(user);
    return user;
  }

  /// Upload file gambar ke Supabase Storage bucket [_kAvatarBucket],
  /// hapus foto lama jika ada, simpan public URL ke DB, dan kembalikan
  /// [AppAuthUser] terbaru.
  Future<AppAuthUser> uploadAndSaveProfilePicture({
    required int userId,
    required String currentPictureUrl, // URL lama, bisa kosong
    required File imageFile,
  }) async {
    // 1. Tentukan path di bucket: avatars/{userId}/avatar.{ext}
    final ext = imageFile.path.split('.').last.toLowerCase();
    final storagePath = '$userId/avatar.$ext';

    // 2. Hapus file lama di storage (opsional, ignore error jika tidak ada)
    if (currentPictureUrl.isNotEmpty) {
      try {
        // Ekstrak path dari URL: .../{bucket}/{path}
        final uri = Uri.parse(currentPictureUrl);
        final segments = uri.pathSegments;
        final bucketIdx = segments.indexOf(_kAvatarBucket);
        if (bucketIdx != -1 && bucketIdx < segments.length - 1) {
          final oldPath = segments.sublist(bucketIdx + 1).join('/');
          await _client.storage.from(_kAvatarBucket).remove([oldPath]);
        }
      } catch (_) {
        // Abaikan error hapus file lama
      }
    }

    // 3. Upload file baru (upsert=true agar overwrite jika path sama)
    await _client.storage.from(_kAvatarBucket).upload(
      storagePath,
      imageFile,
      fileOptions: const FileOptions(upsert: true),
    );

    // 4. Ambil public URL
    final publicUrl =
        _client.storage.from(_kAvatarBucket).getPublicUrl(storagePath);

    // 5. Simpan URL ke DB
    return updateProfilePicture(userId: userId, pictureUrl: publicUrl);
  }

  AppAuthUser _toAppAuthUser(Map<String, dynamic> json) {
    return AppAuthUser(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      profilePicture: json['profile_picture'] as String?,
    );
  }

  Future<void> _saveSession(AppAuthUser user) async {
    await _prefs.setInt(SessionKeys.userId, user.id);
    await _prefs.setString(SessionKeys.userName, user.fullName);
    await _prefs.setString(SessionKeys.userEmail, user.email);
  }
}
