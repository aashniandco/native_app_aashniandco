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

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ shipping_bloc/shipping_event.dart';
import '../model/countries.dart';

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


//   Future<double?> estimateShipping(String countryId, double cartWeight) async {
//     // fetchCartTotalWeight(); // REMOVE THIS LINE - This was the source of your error.
//     // The cartWeight is passed as a parameter.
// print("called>>>>>>>>>>>");
//     final regionId = 0; // Still hardcoded
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in for estimating shipping");
//     }
//
//     final shippingUrl =
//         "https://stage.aashniandco.com/rest/V1/aashni/shipping-rate/$countryId/0?weight=$cartWeight";
//
//     print('--- ShippingRepository: Attempting to estimate shipping ---');
//     print('Country ID: $countryId, Region ID (hardcoded): $regionId, Cart Weight: $cartWeight');
//     print('Request URL>>>>>: $shippingUrl');
//     print('Customer Token: $customerToken');
//     print('-------------------------------------------------------------');
//
//     final response = await this.ioClient.get( // Use this.ioClient
//       Uri.parse(shippingUrl),
//       headers: {
//         'Authorization': 'Bearer $customerToken',
//         'Content-Type': 'application/json',
//       },
//     );
//
//     print('--- ShippingRepository: API Response for shipping estimate ---');
//     print('Status Code: ${response.statusCode}');
//     print('Response Body: ${response.body}'); // Log the full body for shipping estimate
//     print('----------------------------------------------------------');
//
//     if (response.statusCode != 200) {
//       print('ShippingRepository: Estimate shipping API call failed with status code ${response.statusCode}.');
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
//       print('ShippingRepository: Condition for successful parsing FAILED for shipping estimate.');
//       print('  - data is List: ${data is List}');
//       if (data is List) {
//         print('  - data.length >= 2: ${data.length >= 2}');
//         if (data.isNotEmpty) {
//           print('  - data[0] == true: ${data[0] == true} (Actual data[0]: ${data[0]}, Type: ${data[0].runtimeType})');
//         } else {
//           print('  - data is an empty list.');
//         }
//       }
//       throw Exception("Failed to estimate shipping: Unexpected response format - ${response.body}");
//     }
//   }
///////////14 june



  // Future<List<Map<String, dynamic>>> fetchAvailableShippingMethods({
  //   required String countryId,
  //   required String regionId,
  //   required String regionCode,
  //   required String regionName,
  //   required String postcode,
  //   required String city,
  //   required String street,
  //   required String firstname,
  //   required String lastname,
  //   required String telephone,
  // }) async {
  //   if (kDebugMode) {
  //     print("--- ShippingRepository: Fetching available shipping methods ---");
  //   }
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null || customerToken.isEmpty) {
  //     throw Exception("User not logged in");
  //   }
  //
  //   // Construct the payload for the API
  //   final payload = {
  //     "address": {
  //       "region": regionName,
  //       "region_id": int.tryParse(regionId) ?? 0,
  //       "region_code": regionCode,
  //       "country_id": countryId,
  //       "postcode": postcode,
  //       "city": city,
  //       "street": [street],
  //       "firstname": firstname,
  //       "lastname": lastname,
  //       "telephone": telephone,
  //     }
  //   };
  //
  //   if (kDebugMode) {
  //     print("Request Payload: ${json.encode(payload)}");
  //   }
  //
  //   final url = Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods');
  //   final response = await this.ioClient.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //     body: json.encode(payload),
  //   );
  //
  //   if (kDebugMode) {
  //     print("API Response Status: ${response.statusCode}");
  //     print("API Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> responseData = json.decode(response.body);
  //     // Convert the list of dynamic to a list of maps
  //     return responseData.map((item) => item as Map<String, dynamic>).toList();
  //   } else {
  //     final errorBody = json.decode(response.body);
  //     throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
  //   }
  // }

  // 🔄 REPLACE your old estimateShipping method with this one.
// This method now returns a List of ShippingMethod objects.
  Future<List<ShippingMethod>> fetchAvailableShippingMethods({
    required String countryId,
    required String regionId,
    required String postcode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }

    // This is the standard Magento endpoint
    final url = Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods');

    // The payload requires the shipping address
    final payload = {
      "address": {
        "country_id": countryId,
        "region_id": int.tryParse(regionId) ?? 0,
        "postcode": postcode.isNotEmpty ? postcode : "00000", // Use a placeholder if empty
        // You can add more address fields here if needed by other shipping methods
      }
    };

    HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
      body: json.encode(payload),
    );

    print("Standard Shipping API Response: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      // Map the JSON response to your new ShippingMethod model
      return responseData.map((data) => ShippingMethod.fromJson(data)).toList();
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
    }
  }

// ✅ REPLACE your repository method with this corrected



  Future<Map<String, dynamic>> submitShippingInformation(SubmitShippingInfo event) async {
    if (kDebugMode) {
      print("--- ShippingRepository: Submitting shipping information ---");
    }

    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in for submitting shipping info");
    }

    // This part is fine. It builds the address object.
    final addressPayload = {
      "region": event.regionName,
      "region_id": int.tryParse(event.regionId) ?? 0,
      "region_code": event.regionCode,
      "country_id": event.countryId,
      "street": [event.streetAddress],
      "postcode": event.zipCode,
      "city": event.city,
      "firstname": event.firstName,
      "lastname": event.lastName,
      "email": event.email.isNotEmpty ? event.email : "mitesh@gmail.com",
      "telephone": event.phone,
    };

    // ✅ --- START OF THE FIX ---
    // The structure of the main request body needs to be corrected.
    final Map<String, dynamic> requestBody = {
      "addressInformation": {
        "shipping_address": addressPayload,
        "billing_address": addressPayload, // Using the same address for billing

        // The keys must be prefixed with "shipping_" and be at this level.
        "shipping_carrier_code": event.carrierCode,
        "shipping_method_code": event.methodCode,
      }
    };
    // ✅ --- END OF THE FIX ---

    if (kDebugMode) {
      print("Final Payload Check: ${json.encode(requestBody)}");
    }

    final url = Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/shipping-information');
    final response = await this.ioClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
      body: json.encode(requestBody),
    );

    if (kDebugMode) {
      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");
      print("---------------------------------------------------------");
    }

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = json.decode(response.body);
      // Check for a more specific error message from Magento
      String errorMessage = 'Failed to save address. Please check the details and try again.';
      if (errorBody['message'] != null) {
        errorMessage = errorBody['message'];
        // Check for parameter details which can be very helpful
        if (errorBody['parameters'] != null && errorBody['parameters'] is Map) {
          errorMessage += " Details: ${errorBody['parameters']}";
        }
      }
      throw Exception(errorMessage);
    }
  }

// In your shipping_repository.dart

// ✅ REPLACE your existing method with this more robust version

  // ✅ REPLACE your entire repository method with this one.

  // ✅ REPLACE your repository method with this one, which includes the new debugging step.

  // ✅ REPLACE your repository method with this corrected version

  // lib/features/shoppingbag/repository/shipping_repository.dart

  Future<int> submitPaymentInformation(SubmitPaymentInfo event) async {
    if (kDebugMode) print("--- ShippingRepository: Submitting Payment Info ---");

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    if (customerToken == null) throw Exception("User not logged in.");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $customerToken',
    };

    try {
      // This debugging is fine, leave it as is.
      final cartDetailsResponse = await ioClient.get(
        Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
        headers: headers,
      );
      if (cartDetailsResponse.statusCode == 200) {
        final cartData = json.decode(cartDetailsResponse.body);
        final cartId = cartData['id'];
        if (kDebugMode) print("✅ Cart ID: $cartId");
      }

      final paymentMethodsResponse = await ioClient.get(
        Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/payment-methods'),
        headers: headers,
      );
      if (kDebugMode) print("✅ Payment methods: ${paymentMethodsResponse.body}");

      // --- This sanitation logic is correct ---
      Map<String, dynamic> sanitizedBillingAddress = Map.from(event.billingAddress);
      if (sanitizedBillingAddress['street'] is Set) {
        if (kDebugMode) print("Warning: 'street' field was a Set. Converting to List.");
        sanitizedBillingAddress['street'] = (sanitizedBillingAddress['street'] as Set).toList();
      }

      // ✅ START OF THE FIX: Correctly build the payload
      final payload = {
        "paymentMethodCode": event.paymentMethodCode,
        "billingAddress": sanitizedBillingAddress,
        // The backend function is expecting a top-level parameter
        // named 'paymentMethodNonce', not a nested object.
        "paymentMethodNonce": event.paymentMethodNonce
      };
      // final payload = {
      //   "paymentMethodCode": event.paymentMethodCode,
      //   "billingAddress": sanitizedBillingAddress,
      //   "paymentMethodData": {
      //     "type": "card",
      //     "card": {
      //       "token": event.paymentMethodNonce
      //     }
      //   }
      // };

      // ✅ END OF THE FIX

      if (kDebugMode) print("Final Corrected Payload: ${json.encode(payload)}");

      final response = await ioClient.post(
        Uri.parse('https://stage.aashniandco.com/rest/V1/aashni/place-order'),
        headers: headers,
        body: json.encode(payload),
      );

      if (kDebugMode) {
        print("Payment API Status (POST): ${response.statusCode}");
        print("Payment API Body (POST): ${response.body}");
      }

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return int.parse(responseBody.toString());
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to place order.');
      }

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("❌ Exception during payment info submission: $e");
        print("StackTrace: $stackTrace");
      }
      rethrow;
    }
  }

// Future<int> submitPaymentInformation(SubmitPaymentInfo event) async {
  //   if (kDebugMode) print("--- ShippingRepository: Submitting Payment Info ---");
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null) throw Exception("User not logged in.");
  //
  //   final payload = {
  //     "paymentMethod": {"method": event.paymentMethodCode},
  //     "billing_address": event.billingAddress
  //   };
  //
  //   if (kDebugMode) print("Payment Payload: ${json.encode(payload)}");
  //
  //   final response = await ioClient.post(
  //     Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/payment-information'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //     body: json.encode(payload),
  //   );
  //
  //   if (kDebugMode) {
  //     print("Payment API Status: ${response.statusCode}");
  //     print("Payment API Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     // Magento returns the order ID directly in the response body
  //     return int.parse(response.body);
  //   } else {
  //     final errorBody = json.decode(response.body);
  //     throw Exception(errorBody['message'] ?? 'Failed to place order.');
  //   }
  // }

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