/// Entity domain untuk user yang sudah login.
/// Nama [AppAuthUser] digunakan untuk menghindari konflik dengan
/// supabase_flutter yang juga mengekspor class AuthUser.
class AppAuthUser {
  final int id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? profilePicture;

  const AppAuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.birthDate,
    this.profilePicture,
  });
}
