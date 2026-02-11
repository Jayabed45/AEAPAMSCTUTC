class UserModel {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String username;
  final String profileImageUrl;
  final bool isVerified;
  final String role;
  final String organization;

  UserModel({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.username,
    required this.profileImageUrl,
    this.isVerified = false,
    required this.role,
    required this.organization,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? 'https://i.pravatar.cc/300',
      isVerified: json['is_verified'] ?? false,
      role: json['role'] ?? 'User',
      organization: json['organization'] ?? 'AEAPAMSCTUTC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'username': username,
      'profile_image_url': profileImageUrl,
      'is_verified': isVerified,
      'role': role,
      'organization': organization,
    };
  }
}
