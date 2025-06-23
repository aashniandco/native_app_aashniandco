import 'dart:convert';
import 'dart:io';
import '../bloc/order_details_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import '../model/order_details_model.dart';


class OrderRepository {
  // TODO: Replace with your actual Magento URL
  static const String _baseUrl = 'https://stage.aashniandco.com/rest';

  Future<String?> _getCustomerToken() async {
    final prefs = await SharedPreferences.getInstance();
    // TODO: Make sure the key 'customer_token' matches what you use after login
    return prefs.getString('user_token');
  }

  Future<OrderDetails> fetchOrderDetails(int orderId) async {
    final token = await _getCustomerToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final url = Uri.parse('$_baseUrl/V1/aashni/order-details/$orderId');
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);
    final response = await ioClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OrderDetails.fromJson(data);
    } else {
      // Decode the error message from Magento for better feedback
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Failed to load order details.';
      throw Exception(errorMessage);
    }
  }
}