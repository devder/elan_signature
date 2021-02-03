import 'package:elan_signature/checks/lib/screens/product_detail_screen.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    //the consumer widget replaces this;
    //i can use the provider.of to get all the data then put listen to false
    //so that the entire widget doesn't rebuild. Then wrap the only place i need
    //to rebuild (which is the button)with the Consumer bc it always listens

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: GridTile(
        header: Container(
            padding: const EdgeInsets.all(3), child: Text(product.title)),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          subtitle: Text(product.price.toString()),
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border_outlined),
                // label: child
                color: Theme.of(context).accentColor,
                onPressed: () {
                  product.toggleFavorite(authData.token, authData.userId);
                }),
            // child: Text('Text does not change when rebuilt'),
            //here this child is a part of the widget that i want to rebuild but
            //the child will not rebuild bc it doesn not change
            //all these are for optimization
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              //this scaffold can do a lot of things as regards the layout
              //on the current page like opening the drawer
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'Added Item to Cart',
                    textAlign: TextAlign.center,
                  ),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  )));
            },
          ),
          backgroundColor: Colors.black87,
          // title: Text(
          //   title,
          //   textAlign: TextAlign.center,
          // ),
        ),
      ),
    );
  }
}
