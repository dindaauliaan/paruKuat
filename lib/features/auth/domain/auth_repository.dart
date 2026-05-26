import 'auth_user.dart';

abstract interface class AuthRepository {
  Future<AppAuthUser> login({required String email, required String password});
  Future<AppAuthUser> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    DateTime? birthDate,
  });
  Future<void> logout();
  Future<AppAuthUser?> getActiveSession();

  /// Update fields profil user (email, phone, birthDate).
  Future<AppAuthUser> updateProfile({
    required int userId,
    String? email,
    String? phoneNumber,
    DateTime? birthDate,
  });

  /// Update profile picture URL user.
  Future<AppAuthUser> updateProfilePicture({
    required int userId,
    required String pictureUrl,
  });
}
