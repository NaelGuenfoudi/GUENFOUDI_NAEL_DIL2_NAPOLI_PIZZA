import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pizza/authentification.dart';
import 'package:pizza/oder.dart';
import 'pizza.dart';
import 'ingredient.dart';

Future<List<Pizza>> fetchPizzas() async {
  try {
    // Faites une requête HTTP pour récupérer les données JSON
    Response response = await Dio().get('https://pizzas.shrp.dev/items/pizzas');

    // Vérifiez si la requête a réussi (statut 200)
    if (response.statusCode == 200) {
      // Décodez les données JSON en une liste dynamique de maps JSON
      List<dynamic> pizzaJsonList = response.data['data'];
      print("kekeke");
      // Mappez chaque map JSON en instance de Pizza en utilisant la méthode fromJson
      List<Pizza> pizzas =
          pizzaJsonList.map((json) => Pizza.fromJson(json)).toList();
      //boucler sur la liste pizzas, et fetcher avec fettchIngredientByName tous les ingredients en fonction de leurs noms ,
      // Retournez la liste des pizzas
      return pizzas;
    } else {
      // Si la requête a échoué, lancez une exception avec un message d'erreur
      throw Exception('Failed to load pizzas');
    }
  } catch (e) {
    // Si une erreur se produit pendant le traitement de la requête, lancez une exception avec l'erreur d'origine
    throw Exception('Error fetching pizzas: $e');
  }
}

Future<List<Pizza>> fetchPizzasWithIngredients() async {
  try {
    List<Pizza> pizzas = await fetchPizzas(); // Récupérez toutes les pizzas
    List<Pizza> pizzasWithIngredients = [];
    for (Pizza pizza in pizzas) {
      // Fetch the ingredients for each pizza
      pizzasWithIngredients.add(await fetchIngredientsByPizza(pizza));
    }
    return pizzasWithIngredients;
  } catch (e) {
    throw Exception('Error fetching pizzas with ingredients: $e');
  }
}



Future<Pizza> fetchIngredientsByPizza(Pizza pizza) async {
  List<Ingredient?> fetchedIngredients = await Future.wait(
    pizza.idIngredients.map((id) => fetchIngredientById(id))
  );

  List<Ingredient> nonNullIngredients = fetchedIngredients.whereType<Ingredient>().toList();

  return Pizza(
    id: pizza.id,
    name: pizza.name,
    price: pizza.price,
    base: pizza.base,
    idIngredients: pizza.idIngredients,
    ingredients: nonNullIngredients,
    category: pizza.category,
    imageUrl: pizza.imageUrl,
  );
}


Future<Ingredient?> fetchIngredientById(idIngredient) async {
  try {
    Response response = await Dio()
        .get("https://pizzas.shrp.devitems/ingredients/$idIngredient");
    Ingredient? ingredient;
    if (response.statusCode == 200) {
      ingredient = Ingredient.fromJson(response.data['data']);
    }

    return ingredient;
  } catch (e) {
    // Si une erreur se produit pendant le traitement, lancez une exception avec l'erreur d'origine
    throw Exception('Error fetching ingredient by name $idIngredient: $e');
  }
}

Future<bool> createOrder(List<OrderLine> orderLines, User user) async {
  // API Endpoint
  const String url = 'https://pizzas.shrp.dev/items/orders';

  // Transform orderLines to JSON
  List<Map<String, dynamic>> jsonOrderLines = orderLines.map((orderLine) {
    return {
      'pizza_id': orderLine.pizza.id,
      'quantity': orderLine.quantity
    };
  }).toList();

  // Prepare the payload
  Map<String, dynamic> payload = {'orderlines': jsonOrderLines};

  try {
    // Make a POST request with Dio
    Response response = await Dio().post(
      url,
      data: json.encode(payload),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}', // Include the token in the Authorization header
        },
        validateStatus: (status) { return status! < 500; } // Accept any status less than 500
      )
    );

    // Check if the status code is 200
    return response.statusCode == 200;
  } catch (e) {
    // Log or handle the error as needed
    print('Failed to create order: $e');
    return false;
  }
}
