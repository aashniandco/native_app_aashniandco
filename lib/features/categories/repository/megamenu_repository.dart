import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/megamenu_model.dart';
import 'package:http/io_client.dart';

class MegamenuRepository {
  final String baseUrl = 'https://stage.aashniandco.com/rest/V1/solr/megamenu';


  Future<MegamenuModel> fetchMegamenu() async {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);
    final response = await ioClient .get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return MegamenuModel.fromJson(decoded);
    } else {
      throw Exception('Failed to load megamenu');
    }
  }
}
