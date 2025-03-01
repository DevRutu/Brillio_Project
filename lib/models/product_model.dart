
class KidsProduct {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final double rating;
  final String buyLink;
  final List<String> benefits;

  KidsProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.rating,
    required this.buyLink,
    required this.benefits,
  });

  factory KidsProduct.fromFirestore(Map<String, dynamic> data, String id) {
    return KidsProduct(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      buyLink: data['buyLink'] ?? '',
      benefits: List<String>.from(data['benefits'] ?? []),
    );
  }
}