import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/edit_product_screen.dart';
import 'providers/orders_provider.dart';
import 'screens/cart_screen.dart';
import 'providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'screens/product_detail.dart';
import 'screens/products_overview_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/user_products_screen.dart';
import 'screens/splash_screen.dart';
import 'providers/products_provider.dart';
import 'package:provider/provider.dart';
import 'helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //this changenotifierprovider is for the whole app where the whole app
    // to have access to the items they provide
    //there are several other provider(which are the actual listeners)
    //ie Consumer and Provider.of<>(context) which rebuild
    // for each product item that listens for change in
    // the favorite property of each products;
    //remember to use changnotifier.value in a grid/listview builder
    // return ChangeNotifierProvider(
    //   create: (context) => ProductsProvider(),
    //   child: Foo(),
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            create: (_) => ProductsProvider(),
            update: (_, auth, prevProductsData) =>
                prevProductsData..retrieveDetails(auth.token, auth.userId)),
        ChangeNotifierProxyProvider<Auth, OrdersProvider>(
            create: (_) => OrdersProvider(),
            update: (_, auth, prevOrdersData) =>
                prevOrdersData..retrieveDetails(auth.token, auth.userId)),
        ChangeNotifierProvider(create: (_) => CartProvider())
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'ElanSignature',
          theme: ThemeData(
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.amber,
            fontFamily: 'Lato',
            // pageTransitionsTheme: PageTransitionsTheme(builders: {
            //   TargetPlatform.iOS: CustomPageTransitionBuilder(),
            //   TargetPlatform.android: CustomPageTransitionBuilder()
            // })
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authSnapshot) =>
                      authSnapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            // '/productsOverview': (ctx) => ProductsOverviewScreen(),
            ProductDetail.routeName: (ctx) => ProductDetail(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen()
          },
        ),
      ),
    );
  }
}

// providers: [
// //auth should be first
// ChangeNotifierProvider(create: (_) => Auth()),
// ChangeNotifierProxyProvider<Auth, ProductsProvider>(
// create: null,
// update: (_, auth, prevProductsData) => ProductsProvider(
// auth.token,
// auth.userId,
// prevProductsData == null ? [] : prevProductsData.items)),
// //here, auth is providing to products provider
// ChangeNotifierProxyProvider<Auth, OrdersProvider>(
// create: null,
// update: (_, auth, prevOrders) => OrdersProvider(auth.token,
// auth.userId, prevOrders == null ? [] : prevOrders.orders)),
// ChangeNotifierProvider(create: (_) => CartProvider()),
// ],
// Consumer<Auth>(
// builder: (ctx, auth, __) => MaterialApp(
// title: 'ElanSignature',
// theme: ThemeData(
// primarySwatch: Colors.deepOrange,
// accentColor: Colors.amber,
// fontFamily: 'Lato',
// ),
// // home: AuthScreen(),
// home: auth.isAuth
// ? ProductsOverviewScreen()
//     : FutureBuilder(
// future: auth.tryAutoLogin(),
// builder: (ctx, authSnapshot) =>
// authSnapshot.connectionState == ConnectionState.waiting
// ? SplashScreen()
//     : AuthScreen(),
// ),
// routes: {
// // '/auth': (context) => AuthScreen(),
// '/productsOverview': (ctx) => ProductsOverviewScreen(),
// '/productDetail': (ctx) => ProductDetail(),
// '/cart': (ctx) => CartScreen(),
// '/orders': (ctx) => OrdersScreen(),
// '/userProducts': (ctx) => UserProductsScreen(),
// '/editProduct': (ctx) => EditProductScreen()
// },
// ),
// ),
