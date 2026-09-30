class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime joinedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.joinedAt,
  });

  // Factory to create our default mock user
  factory UserModel.defaultUser() {
    return UserModel(
      id: 'usr_default_01',
      name: 'Default User',
      email: 'user@signko.com',
      joinedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(), // Backend returns int, convert to string
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'], // Snake case from backend
      joinedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
