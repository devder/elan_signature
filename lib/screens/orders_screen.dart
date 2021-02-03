import 'package:flutter/material.dart';
import '../providers/orders_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/order_item_widget.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter/cupertino.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  // @override
  // void initState() {
  //no init state n stateless widget
  //   // Future.delayed(Duration.zero).then((_) async {
  //   //   setState(() => _isLoading = true);
  //   //   await Provider.of<OrdersProvider>(context, listen: false)
  //   //       .fetchAndSetOrders();
  //   //   setState(() => _isLoading = false);
  //   // });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: Provider.of<OrdersProvider>(context, listen: false)
              .fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                return Center(
                    child: Text('..could not fetch orders at the moment'));
              } else {
                return Consumer<OrdersProvider>(
                  builder: (ctx, orderData, __) => orderData.orders.isEmpty
                      ? Center(
                          child: Text(
                            'You have not placed any others yet',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          itemCount: orderData.orders.length,
                          itemBuilder: (ctx, i) =>
                              OrderItemWidget(orderData.orders[i])),
                );
              }
            }
          },
        ));
  }
}
// with the FutureBuilder i wont need to use a stateful widget and i should
//  set up a listener but use a consumer just where i need data to change
// body: _isLoading
// ? Center(child: CircularProgressIndicator())
// : ListView.builder(
// itemCount: orderData.orders.length,
// itemBuilder: (ctx, i) => OrderItemWidget(orderData.orders[i])),
