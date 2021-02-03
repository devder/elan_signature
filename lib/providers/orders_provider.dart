import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/order_item.dart';
import '../models/cart_item.dart';
import 'package:http/http.dart' as http;

class OrdersProvider with ChangeNotifier {
  String authToken; //was final before
  String userId;
  List<OrderItem> _orders = [];
  // OrdersProvider(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders => [..._orders];

  void retrieveDetails(String tokeN, String userId1) {
    authToken = tokeN;
    userId = userId1;
  }

  Future<void> addOrder(List<CartItem> cartItems, double total) async {
    final url =
        'https://elansignature-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartItems
                .map((item) => {
                      'id': item.id,
                      'title': item.title,
                      'quantity': item.quantity,
                      'price': item.price
                    })
                .toList()
          }));
      _orders.insert(
        0,
        OrderItem(
            id: jsonDecode(response.body)['name'],
            amount: total,
            dateTime: timeStamp,
            products: cartItems),
      );
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://elansignature-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final List<OrderItem> loadedOrders = [];
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  title: item['title'],
                  quantity: item['quantity']))
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
