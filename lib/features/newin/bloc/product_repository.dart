import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../constants/api_constants.dart';
import '../model/new_in_model.dart';
import 'package:http/io_client.dart';

// class ProductRepository {
//   Future<List<Product>> fetchProductsBySubcategory(String subcategory) async {
//     final url = ApiConstants.subcategoryApiMap[subcategory];
//     print('🔗 API Called for "$subcategory": $url');
//
//
//     if (url == null) {
//       throw Exception("API URL not found for subcategory: $subcategory");
//     }
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final items = List<Map<String, dynamic>>.from(data['response']['docs']);
//       return items.map((item) => Product.fromJson(item)).toList();
//     } else {
//       throw Exception('Failed to fetch data');
//     }
//   }
// }

/////imp

class ProductRepository {



  // Future<List<Product>> fetchProductsByGenders(List<String> genders) async {
  //   const String url = "https://stage.aashniandco.com/rest/V1/solr/search";
  //
  //   try {
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     final genderQuery = genders.map((g) => '"$g"').join(" OR ");
  //
  //     final Map<String, dynamic> body = {
  //       "queryParams": {
  //         "query": 'gender_name:($genderQuery)',
  //         "params": {
  //           "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,gender_name",
  //           "rows": "100"
  //         }
  //       }
  //     };
  //
  //     final response = await ioClient.post(
  //       Uri.parse(url),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //       print('API Response: $decoded');  // Log the entire response to see the structure
  //
  //       final docs = decoded['response']?['docs'];
  //       if (docs is List) {
  //         return docs.map((doc) => Product.fromJson(doc)).toList();
  //       } else {
  //         throw Exception("Invalid docs format");
  //       }
  //     } else {
  //       throw Exception("Failed with status: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ Error fetching gender products: $e");
  //     return [];
  //   }
  // }
  Future<List<Product>> fetchProductsByGenders(List<String> genders) async {
    // const String url = "https://stage.aashniandco.com/rest/V1/solr/search";
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;

      IOClient ioClient = IOClient(httpClient);

      final genderQuery = genders.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'gender_name:($genderQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,color_name",
            "rows": "10000",
            "wt": "json"
          }
        }
      };

      final response = await ioClient.post(
       uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('API Response: $decoded');

        if (decoded is List && decoded.length > 1) {
          final secondItem = decoded[1];
          final docs = secondItem['docs'];

          if (docs is List) {
            return docs.map((doc) => Product.fromJson(doc)).toList();
          } else {
            throw Exception("Invalid docs format");
          }
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching gender products: $e");
      return []; // 🛡️ Always return a fallback
    }
  }

  Future<List<Product>> fetchProductsByThemes(List<String> themes) async {
    // const String url = "https://stage.aashniandco.com/rest/V1/solr/search";
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;

      IOClient ioClient = IOClient(httpClient);

      final themesQuery = themes.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'theme_name:($themesQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,color_name",
            "rows": "10000",
            "wt": "json"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('API Response themes: $decoded');

        if (decoded is List && decoded.length > 1) {
          final secondItem = decoded[1];
          final docs = secondItem['docs'];

          if (docs is List) {
            return docs.map((doc) => Product.fromJson(doc)).toList();
          } else {
            throw Exception("Invalid docs format");
          }
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching gender products: $e");
      return []; // 🛡️ Always return a fallback
    }
  }


  Future<List<Product>> fetchProductsByColors(List<String> colors) async {
    // const String url = "https://stage.aashniandco.com/rest/V1/solr/search";
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;

      IOClient ioClient = IOClient(httpClient);

      final colorsQuery = colors.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'color_name:($colorsQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,color_name",
            "rows": "10000",
            "wt": "json"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('API Response colors: $decoded');

        if (decoded is List && decoded.length > 1) {
          final secondItem = decoded[1];
          final docs = secondItem['docs'];

          if (docs is List) {
            return docs.map((doc) => Product.fromJson(doc)).toList();
          } else {
            throw Exception("Invalid docs format");
          }
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching color products: $e");
      return []; // 🛡️ Always return a fallback
    }
  }

  Future<List<Product>> fetchProductsBySize(List<String> sizes) async {
    // const String url = "https://stage.aashniandco.com/rest/V1/solr/search";
    final uri = Uri.parse(ApiConstants.url);
    print('🔗 Request URL: $uri');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;

      IOClient ioClient = IOClient(httpClient);

      final sizesQuery = sizes.map((g) => '"$g"').join(" OR ");

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'size_name:($sizesQuery)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,size_name",
            "rows": "10000",
            "wt": "json"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('API Response Size : $decoded');

        if (decoded is List && decoded.length > 1) {
          final secondItem = decoded[1];
          final docs = secondItem['docs'];

          if (docs is List) {
            return docs.map((doc) => Product.fromJson(doc)).toList();
          } else {
            throw Exception("Invalid docs format");
          }
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching color products: $e");
      return []; // 🛡️ Always return a fallback
    }
  }


  Future<List<Product>> fetchProductsForMultipleSubcategories(List<String> subcategories) async {
    List<Product> allProducts = [];

    for (String subcategory in subcategories) {
      try {
        final products = await fetchProductsBySubcategory(subcategory);
        allProducts.addAll(products);
      } catch (e) {
        print("⚠️ Failed to fetch for $subcategory: $e");
        // Continue fetching others even if one fails
      }
    }

    return allProducts;
  }

  Future<List<Product>> fetchProductsBySubcategory(String subcategory) async {
    // Await the URL fetching, since it’s asynchronous
    final url = await ApiConstants.getApiUrlForSubcategory(subcategory.toLowerCase());
    print("📦 Fetching from: $url");

    // Ensure the URL is not empty
    if (url.isEmpty) {
      throw Exception("API URL is empty for subcategory: $subcategory");
    }

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      final response = await ioClient.get(Uri.parse(url));
      print("📡 Status Code: ${response.statusCode}");
      print("📨 Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic rawJson = json.decode(response.body);

        if (rawJson is List && rawJson.length > 1) {
          final secondObject = rawJson[1] as Map<String, dynamic>;

          final solrResponse = SolrProductResponse.fromJson({'response': secondObject});
          print("✅ Parsed ${solrResponse.products.length} products");

          for (var p in solrResponse.products) {
            print("🧵 ${p.designerName} - ₹${p.actualPrice} - ${p.shortDesc}");
          }

          return solrResponse.products;
        } else {
          print("⚠️ Unexpected format: $rawJson");
          throw Exception("Unexpected response format from API");
        }
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to load products from API");
      }
    } catch (e, stackTrace) {
      print("🔥 Exception occurred: $e");
      print("📍 StackTrace: $stackTrace");
      throw Exception("Error fetching products: $e");
    }
  }
}
// class ProductRepository {
//
//   Future<List<Product>> fetchProductsForMultipleSubcategories(List<String> subcategories) async {
//     List<Product> allProducts = [];
//
//     for (String subcategory in subcategories) {
//       try {
//         final products = await fetchProductsBySubcategory(subcategory);
//         allProducts.addAll(products);
//       } catch (e) {
//         print("⚠️ Failed to fetch for $subcategory: $e");
//         // Continue fetching others even if one fails
//       }
//     }
//
//     return allProducts;
//   }
//
//
//   Future<List<Product>> fetchProductsBySubcategory(String subcategory) async {
//     final url = ApiConstants.getApiUrlForSubcategory(subcategory.toLowerCase());
//     print("📦 Fetching from: $url");
//
//     if (url.isEmpty) {
//       throw Exception("API URL is empty for subcategory: $subcategory");
//     }
//
//     try {
//       HttpClient httpClient = HttpClient();
//             httpClient.badCertificateCallback = (cert, host, port) => true;
//             IOClient ioClient = IOClient(httpClient);
//       // final response = await ioClient.get(url, headers: {"Connection": "keep-alive"});
//       final response = await ioClient.get(Uri.parse(url));
//       print("📡 Status Code: ${response.statusCode}");
//       print("📨 Raw Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final dynamic rawJson = json.decode(response.body);
//
//         if (rawJson is List && rawJson.length > 1) {
//           final secondObject = rawJson[1] as Map<String, dynamic>;
//
//           final solrResponse = SolrProductResponse.fromJson({'response': secondObject});
//           print("✅ Parsed ${solrResponse.products.length} products");
//
//           for (var p in solrResponse.products) {
//             print("🧵 ${p.designerName} - ₹${p.actualPrice} - ${p.shortDesc}");
//           }
//
//           return solrResponse.products;
//         } else {
//           print("⚠️ Unexpected format: $rawJson");
//           throw Exception("Unexpected response format from API");
//         }
//       } else {
//         print("❌ Error: ${response.statusCode} - ${response.body}");

//         throw Exception("Failed to load products from API");
//       }
//     } catch (e, stackTrace) {
//       print("🔥 Exception occurred: $e");
//       print("📍 StackTrace: $stackTrace");
//       throw Exception("Error fetching products: $e");
//     }
//   }
// }



