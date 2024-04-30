class Ingredient {
  final int id;
  final String name;
  final String category;
  final double? price; // Le prix peut être nul
  final String image;

  Ingredient({
    required this.id,
    required this.name,
    required this.category,
    this.price,
    required this.image,
  });

  // Factory method pour créer une instance d'Ingredient à partir du JSON
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      image: json['image'],
    );
  }
}