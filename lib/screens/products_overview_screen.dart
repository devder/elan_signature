import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import 'package:flutter/material.dart';
import '../widgets/products_grid.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../screens/cart_screen.dart';
import 'dart:io' show Platform;
import 'package:badges/badges.dart';
import '../widgets/app_drawer.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // Provider.of<ProductsProvider>(context).fetchAndSetProducts();
    //above won't work here except i set listen to false bc of context in init
    //beneath will work tho, this method works on any function that needs ctx
    // Future.delayed(Duration.zero).then((_) =>
    //     Provider.of<ProductsProvider>(context, listen: false)
    //         .fetchAndSetProducts());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //i can use a future builder instead of this approach and convert this to
    //  a stateless widget then use consumer instead
    //but the down side of that too is that if sth in the build method should
    //re run a new future will be made again which is wrong

    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elan Signature'),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cartData, badgeChild) => Badge(
              badgeContent: Text('${cartData.itemCount}'),
              child: badgeChild,
              position: BadgePosition(top: 0, end: 0),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () =>
                  Navigator.pushNamed(context, CartScreen.routeName),
            ),
          ),
          PopupMenuButton(
              onSelected: (selectedValue) {
                setState(() {
                  if (selectedValue == FilterOptions.Favorites) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    PopupMenuItem(
                        child: Text('Only Favorites'),
                        value: FilterOptions.Favorites),
                    PopupMenuItem(
                        child: Text('Show All'), value: FilterOptions.All)
                  ])
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(
              showOnlyFavorites: _showOnlyFavorites,
            ),
    );
  }
}

// _isLoading
// ? Center(
// child: Platform.isIOS
// ? CupertinoActivityIndicator()
//     : CircularProgressIndicator(),
// )
// : ProductsGrid(
// showOnlyFavorites: _showOnlyFavorites,
// ),
