import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/login_model.dart';
import '../model/magento_user.dart';

class LoginRepository {
  String baseUrl;

  LoginRepository({required this.baseUrl});

  Future<void> login(MagentoLoginRequest request) async {
    final url = Uri.parse('$baseUrl/rest/V1/integration/customer/token');
    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body) as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', token);

      // Fetch user info
      final user = await fetchUserDetails(token);
      if (user != null) {
        await prefs.setString('user_firstname', user.firstname);
        await prefs.setString('user_lastname', user.lastname);
        await prefs.setInt('user_customer_id', user.customer_id);
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? "Login failed");
    }
  }


  Future<MagentoUser?> fetchUserDetails(String token) async {

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final IOClient ioClient = IOClient(httpClient);

    final url = Uri.parse('$baseUrl/rest/V1/customers/me');

    final response = await ioClient.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MagentoUser.fromJson(data);
    } else {
      return null;
    }
  }

}

