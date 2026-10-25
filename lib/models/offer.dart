class Offer {
  final String id;
  final String title;
  final String type;
  final String price;
  final String? minOrder;
  final String category;
  final List<String> countries;
  final String companyName;
  final bool isVerified;
  final double rating;
  final String? description;
  final String? details;
  final List<String> features;
  final int colorIndex;
  final String? ownerId;
  final List<String> imageBase64;

  const Offer({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    this.minOrder,
    required this.category,
    required this.countries,
    required this.companyName,
    this.isVerified = false,
    required this.rating,
    this.description,
    this.details,
    this.features = const [],
    this.colorIndex = 0,
    this.ownerId,
    this.imageBase64 = const [],
  });

  String get countriesText => countries.join('، ');

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'price': price,
    'minOrder': minOrder,
    'category': category,
    'countries': countries,
    'companyName': companyName,
    'isVerified': isVerified,
    'rating': rating,
    'description': description,
    'details': details,
    'features': features,
    'colorIndex': colorIndex,
    'ownerId': ownerId,
    'imageBase64': imageBase64,
  };

  factory Offer.fromJson(Map<String, Object?> json) => Offer(
    id: json['id']! as String,
    title: json['title']! as String,
    type: json['type']! as String,
    price: json['price']! as String,
    minOrder: json['minOrder'] as String?,
    category: json['category']! as String,
    countries: (json['countries']! as List).cast<String>(),
    companyName: json['companyName']! as String,
    isVerified: json['isVerified'] as bool? ?? false,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    description: json['description'] as String?,
    details: json['details'] as String?,
    features: (json['features'] as List?)?.cast<String>() ?? const [],
    colorIndex: json['colorIndex'] as int? ?? 0,
    ownerId: json['ownerId'] as String?,
    imageBase64: (json['imageBase64'] as List?)?.cast<String>() ?? const [],
  );
}
