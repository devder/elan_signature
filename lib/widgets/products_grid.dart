import 'package:elan_signature/models/product.dart';
import 'package:flutter/material.dart';
import '../widgets/product_item.dart';
import '../providers/products_provider.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavorites;
  ProductsGrid({this.showOnlyFavorites});
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);

    final products =
        showOnlyFavorites ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: products.length,
        //when putting a provider in a grid or list view builder
        //we need to be careful since some widgets are not actually built till
        //when we scroll there
        //in this case, using the changenotifierprovider.value is better
        //instead of creating a new context
        //change notifier provider automatically cleans up as per life cycle method
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              // create: (contx) => products[i],
              value: products[i],
              child: ProductItem(),
              // child: ProductItem(
              //   title: products[i].title,
              //   id: products[i].id,
              //   imageUrl: products[i].imageUrl,
              //   price: products[i].price,
              // ),
            ));
  }
}
