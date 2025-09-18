class UserProfile {
  final String id;
  final String email;
  final String language;

  UserProfile({
    required this.id,
    required this.email,
    required this.language,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      language: json['language'] ?? 'English',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'language': language,
    };
  }
}
