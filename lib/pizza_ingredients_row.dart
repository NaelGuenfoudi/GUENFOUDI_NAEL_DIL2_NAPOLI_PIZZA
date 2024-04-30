import 'package:flutter/material.dart';
import 'package:pizza/pizza.dart'; // Assurez-vous d'importer la classe Pizza
import 'package:pizza/api_service.dart'; // Assurez-vous d'importer la classe Pizza

class PizzaIngredientsRow extends StatefulWidget {
  final Pizza pizza;

  PizzaIngredientsRow({required this.pizza});

  @override
  _PizzaIngredientsRowState createState() => _PizzaIngredientsRowState();
}

class _PizzaIngredientsRowState extends State<PizzaIngredientsRow> {
  Future<Pizza>? _loadedPizza;

  @override
  void initState() {
    super.initState();
    _loadedPizza = fetchIngredientsByPizza(widget.pizza); // Suppose this function is accessible and correctly fetches and updates the pizza ingredients
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pizza>(
      future: _loadedPizza,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _buildIngredients(snapshot.data!),
          );
        } else if (snapshot.hasError) {
          return Text('Erreur de chargement');
        }
        return CircularProgressIndicator(); // Afficher un indicateur de chargement pendant le chargement des données
      },
    );
  }

  List<Widget> _buildIngredients(Pizza pizza) {
    return pizza.ingredients.map((ingredient) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Image.network(
          "https://pizzas.shrp.dev/assets/${ingredient.image}",
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }).toList();
  }
}
