import 'package:elan_signature/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

//this is also a provider bc i wanna be able to change isfavorite per user

class Product with ChangeNotifier {
  final String id;
  final String description;
  final String title;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.imageUrl,
      @required this.description,
      @required this.price,
      this.isFavorite = false});

  Future<void> toggleFavorite(String authToken, String userId) async {
    final url =
        'https://elansignature-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    var existingStatus = isFavorite;
    try {
      isFavorite = !isFavorite;
      notifyListeners();
      //using put request here bc i wanna overwrite and not update
      final response = await http.put(url, body: jsonEncode(isFavorite));
      if (response.statusCode >= 400)
        throw HttpException('could not favorite item');
    } catch (e) {
      isFavorite = existingStatus;
      throw e;
    } finally {
      existingStatus = null;
      notifyListeners();
    }
  }
}
