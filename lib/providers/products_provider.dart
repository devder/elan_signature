import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  String authToken;
  String userId;
  // ProductsProvider(this.authToken, this.userId, this._items);
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
  ];

  void retrieveDetails(String tokeN, String userId1) {
    authToken = tokeN;
    userId = userId1;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final baseUrl = 'https://elansignature-default-rtdb.firebaseio.com';
    final filterUrl =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    //this is a filter mechanism done on the server side
    //after doing this, go to the server and set the rules on firebase
    var url = '$baseUrl/products.json?auth=$authToken&$filterUrl';
    try {
      final response = await http.get(url);
      final Map<String, dynamic> extractedData = jsonDecode(response.body);
      if (extractedData == null) {
        return;
      }
      url = '$baseUrl/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            imageUrl: prodData['imageUrl'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  // Future<void> addProduct(Product product) {
  //   //rem to always always return sth from a future if u wanna see/use it
  //   //the .json is required in firebase
  //   const url =
  //       'https://elansignature-default-rtdb.firebaseio.com/products.json';
  //   return http
  //       .post(url,
  //           body: jsonEncode({
  //             'title': product.title,
  //             'imageUrl': product.imageUrl,
  //             'description': product.description,
  //             'price': product.price,
  //             'isFavorite': product.isFavorite
  //           }))
  //       .then((response) {
  //     final newProduct = Product(
  //         id: jsonDecode(response.body)['name'],
  //         title: product.title,
  //         imageUrl: product.imageUrl,
  //         description: product.description,
  //         price: product.price);
  //     _items.add(newProduct);
  //     notifyListeners();
  //   }).catchError((error) => throw error);
  //   //the error is put at the end here so that it can catch error from the two
  // }

  Future<void> addProduct(Product product) async {
    //await automatically does the returning when used
    //the .json is required in firebase
    final url =
        'https://elansignature-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      //a new product on the server should not have a fav status
      final response = await http.post(url,
          body: jsonEncode({
            'title': product.title,
            'imageUrl': product.imageUrl,
            'description': product.description,
            'price': product.price,
            'creatorId': userId
          }));
      final newProduct = Product(
          id: jsonDecode(response.body)['name'],
          title: product.title,
          imageUrl: product.imageUrl,
          description: product.description,
          price: product.price);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String prodId, Product product) async {
    final prodIdx = _items.indexWhere((prod) => prod.id == prodId);
    if (prodIdx >= 0) {
      try {
        final url =
            'https://elansignature-default-rtdb.firebaseio.com/products/$prodId.json?auth=$authToken';
        await http.patch(url,
            body: jsonEncode({
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price
            }));
        _items[prodIdx] = product;
        notifyListeners();
      } catch (e) {
        throw e;
      }
    }
  }

  Future<void> deleteProduct(String prodId) async {
    //utilizing optimistic updating
    final url =
        'https://elansignature-default-rtdb.firebaseio.com/products/$prodId.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == prodId);
    var existingProduct = _items[existingProductIndex];
    try {
      _items.removeAt(existingProductIndex);
      notifyListeners();
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product');
      }
    } catch (e) {
      _items.insert(existingProductIndex, existingProduct);
      throw e;
    } finally {
      existingProduct = null;
      notifyListeners();
    }
  }
}
