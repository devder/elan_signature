import 'package:elan_signature/checks/lib/screens/edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class UserProductItemWidget extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  UserProductItemWidget({this.title, this.imageUrl, this.id});
  @override
  Widget build(BuildContext context) {
    //i put it here bc of the try catch block and how flutter works
    //wrapping a context/scaffold inside a Future
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: FittedBox(
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.edit),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.pushNamed(context, EditProductScreen.routeName,
                      arguments: id);
                }),
            IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () async {
                  try {
                    await Provider.of<ProductsProvider>(context, listen: false)
                        .deleteProduct(id);
                  } catch (e) {
                    scaffold.showSnackBar(SnackBar(
                        content: Text(
                      "Deleting Failed",
                      textAlign: TextAlign.center,
                    )));
                  }
                }),
          ],
        ),
      ),
    );
  }
}
