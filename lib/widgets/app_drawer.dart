import '../helpers/custom_route.dart';
import '../screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello Friend'),
            //this makes it never add a back button
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            //remember to use pushreplacement in drawers
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            leading: Icon(Icons.shop),
            title: Text('Shop'),
          ),
          Divider(),
          ListTile(
            //remember to use pushreplacement in drawers
            onTap: () {
              Navigator.pushReplacementNamed(context, OrdersScreen.routeName);
              //for custom animation
              // Navigator.pushReplacement(
              //     context, CustomRoute(builder: (ctx) => OrdersScreen()));
            },
            leading: Icon(Icons.payment),
            title: Text('Orders'),
          ),
          Divider(),
          ListTile(
            //remember to use pushreplacement in drawers
            onTap: () => Navigator.pushReplacementNamed(
                context, UserProductsScreen.routeName),
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
          ),
          Divider(),
          ListTile(
            //remember to use pushreplacement in drawers
            onTap: () {
              Navigator.of(context).pop();
              // Navigator.pushNamedAndRemoveUntil(
              //     context, '/auth', (Route route) => false);
              // Navigator.of(context).pushAndRemoveUntil(
              //   MaterialPageRoute(
              //     builder: (BuildContext context) => AuthScreen(),
              //   ),
              //   (Route route) => false,
              // );
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
