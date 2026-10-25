class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final String phone;
  final String email;
  final String country;
  final String city;
  final String website;
  final String bio;
  final String role;
  final String? avatarBase64;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    this.phone = '',
    this.email = '',
    this.country = '',
    this.city = '',
    this.website = '',
    this.bio = '',
    this.role = 'مشتري',
    this.avatarBase64,
  });

  factory UserProfile.demo() => const UserProfile(
    id: 'demo',
    fullName: 'أحمد محمد',
    username: 'demo',
    phone: '',
    email: 'demo@souq.local',
    country: 'السعودية',
    city: 'الرياض',
    website: '',
    role: 'مشتري',
  );

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? country,
    String? city,
    String? website,
    String? bio,
    String? role,
    String? avatarBase64,
    bool clearAvatar = false,
  }) => UserProfile(
    id: id,
    fullName: fullName ?? this.fullName,
    username: username,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    country: country ?? this.country,
    city: city ?? this.city,
    website: website ?? this.website,
    bio: bio ?? this.bio,
    role: role ?? this.role,
    avatarBase64: clearAvatar ? null : (avatarBase64 ?? this.avatarBase64),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'fullName': fullName,
    'username': username,
    'phone': phone,
    'email': email,
    'country': country,
    'city': city,
    'website': website,
    'bio': bio,
    'role': role,
    'avatarBase64': avatarBase64,
  };

  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
    id: json['id']! as String,
    fullName: json['fullName']! as String,
    username: json['username']! as String,
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    country: json['country'] as String? ?? '',
    city: json['city'] as String? ?? '',
    website: json['website'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
    role: json['role'] as String? ?? 'مشتري',
    avatarBase64: json['avatarBase64'] as String?,
  );
}
