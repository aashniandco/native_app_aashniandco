import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepository {
  final IOClient ioClient;

  CartRepository()
      : ioClient = IOClient(
    HttpClient()..badCertificateCallback = (cert, host, port) => true,
  );


  Future<void> setCustomShippingPrice(double shippingPrice) async {
    if (kDebugMode) {
      print("--- ShippingRepository: Calling CUSTOM API to set shipping price: $shippingPrice ---");
    }

    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in for setting custom shipping price");
    }

    // This is the NEW custom API URL you defined in webapi.xml
    final url = Uri.parse('https://stage.aashniandco.com/rest/V1/aashni/carts/mine/set-shipping-price');

    final response = await this.ioClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
      // The body just contains the price
      body: json.encode({"shippingPrice": shippingPrice}),
    );

    if (kDebugMode) {
      print("Custom API Response Status: ${response.statusCode}");
      print("Custom API Response Body: ${response.body}");
    }

    if (response.statusCode != 200) {
      // It failed, throw an exception
      final errorBody = json.decode(response.body);
      throw Exception("Failed to set custom shipping price: ${errorBody['message']}");
    }
  }

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
      print("cart body: ${response.body}");
      return json.decode(response.body);

    }

    else {
      throw Exception("Failed to fetch cart items: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchTotal() async {
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
      final data = json.decode(response.body);
      print("Total cart weight: ${data['weight']}");
      return data;
    } else {
      throw Exception("Failed to fetch cart total: ${response.body}");
    }
  }


  Future<List<Map<String, dynamic>>> getCartItems() async {
    final rawItems = await fetchCartItems();
    return rawItems.cast<Map<String, dynamic>>();
  }


  Future<double> fetchCartTotalWeight(int customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }

    final response = await ioClient.get(
      Uri.parse('https://stage.aashniandco.com/rest/V1/cart/details/$customerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      if (data.isEmpty) {
        return 0.0;
      }
      final firstItem = data[0] as Map<String, dynamic>;
      final weightStr = firstItem['total_cart_weight'];
      final totalWeight = double.tryParse(weightStr.toString()) ?? 0.0;
      return totalWeight;
    } else {
      throw Exception("Failed to fetch cart total weight: ${response.body}");
    }
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

