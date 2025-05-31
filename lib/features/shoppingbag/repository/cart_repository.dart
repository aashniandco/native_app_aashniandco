import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepository {
  final IOClient ioClient;

  CartRepository()
      : ioClient = IOClient(
    HttpClient()..badCertificateCallback = (cert, host, port) => true,
  );



  Future<List<dynamic>> fetchCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }

    final response = await ioClient.get(
      Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
    );


    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch cart items: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchTotal() async{
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }

    final response = await ioClient.get(
      Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/totals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
    );


    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch cart items: ${response.body}");
    }


  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final rawItems = await fetchCartItems();
    return rawItems.cast<Map<String, dynamic>>();
  }


  Future<bool> removeItem(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    final url = Uri.parse(
      'https://stage.aashniandco.com/rest/V1/solr/cart/item/delete?item_id=$itemId',
    );

    final response = await ioClient.post(
      url,
      headers: {
        'Authorization': 'Bearer $customerToken',
      },
    );

    final resData = jsonDecode(response.body);
    return resData is List && resData.isNotEmpty && resData[0] == true;
  }

  Future<int?> updateCartItemQty(int itemId, int qty) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    final uri = Uri.parse(
        "https://stage.aashniandco.com/rest/V1/solr/cart/item/updateQty?item_id=$itemId&qty=$qty");

    final response = await ioClient.post(
      uri,
      headers: {
        'Authorization': 'Bearer $customerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty && data[0] == true) {
        if (data.length > 2 && data[2] is Map && data[2]['qty'] != null) {
          final updatedQty = data[2]['qty'];
          return updatedQty is int ? updatedQty : int.tryParse(updatedQty.toString());
        }
        return qty;
      } else {
        throw Exception("Failed to update qty: ${data[1]}");
      }
    } else {
      throw Exception("HTTP error: ${response.statusCode}");
    }
  }
}

