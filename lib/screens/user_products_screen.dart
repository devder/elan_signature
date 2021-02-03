import '../widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/user_product_item_widget.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    //(true) bc of filtering from the provider file
    //listen must be false when using a future builder
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<ProductsProvider>(context);
    //commented this out bc of the future builder
    // when using the provider of, no need for the consumer
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  Navigator.pushNamed(context, EditProductScreen.routeName))
        ],
      ),
      body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (ctx, snapShot) => snapShot.connectionState ==
                  ConnectionState.waiting
              ? Center(
                  child: Platform.isIOS
                      ? CupertinoActivityIndicator()
                      : CircularProgressIndicator(),
                )
              : Consumer<ProductsProvider>(
                  builder: (_, productsData, __) => Platform.isIOS
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomScrollView(
                            slivers: [
                              CupertinoSliverRefreshControl(
                                onRefresh: () => _refreshProducts(context),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (ctx, i) => Column(
                                          children: [
                                            UserProductItemWidget(
                                              title:
                                                  productsData.items[i].title,
                                              imageUrl: productsData
                                                  .items[i].imageUrl,
                                              id: productsData.items[i].id,
                                            ),
                                            Divider()
                                          ],
                                        ),
                                    childCount: productsData.items.length),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _refreshProducts(context),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListView.builder(
                              itemCount: productsData.items.length,
                              itemBuilder: (ctx, i) => Column(
                                children: [
                                  UserProductItemWidget(
                                    title: productsData.items[i].title,
                                    imageUrl: productsData.items[i].imageUrl,
                                    id: productsData.items[i].id,
                                  ),
                                  Divider()
                                ],
                              ),
                            ),
                          ),
                        ))),
    );
  }
}
