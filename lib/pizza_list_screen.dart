import 'package:flutter/material.dart';
import 'package:pizza/authentification.dart';
import 'package:pizza/oder.dart';
import 'package:pizza/pizza_detail_screen.dart';
import 'package:pizza/pizza_ingredients_row.dart';
import 'package:provider/provider.dart';
import 'pizza.dart';
import 'api_service.dart';

class CartItem {
  final Pizza pizza;
  int quantity;

  CartItem({required this.pizza, this.quantity = 1});
}

class PizzaListScreen extends StatefulWidget {
  @override
  _PizzaListScreenState createState() => _PizzaListScreenState();
}

class _PizzaListScreenState extends State<PizzaListScreen> {
  late Future<List<Pizza>> futurePizzas;
  List<OrderLine> _cart = [];
  bool _showCartItems = false;

  @override
  void initState() {
    super.initState();
    futurePizzas = fetchPizzas();
  }

  @override
  Widget build(BuildContext context) {
    
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Pizza List"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              setState(() {
                _showCartItems = !_showCartItems;
              });
            },
          ),
          // Condition pour afficher soit le bouton "Exit to App" soit le bouton "Login"
          if (Provider.of<AuthService>(context).user != null) ...[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                authService.signOut();
              },
            ),
          ],
          if (Provider.of<AuthService>(context).user == null) ...[
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Pizza>>(
              future: futurePizzas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final pizzas = snapshot.data ?? [];
                final itemsToShow = _showCartItems ? _cart : pizzas;

                return ListView.builder(
                  itemCount: itemsToShow.length,
                  itemBuilder: (context, index) {
                    if (!_showCartItems) {
                      Pizza pizza = itemsToShow[index] as Pizza;
                      return ListTile(
                        title: Text(pizza.name),
                        subtitle: PizzaIngredientsRow(pizza: pizza),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("\$${pizza.price}"),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                _showQuantityModal(context, pizza);
                              },
                              child: Text("Add to Cart"),
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            "https://pizzas.shrp.dev/assets/${pizza.imageUrl}",
                          ),
                        ),
                        onTap: () {
                          _showPizzaDetailsModal(context, pizza);
                        },
                      );
                    } else {
                      OrderLine cartItem = itemsToShow[index] as OrderLine;
                      return ListTile(
                        title: Text(cartItem.pizza.name),
                        subtitle: Text(cartItem.pizza.ingredients.join(', ')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                _updateCartItemQuantity(
                                    cartItem, cartItem.quantity - 1);
                              },
                            ),
                            Text("${cartItem.quantity}"),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _updateCartItemQuantity(
                                    cartItem, cartItem.quantity + 1);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _showPizzaDetailsModal(context, cartItem.pizza);
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
          if (_showCartItems) // Button to view cart summary
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _showCartModal(context,authService.user as User),
                child: Text('Visualiser le panier'),
              ),
            ),
        ],
      ),
    );
  }

  void _showPizzaDetailsModal(BuildContext context, Pizza pizza) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PizzaDetailScreen(pizza: pizza);
      },
    );
  }

  void _showQuantityModal(BuildContext context, Pizza pizza) {
    int selectedQuantity = 1; // Valeur par défaut

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Quantity"),
          content: DropdownButton<int>(
            value: selectedQuantity,
            onChanged: (int? value) {
              if (value != null) {
                selectedQuantity = value;
              }
            },
            items: List.generate(10, (index) => index + 1)
                .map((quantity) => DropdownMenuItem<int>(
                      value: quantity,
                      child: Text("$quantity"),
                    ))
                .toList(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addToCart(pizza, selectedQuantity);
                Navigator.of(context).pop(); // Fermer la modale
              },
              child: Text("Add to Cart"),
            ),
          ],
        );
      },
    );
  }

  void _showCartModal(BuildContext context,User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cart Summary"),
          content: Container(
            // Encapsulate ListView in a Container with a fixed height
            height: 200, // Set a height that fits the modal dialog
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final cartItem = _cart[index];
                return ListTile(
                  title: Text(cartItem.pizza.name),
                  subtitle: Text("Quantity: ${cartItem.quantity}"),
                  trailing: Text(
                      "Total: \$${cartItem.pizza.price * cartItem.quantity}"),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                bool orderResult = await createOrder(_cart,user);
                if (orderResult) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Order successfully placed!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to place order."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Valider le panier"),
            )
          ],
        );
      },
    );
  }

  void _addToCart(Pizza pizza, int quantity) {
    setState(() {
      _cart.add(OrderLine(pizza: pizza, quantity: quantity));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pizza.name} added to cart'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _updateCartItemQuantity(OrderLine cartItem, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cart.remove(cartItem);
      } else {
        cartItem.quantity = quantity;
      }
    });
  }
}
