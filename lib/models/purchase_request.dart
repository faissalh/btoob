class PurchaseRequest {
  final String id;
  final String title;
  final String status;
  final String buyerName;
  final String contactPerson;
  final String quantity;
  final String budget;
  final String country;
  final String city;
  final String? description;
  final String? deadline;
  final String? category;
  final String? ownerId;
  final List<String> imageBase64;

  const PurchaseRequest({
    required this.id,
    required this.title,
    required this.status,
    required this.buyerName,
    required this.contactPerson,
    required this.quantity,
    required this.budget,
    required this.country,
    required this.city,
    this.description,
    this.deadline,
    this.category,
    this.ownerId,
    this.imageBase64 = const [],
  });

  String get location => '$country · $city';

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'status': status,
    'buyerName': buyerName,
    'contactPerson': contactPerson,
    'quantity': quantity,
    'budget': budget,
    'country': country,
    'city': city,
    'description': description,
    'deadline': deadline,
    'category': category,
    'ownerId': ownerId,
    'imageBase64': imageBase64,
  };

  factory PurchaseRequest.fromJson(Map<String, Object?> json) =>
      PurchaseRequest(
        id: json['id']! as String,
        title: json['title']! as String,
        status: json['status']! as String,
        buyerName: json['buyerName']! as String,
        contactPerson: json['contactPerson']! as String,
        quantity: json['quantity']! as String,
        budget: json['budget']! as String,
        country: json['country']! as String,
        city: json['city']! as String,
        description: json['description'] as String?,
        deadline: json['deadline'] as String?,
        category: json['category'] as String?,
        ownerId: json['ownerId'] as String?,
        imageBase64: (json['imageBase64'] as List?)?.cast<String>() ?? const [],
      );
}
