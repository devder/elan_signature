import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'dart:io' show Platform;

class CartItemWidget extends StatelessWidget {
  final String id; //this is the key
  final String productId; // this is in the values object
  final String title;
  final int quantity;
  final double price;

  CartItemWidget(
      {this.quantity, this.price, this.title, this.id, this.productId});
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => Platform.isIOS
                ? CupertinoAlertDialog(
                    title: Text('Are you sure?'),
                    content:
                        Text('Do you want to remove the item from the cart?'),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            //this is the future that is being returned with true
                            //to confirm dismissal or false to quit
                            Navigator.of(ctx).pop(true);
                          },
                          child: Text('Yes')),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                          child: Text('No')),
                    ],
                  )
                : AlertDialog(
                    title: Text('Are you sure?'),
                    content:
                        Text('Do you want to remove the item from the cart?'),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            //this is the future that is being returned with true
                            //to confirm dismissal or false to quit
                            Navigator.of(ctx).pop(true);
                          },
                          child: Text('Yes')),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                          child: Text('No')),
                    ],
                  ));
      },
      onDismissed: (direction) =>
          Provider.of<CartProvider>(context, listen: false)
              .removeItem(productId),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: FittedBox(child: Text('\$$price')),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${price * quantity}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
