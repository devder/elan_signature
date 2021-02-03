import 'cart_item.dart';

class OrderItem {
  final String id;
  final List<CartItem> products;
  final double amount;
  final DateTime dateTime;

  OrderItem({this.dateTime, this.id, this.products, this.amount});
}
