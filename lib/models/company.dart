class Company {
  final String id;
  final String name;
  final bool isVerified;
  final String type;
  final String country;
  final String city;
  final String description;
  final double rating;
  final int reviewCount;
  final int offersCount;
  final String? phone;
  final String? email;
  final List<String> certifications;
  final int? yearEstablished;

  const Company({
    required this.id,
    required this.name,
    this.isVerified = false,
    required this.type,
    required this.country,
    required this.city,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.offersCount,
    this.phone,
    this.email,
    this.certifications = const [],
    this.yearEstablished,
  });

  String get location => '$country · $city';
}
