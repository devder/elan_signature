import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../providers/orders_provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart'),
      ),
      body: Consumer<CartProvider>(
        builder: (_, cartData, __) => Column(
          children: [
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        '\$${cartData.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    OrderButton(cartData),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: cartData.items.length,
                  itemBuilder: (ctx, i) => CartItemWidget(
                        title: cartData.items.values.toList()[i].title,
                        productId: cartData.items.keys.toList()[i],
                        price: cartData.items.values.toList()[i].price,
                        id: cartData.items.values.toList()[i].id,
                        quantity: cartData.items.values.toList()[i].quantity,
                      )),
            ),
            if (cartData.items.isEmpty)
              Expanded(
                  flex: 2,
                  child: Text(
                    'Your cart is empty, add items',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ))
          ],
        ),
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final cartData;
  OrderButton(this.cartData);
  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cartData.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<OrdersProvider>(context, listen: false)
                  .addOrder(widget.cartData.items.values.toList(),
                      widget.cartData.totalAmount);
              setState(() {
                _isLoading = false;
              });
              widget.cartData.clearCart();
            },
      child: _isLoading
          ? Platform.isIOS
              ? CupertinoActivityIndicator()
              : CircularProgressIndicator()
          : Text('ORDER NOW'),
      textColor: Theme.of(context).primaryColor,
    );
  }
}
