import 'package:aashni_app/bloc/login/login_screen_bloc.dart';
import 'package:aashni_app/features/auth/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ShoppingBagScreen extends StatefulWidget {
  @override
  _ShoppingBagScreenState createState() => _ShoppingBagScreenState();
}

class _ShoppingBagScreenState extends State<ShoppingBagScreen> {
  List<dynamic> cartItems = [];
  // List<Map<String, dynamic>> cartItems = [];

  bool isLoading = true;
  bool isLoggedIn = false;

  //
  // List<Map<String, dynamic>> cartItems = [];

  late Dio dio;
  final CookieJar cookieJar = CookieJar();

  @override
  void initState() {
    super.initState();
    dio = Dio();
    dio.interceptors.add(CookieManager(cookieJar));

// ignore bad SSL certificates
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
      return;
    }

    isLoggedIn = true;

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.get(
      Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> items = json.decode(response.body);
      setState(() {
        cartItems = items;
        if (cartItems.isNotEmpty) {
          print(cartItems.runtimeType);       // List<dynamic>
          print(cartItems[0].runtimeType);    // Map<String, dynamic>
          print(cartItems[0]['item_id']);
        } else {
          print("Cart items list is empty.");
        }
        isLoading = false;
      });
    } else {
      print("Error fetching cart items: ${response.body}");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart items')),
      );
    }
  }


  // Future<bool> deleteCartItemFromMagento(BuildContext context, int itemId) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //
  //   if (customerToken == null || customerToken.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('User not logged in.')),
  //     );
  //     return false;
  //   }
  //
  //   try {
  //     final response = await dio.post(
  //       'https://stage.aashniandco.com/rest/V1/solr/cart/item/delete',
  //       data: jsonEncode({'item_id': itemId}), // 👈 Force JSON encoding here
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $customerToken',
  //           'Content-Type': 'application/json', // 👈 Must be JSON
  //         },
  //       ),
  //     );
  //
  //     print("Delete response: ${response.data}");
  //
  //     if (response.statusCode == 200 && response.data is Map && response.data['success'] == true) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(response.data['message'] ?? 'Item removed')),
  //       );
  //       return true;
  //     } else {
  //       if (response.data is List) {
  //         final List res = response.data;
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text(res.length > 1 ? res[1].toString() : 'Deletion failed')),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Unexpected response from server')),
  //         );
  //       }
  //       return false;
  //     }
  //   } catch (e) {
  //     print("Error deleting item: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //     return false;
  //   }
  // }

  // ✅ This is the missing method








  Future<void> removeItem(BuildContext context, dynamic itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (itemId == null || itemId.toString().isEmpty) {
      print('Error: itemId is null or empty');
      return;
    }

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    // Build URL with query parameter
    final url = Uri.parse(
      'https://stage.aashniandco.com/rest/V1/solr/cart/item/delete?item_id=$itemId',
    );

    try {
      final response = await ioClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $customerToken',
          // No need to send Content-Type if no body
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final resData = jsonDecode(response.body);

      if (resData is List && resData.isNotEmpty && resData[0] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
        setState(() {
          cartItems.removeWhere((element) =>
          element is Map && element['item_id'].toString() == itemId.toString());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item: ${resData[1]}')),
        );
      }
    } catch (e) {
      print('Error deleting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  }












  // Future<void> deleteCartItemFromMagento(BuildContext context, int itemId) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //
  //   print("token @delete >> $customerToken");
  //
  //   if (customerToken == null || customerToken.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('User not logged in.')),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     final response = await dio.delete(
  //       'https://stage.aashniandco.com/rest/V1/carts/mine/items/$itemId',
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $customerToken',
  //           'Content-Type': 'application/json',
  //         },
  //       ),
  //     );
  //
  //     if (response.statusCode == 200 || response.statusCode == 204) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Item removed successfully.')),
  //       );
  //     } else {
  //       print('Delete failed: ${response.statusCode} ${response.data}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to delete item: ${response.statusCode}')),
  //       );
  //     }
  //   } on DioError catch (e) {
  //     print('Dio error occurred: ${e.response?.statusCode} ${e.response?.data}');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error occurred: ${e.response?.statusCode ?? ''}')),
  //     );
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Unexpected error: $e')),
  //     );
  //   }
  // }
  //
  // void removeItem(BuildContext context, Map<String, dynamic> item) async {
  //   final int? itemId = item['item_id'];
  //   if (itemId == null) return;
  //
  //   await deleteCartItemFromMagento(context, itemId);
  //
  //   setState(() {
  //     cartItems.removeWhere((element) => element['item_id'] == itemId);
  //   });
  // }


  Future<int?> updateCartItemQty(int itemId, int qty) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    // Build URL with query parameters
    final uri = Uri.parse(
      "https://stage.aashniandco.com/rest/V1/solr/cart/item/updateQty?item_id=$itemId&qty=$qty",
    );

    final response = await ioClient.post(
      uri,
      headers: {
        'Authorization': 'Bearer $customerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty && data[0] == true) {
          // Try to get updated qty from index 2
          if (data.length > 2 && data[2] is Map && data[2]['qty'] != null) {
            final updatedQty = data[2]['qty'];
            print("Updated qty: $updatedQty");
            return updatedQty is int ? updatedQty : int.tryParse(updatedQty.toString());
          } else {
            print("Qty updated but not returned, fallback to requested qty: $qty");
            return qty;
          }
        } else {
          print("Failed to update qty: ${data[1]}");
          return null;
        }
      } catch (e) {
        print("Error parsing response: $e");
        return null;
      }
    } else {
      print("HTTP error: ${response.statusCode}");
      return null;
    }
  }




  void _onQtyChange(Map<String, dynamic> item, int delta) async {
    final int itemId = item['item_id'];
    int currentQty = 1;

    if (item['qty'] is int) {
      currentQty = item['qty'];
    } else if (item['qty'] is String) {
      currentQty = int.tryParse(item['qty']) ?? 1;
    }

    int newQty = currentQty + delta;
    if (newQty < 1) newQty = 1;

    int? updatedQty = await updateCartItemQty(itemId, newQty);

    if (updatedQty != null) {
      setState(() {
        final index = cartItems.indexWhere((e) =>
        e is Map<String, dynamic> && e['item_id'] == itemId);

        if (index != -1 && cartItems[index] is Map<String, dynamic>) {
          (cartItems[index] as Map<String, dynamic>)['qty'] = updatedQty;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity')),
      );
    }
  }









  // void updateQuantity(Map<String, dynamic> item, int delta) {
  //   final rawQty = item['qty'];
  //   int qty = 1;
  //   if (rawQty is int) {
  //     qty = rawQty;
  //   } else if (rawQty is String) {
  //     qty = int.tryParse(rawQty) ?? 1;
  //   }
  //   qty += delta;
  //   if (qty < 1) qty = 1;
  //
  //   setState(() {
  //     final index = cartItems.indexWhere((e) => e['item_id'] == item['item_id']);
  //     if (index != -1) {
  //       cartItems[index]['qty'] = qty;
  //     }
  //   });
  // }

  // void removeItem(Map item) {
  //   setState(() {
  //     cartItems.remove(item);
  //   });
  // }


  @override

  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Shopping Bag")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text("Shopping Bag")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "SIGN IN TO YOUR ACCOUNT TO ENABLE SYNC",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountScreen()),
                  );
                },
                child: const Text("Sign In"),
              ),
            ],
          ),
        ),
      );
    }

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Shopping Bag")),
        body: const Center(child: Text("Your cart is empty")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Shopping Bag")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...cartItems.map((item) {
              print('Item type: ${item.runtimeType}');
              print('Item: $item');
              if (item is! Map<String, dynamic>) return const SizedBox.shrink();
              final qty = item['qty'] ?? 1;
              final price = double.tryParse(item['price'].toString()) ?? 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item['prodSmallImg'] ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(item['name'] ?? '',
                    style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("SKU: ${item['sku'] ?? ''}",
                    style: const TextStyle(
                    fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
              Text("Price : ₹${price.toStringAsFixed(0)}",
              style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
              children: [
                IconButton(
                  onPressed: () => _onQtyChange(item, -1),
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '${item['qty']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _onQtyChange(item, 1),
                  icon: const Icon(Icons.add),
                ),
              const Spacer(),
              IconButton(
              onPressed: () async {
              await removeItem(context, item['item_id']);
              // no need to remove item here again, since removeItem already calls setState and removes
              },
              icon: const Icon(Icons.delete_outline),
              ),

              ],
              ),
              Text("Subtotal : ₹${(price * qty).toStringAsFixed(0)}",
              style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500)),
              ],
              ),
              ),

                  ],
                ),
              );
            }).toList(),

            // Optional: Add coupon / address / payment summary below here
          ],
        ),
      ),
    );
  }

}





// class ShoppingBagScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Shopping Bag"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "SIGN IN TO YOUR ACCOUNT TO ENABLE SYNC",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Add functionality for Sign In
//                 print("Sign In clicked");
//
//                 Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountScreen()));
//               },
//               child: Text("Sign In"),
//             ),
//             SizedBox(height: 10),
//             // TextButton(
//             //   onPressed: () {
//             //     // Add functionality for checking out new items
//             //     print("Check out New In clicked");
//             //   },
//             //   child: Text("Or check out New In"),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
