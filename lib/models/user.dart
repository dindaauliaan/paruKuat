class User {
  final int id;
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;
  final DateTime? birthDate;
  final bool? isPremium;
  final String? profilePicture;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.birthDate,
    this.isPremium,
    this.profilePicture,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'] ?? json['fullName'],
      email: json['email'],
      password: json['password'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : (json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null),
      isPremium: json['is_premium'] ?? json['isPremium'],
      profilePicture: json['profile_picture'] ?? json['profilePicture'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'birth_date': birthDate?.toIso8601String(),
      'is_premium': isPremium,
      'profile_picture': profilePicture,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
