import 'package:pizza/api_service.dart';
import 'package:pizza/ingredient.dart';

class Pizza {
  final String id;
  final String name;
  final int price;
  final String base;
  final List<dynamic> idIngredients;
  final List<Ingredient> ingredients;
  final String category;
  final String imageUrl;

  Pizza({
    required this.id,
    required this.name,
    required this.price,
    required this.base,
    required this.idIngredients,
    required this.ingredients,
    required this.category,
    required this.imageUrl,
  });

  factory Pizza.fromJson(Map<String, dynamic> json) {
    List<Ingredient> pizzaIngredients = [];
    // for (int ingredientId in List<int>.from(json['elements'])) {
    //   Ingredient? ingredient =  await fetchIngredientById(ingredientId) as Ingredient?;
    //   if (ingredient != null) {
    //     pizzaIngredients.add(ingredient);
    //   }
    // }

    return Pizza(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      base: json['base'],
      idIngredients: List<int>.from(json['elements']),
      ingredients: pizzaIngredients,
      category: json['category'],
      imageUrl: json['image'],
    );
  }
}
