// import 'dart:convert';
// import 'dart:io';
//
// import 'package:http/io_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ShippingRepository {
//   final IOClient ioClient;
//
//   ShippingRepository()
//       : ioClient = IOClient(
//     HttpClient()..badCertificateCallback = (cert, host, port) => true,
//   );
//
//
//   Future<List<Map<String, dynamic>>> fetchCountries() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/directory/countries');
//
//     final response = await ioClient.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $customerToken',
//         'Content-Type': 'application/json',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print('Country data raw response: ${response.body}');
//
//       if (data is List) {
//         // Each item in list: { "id": "IN", "full_name_english": "India", ... }
//         return data.cast<Map<String, dynamic>>();
//       } else {
//         throw Exception("Invalid country data");
//       }
//     } else {
//       throw Exception("Failed to fetch countries: ${response.body}");
//     }
//   }
//
//
//   Future<double> fetchCartTotalWeight(int customerId) async {
//     print("Checkout init fetchCartTotalWeightcalled>>");
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//     final response = await ioClient.get(
//       Uri.parse('https://stage.aashniandco.com/rest/V1/cart/details/$customerId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $customerToken',
//       },
//     );
//
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body) as List<dynamic>;
//       if (data.isEmpty) {
//         return 0.0;
//       }
//       final firstItem = data[0] as Map<String, dynamic>;
//       final weightStr = firstItem['total_cart_weight'];
//       final totalWeight = double.tryParse(weightStr.toString()) ?? 0.0;
//       print("init fetchCartTotalWeightcalled>>$totalWeight");
//       return totalWeight;
//     } else {
//       throw Exception("Failed to fetch cart total weight: ${response.body}");
//     }
//   }
//
//   Future<double?> estimateShipping(String countryId, double cartWeight) async { // Added cartWeight parameter
//     fetchCartTotalWeight();
//     final regionId = 0; // Still hardcoded
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//
//     // MODIFIED: cartWeight is now part of the URL
//     final shippingUrl =
//         "https://stage.aashniandco.com/rest/V1/aashni/shipping-rate/$countryId/$regionId/$cartWeight";
//
//     print('--- ShippingRepository: Attempting to estimate shipping ---');
//     print('Country ID: $countryId, Region ID (hardcoded): $regionId, Cart Weight: $cartWeight'); // Added cartWeight
//     print('Request URL: $shippingUrl');
//     print('Customer Token: $customerToken');
//     print('-------------------------------------------------------------');
//
//     final response = await ioClient.get(
//       Uri.parse(shippingUrl),
//       headers: {
//         'Authorization': 'Bearer $customerToken',
//         'Content-Type': 'application/json',
//       },
//     );
//
//     print('--- ShippingRepository: API Response ---');
//     print('Status Code: ${response.statusCode}');
//     print('Response Body: ${response.body}');
//     print('--------------------------------------');
//
//     // It's safer to check status code before attempting to decode JSON
//     if (response.statusCode != 200) {
//       print('ShippingRepository: API call failed with status code ${response.statusCode}.');
//       throw Exception("Failed to estimate shipping (HTTP ${response.statusCode}): ${response.body}");
//     }
//
//     final data = jsonDecode(response.body);
//
//     if (data is List && data.length >= 2 && data[0] == true) {
//       final price = data[1];
//       print('ShippingRepository: Price from API before conversion: $price (Type: ${price.runtimeType})');
//       if (price != null) {
//         if (price is num) {
//           return price.toDouble();
//         } else if (price is String) {
//           try {
//             return double.parse(price);
//           } catch (e) {
//             print('ShippingRepository: Error parsing price string "$price" to double: $e');
//             throw Exception("Failed to estimate shipping: Invalid price format in response - ${response.body}");
//           }
//         } else {
//           throw Exception("Failed to estimate shipping: Price is of unexpected type ${price.runtimeType} - ${response.body}");
//         }
//       } else {
//         throw Exception("Failed to estimate shipping: Price from API is null - ${response.body}");
//       }
//     } else {
//       print('ShippingRepository: Condition for successful parsing FAILED.');
//       print('  - response.statusCode == 200: ${response.statusCode == 200}'); // Will be true if we reached here
//       print('  - data is List: ${data is List}');
//       if (data is List) {
//         print('  - data.length >= 2: ${data.length >= 2}');
//         if (data.isNotEmpty) { // check if not empty before accessing data[0]
//           print('  - data[0] == true: ${data[0] == true} (Actual data[0]: ${data[0]}, Type: ${data[0].runtimeType})');
//         } else {
//           print('  - data is an empty list.');
//         }
//       }
//       throw Exception("Failed to estimate shipping: Unexpected response format - ${response.body}");
//     }
//   }
//
//   // Future<double?> estimateShipping(String countryId) async {
//   //   final regionId = 0; // Still hardcoded
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final customerToken = prefs.getString('user_token');
//   //
//   //   // Potential Exception 1: User not logged in
//   //   if (customerToken == null || customerToken.isEmpty) {
//   //     throw Exception("User not logged in");
//   //   }
//   //
//   //   final shippingUrl =
//   //       "https://stage.aashniandco.com/rest/V1/aashni/shipping-rate/$countryId/$regionId";
//   //
//   //   // Add print statement HERE, BEFORE the API call, to ensure this method is reached and with what data
//   //   print('--- ShippingRepository: Attempting to estimate shipping ---');
//   //   print('Country ID: $countryId, Region ID (hardcoded): $regionId');
//   //   print('Request URL: $shippingUrl');
//   //   print('Customer Token: $customerToken'); // Be careful logging tokens in production
//   //   print('-------------------------------------------------------------');
//   //
//   //
//   //   final response = await ioClient.get( // This line could throw if network error, DNS issue, etc.
//   //     Uri.parse(shippingUrl),
//   //     headers: {
//   //       'Authorization': 'Bearer $customerToken',
//   //       'Content-Type': 'application/json',
//   //     },
//   //   );
//   //
//   //   // Add print statement HERE, AFTER the API call, to see the raw response
//   //   print('--- ShippingRepository: API Response ---');
//   //   print('Status Code: ${response.statusCode}');
//   //   print('Response Body: ${response.body}'); // THIS IS THE MOST IMPORTANT LOG
//   //   print('--------------------------------------');
//   //
//   //   // Potential Exception 2: jsonDecode fails if response.body is not valid JSON
//   //   final data = jsonDecode(response.body);
//   //
//   //   // Potential Exception 3: Conditions not met, leading to the throw
//   //   if (response.statusCode == 200 && data is List && data.length >= 2 && data[0] == true) {
//   //     final price = data[1];
//   //     // This part is also critical: what is `price`?
//   //     print('ShippingRepository: Price from API before conversion: $price (Type: ${price.runtimeType})');
//   //     if (price != null) {
//   //       if (price is num) { // int or double
//   //         return price.toDouble();
//   //       } else if (price is String) {
//   //         try {
//   //           return double.parse(price);
//   //         } catch (e) {
//   //           print('ShippingRepository: Error parsing price string "$price" to double: $e');
//   //           // Potential Exception 4: String price not parsable
//   //           throw Exception("Failed to estimate shipping: Invalid price format in response - ${response.body}");
//   //         }
//   //       } else {
//   //         // Potential Exception 5: Price is not null, but not num or String
//   //         throw Exception("Failed to estimate shipping: Price is of unexpected type ${price.runtimeType} - ${response.body}");
//   //       }
//   //     } else {
//   //       // Potential Exception 6: Price is null
//   //       throw Exception("Failed to estimate shipping: Price from API is null - ${response.body}");
//   //     }
//   //   } else {
//   //     // This is the most likely place it's throwing the exception if the API call itself succeeded (no network error)
//   //     // but the response wasn't what you expected.
//   //     print('ShippingRepository: Condition for successful parsing FAILED.');
//   //     print('  - response.statusCode == 200: ${response.statusCode == 200}');
//   //     print('  - data is List: ${data is List}');
//   //     if (data is List) {
//   //       print('  - data.length >= 2: ${data.length >= 2}');
//   //       if (data.length > 0) {
//   //         print('  - data[0] == true: ${data[0] == true} (Actual data[0]: ${data[0]}, Type: ${data[0].runtimeType})');
//   //       }
//   //     }
//   //     // Potential Exception 7: API call successful but response format incorrect or indicates failure
//   //     throw Exception("Failed to estimate shipping: ${response.body}");
//   //   }
//   // }
// }



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
      throw Exception("User not logged in for fetching countries");
    }

    final url = Uri.parse('https://stage.aashniandco.com/rest/V1/directory/countries');
    print('--- ShippingRepository: Attempting to fetch countries ---');
    print('Request URL: $url');
    print('Customer Token: $customerToken');
    print('-------------------------------------------------------------');

    final response = await this.ioClient.get( // Use this.ioClient
      url,
      headers: {
        'Authorization': 'Bearer $customerToken',
        'Content-Type': 'application/json',
      },
    );

    print('--- ShippingRepository: API Response for countries ---');
    print('Status Code: ${response.statusCode}');
    // print('Response Body: ${response.body}'); // Can be verbose, enable if debugging
    print('------------------------------------------------------');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print('Country data raw response: ${response.body}'); // Already logged above if needed

      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        print("Invalid country data format. Expected List, got ${data.runtimeType}");
        throw Exception("Invalid country data: ${response.body}");
      }
    } else {
      print("Failed to fetch countries (HTTP ${response.statusCode}): ${response.body}");
      throw Exception("Failed to fetch countries: ${response.body}");
    }
  }

  Future<double> fetchCartTotalWeight(int customerId) async {
    print("ShippingRepository: fetchCartTotalWeight called for customerId: $customerId");
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in for fetching cart weight");
    }

    final url = Uri.parse('https://stage.aashniandco.com/rest/V1/cart/details/$customerId');
    print('--- ShippingRepository: Attempting to fetch cart total weight ---');
    print('Request URL: $url');
    print('Customer Token: $customerToken');
    print('-------------------------------------------------------------');

    final response = await this.ioClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
    );

    print('--- ShippingRepository: API Response for cart details ---');
    print('Status Code: ${response.statusCode}');
    // print('Response Body: ${response.body}'); // Enable if needed
    print('---------------------------------------------------------');

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData is List<dynamic>) {
        if (decodedData.isEmpty) {
          print("ShippingRepository: Cart details data is empty, returning 0.0 weight.");
          return 0.0;
        }

        double totalWeight = 0.0;
        for (final item in decodedData) {
          try {
            final weight = double.tryParse(item['weight']?.toString() ?? '0') ?? 0.0;
            totalWeight += weight;
          } catch (e) {
            print("Error parsing weight for item: $item");
          }
        }

        print("ShippingRepository: Total cart weight calculated: $totalWeight");
        return totalWeight;
      } else {
        print("Unexpected data format for cart details: ${decodedData.runtimeType}");
        throw Exception("Invalid cart details format.");
      }
    } else {
      print("Failed to fetch cart details (HTTP ${response.statusCode}): ${response.body}");
      throw Exception("Failed to fetch cart details: ${response.body}");
    }
  }


  Future<double?> estimateShipping(String countryId, double cartWeight) async {
    // fetchCartTotalWeight(); // REMOVE THIS LINE - This was the source of your error.
    // The cartWeight is passed as a parameter.
print("called>>>>>>>>>>>");
    final regionId = 0; // Still hardcoded
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in for estimating shipping");
    }

    final shippingUrl =
        "https://stage.aashniandco.com/rest/V1/aashni/shipping-rate/$countryId/0?weight=$cartWeight";

    print('--- ShippingRepository: Attempting to estimate shipping ---');
    print('Country ID: $countryId, Region ID (hardcoded): $regionId, Cart Weight: $cartWeight');
    print('Request URL>>>>>: $shippingUrl');
    print('Customer Token: $customerToken');
    print('-------------------------------------------------------------');

    final response = await this.ioClient.get( // Use this.ioClient
      Uri.parse(shippingUrl),
      headers: {
        'Authorization': 'Bearer $customerToken',
        'Content-Type': 'application/json',
      },
    );

    print('--- ShippingRepository: API Response for shipping estimate ---');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}'); // Log the full body for shipping estimate
    print('----------------------------------------------------------');

    if (response.statusCode != 200) {
      print('ShippingRepository: Estimate shipping API call failed with status code ${response.statusCode}.');
      throw Exception("Failed to estimate shipping (HTTP ${response.statusCode}): ${response.body}");
    }

    final data = jsonDecode(response.body);

    if (data is List && data.length >= 2 && data[0] == true) {
      final price = data[1];
      print('ShippingRepository: Price from API before conversion: $price (Type: ${price.runtimeType})');
      if (price != null) {
        if (price is num) {
          return price.toDouble();
        } else if (price is String) {
          try {
            return double.parse(price);
          } catch (e) {
            print('ShippingRepository: Error parsing price string "$price" to double: $e');
            throw Exception("Failed to estimate shipping: Invalid price format in response - ${response.body}");
          }
        } else {
          throw Exception("Failed to estimate shipping: Price is of unexpected type ${price.runtimeType} - ${response.body}");
        }
      } else {
        throw Exception("Failed to estimate shipping: Price from API is null - ${response.body}");
      }
    } else {
      print('ShippingRepository: Condition for successful parsing FAILED for shipping estimate.');
      print('  - data is List: ${data is List}');
      if (data is List) {
        print('  - data.length >= 2: ${data.length >= 2}');
        if (data.isNotEmpty) {
          print('  - data[0] == true: ${data[0] == true} (Actual data[0]: ${data[0]}, Type: ${data[0].runtimeType})');
        } else {
          print('  - data is an empty list.');
        }
      }
      throw Exception("Failed to estimate shipping: Unexpected response format - ${response.body}");
    }
  }

  // Optional: An orchestrating method
  // This is how you would typically use the above methods together.
  // Future<double?> getFullShippingEstimateForCustomer(String countryId, int customerId) async {
  //   try {
  //     print("ShippingRepository: Orchestrating full shipping estimate for country $countryId, customer $customerId");
  //     // Step 1: Fetch cart total weight
  //     double weight = await fetchCartTotalWeight(customerId);
  //
  //     // Step 2: Estimate shipping with the fetched weight
  //     double? shippingCost = await estimateShipping(countryId, weight);
  //     return shippingCost;
  //   } catch (e) {
  //     print("ShippingRepository: Error in getFullShippingEstimateForCustomer: $e");
  //     rethrow; // Or handle more gracefully, e.g., return null
  //   }
  // }

// This is the method you will call from your UI or BLoC.
// It orchestrates the entire process.
//   Future<double?> getFullShippingEstimateForCustomer(String countryId, int customerId) async {
//     try {
//       print("ShippingRepository: Starting the full shipping estimate process...");
//
//       // STEP 1: Call fetchCartTotalWeight and AWAIT the result.
//       // The `await` keyword gets the `double` value out of the `Future<double>`.
//       // The result is stored in the `weight` variable.
//       print("Step 1: Fetching cart total weight for customer $customerId...");
//       double weight = await fetchCartTotalWeight(customerId);
//       print("Step 1 complete. Fetched weight: $weight");
//
//       // If the cart is empty (weight is 0), you might want to return 0 immediately
//       // to avoid an unnecessary API call.
//       if (weight == 0.0) {
//         print("Cart weight is 0. Returning 0 for shipping cost.");
//         return 0.0;
//       }
//
//       // STEP 2: Call estimateShipping, passing the `weight` variable from Step 1.
//       // Await the final result.
//       print("Step 2: Estimating shipping for country $countryId with weight $weight...");
//       double? shippingCost = await estimateShipping(countryId, weight);
//       print("Step 2 complete. Estimated shipping cost: $shippingCost");
//
//       // STEP 3: Return the final calculated shipping cost.
//       return shippingCost;
//
//     } catch (e) {
//       // If anything fails in either Step 1 or Step 2, the error is caught here.
//       print("ShippingRepository: An error occurred during the shipping estimate process: $e");
//       // rethrow the error so the UI layer can know something went wrong.
//       rethrow;
//     }
//   }
}