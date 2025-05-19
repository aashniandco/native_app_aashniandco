import 'package:aashni_app/bloc/login/login_screen_bloc.dart';
import 'package:aashni_app/features/auth/view/login_screen.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingBagScreen extends StatefulWidget {
  @override
  _ShoppingBagScreenState createState() => _ShoppingBagScreenState();
}

class _ShoppingBagScreenState extends State<ShoppingBagScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Shopping Bag")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text("Shopping Bag")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SIGN IN TO YOUR ACCOUNT TO ENABLE SYNC",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen()));
                },
                child: Text("Sign In"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Shopping Bag")),
      body: cartItems.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            title: Text(item['name'] ?? 'Unknown Product'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SKU: ${item['sku']}"),
                Text("Qty: ${item['qty']}"),
              ],
            ),
            trailing: Text("₹${item['price']}"),
          );
        },
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
