import 'package:flutter/foundation.dart';
import 'pizza.dart';

class Order {
  final double amount;
  final DateTime dateCreated;
  final String userId;
  final List<OrderLine> orderLines;

  Order({
    required this.amount,
    required this.dateCreated,
    required this.userId,
    required this.orderLines,
  });
}

class OrderLine {
  final Pizza pizza;
   int quantity;

  OrderLine({
    required this.pizza,
    required this.quantity,
  });
}
