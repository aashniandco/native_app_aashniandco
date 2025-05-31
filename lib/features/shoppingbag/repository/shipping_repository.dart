import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShippingRepository {
  final IOClient ioClient;

  ShippingRepository()
      : ioClient = IOClient(
    HttpClient()..badCertificateCallback = (cert, host, port) => true,
  );


  Future<List<Map<String, dynamic>>> fetchCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }

    final url = Uri.parse('https://stage.aashniandco.com/rest/V1/directory/countries');

    final response = await ioClient.get(
      url,
      headers: {
        'Authorization': 'Bearer $customerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Country data raw response: ${response.body}');

      if (data is List) {
        // Each item in list: { "id": "IN", "full_name_english": "India", ... }
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Invalid country data");
      }
    } else {
      throw Exception("Failed to fetch countries: ${response.body}");
    }
  }


  Future<double?> estimateShipping(String countryId) async {
    final regionId = 0;
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }

    final shippingUrl =
        "https://stage.aashniandco.com/rest/V1/aashni/shipping-rate/$countryId/$regionId";

    final response = await ioClient.get(
      Uri.parse(shippingUrl),
      headers: {
        'Authorization': 'Bearer $customerToken',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data is List && data.length >= 2 && data[0] == true) {
      final price = data[1];
      return price != null ? price.toDouble() : null;
    } else {
      throw Exception("Failed to estimate shipping: ${response.body}");
    }
  }
}
