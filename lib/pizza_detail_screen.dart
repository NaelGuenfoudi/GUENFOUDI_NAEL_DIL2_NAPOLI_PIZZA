import 'package:flutter/material.dart';
import 'pizza.dart';

class PizzaDetailScreen extends StatelessWidget {
  final Pizza pizza;

  PizzaDetailScreen({required this.pizza});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          title: Text(pizza.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                'https://pizzas.shrp.dev/assets/${pizza.imageUrl}',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              Text("Price: \$${pizza.price}"),
              Text("Base: ${pizza.base}"),
              Text("Ingredients: ${pizza.ingredients.join(', ')}"),
              Text("Category: ${pizza.category}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
  }
}
