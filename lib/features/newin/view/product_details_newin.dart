import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../../../constants/user_preferences_helper.dart';
import '../../cart/view/cart.dart';
import '../../shoppingbag/shopping_bag.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/new_in_model.dart';  // Adjust import based on where your Product model is located

class ProductDetailNewInDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;




  const ProductDetailNewInDetailScreen({Key? key, required this.product}) : super(key: key);


  @override
  State<ProductDetailNewInDetailScreen> createState() => _ProductDetailNewInDetailScreenState();
}


class _ProductDetailNewInDetailScreenState extends State<ProductDetailNewInDetailScreen> {
  // int selectedSizeIndex = 0; // Default selected size
  int selectedSizeIndex = -1;
  String selectedSize = '';
  String firstName = '';
  String lastName = '';
  int customer_id = 0;

  // List<String> sizes = ["S", "M", "L"]; // Dummy size options
  List<String> sizes = [];
  late PageController _pageController;


  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    final rawSizes = widget.product['size_name'];
    print('Raw sizes from API: $rawSizes');

    if (rawSizes != null && rawSizes is List && rawSizes.isNotEmpty) {
      sizes = List<String>.from(rawSizes).map((size) {
        switch (size.toLowerCase()) {
          case "xxsmall": return "Xxsmall";
          case "xsmall": return "Xsmall";
          case "small": return "Small";
          case "medium": return "Medium";
          case "large": return "Large";
          case "xlarge": return "XLarge";
          case "xxlarge": return "XXLarge";
          case "3xlarge": return "3XLarge";
          case "4xlarge": return "4XLarge";
          case "5xlarge": return "5XLarge";
          case "6xlarge": return "6XLarge";
          case "custom made": return "Custom Made";
          default: return size.toUpperCase(); // fallback
        }
      }).toList();
    } else {
      sizes = ["S", "M", "L"]; // fallback only if no data
    }

    _loadUserNames();
  }

  Future<void> _loadUserNames() async {
    final fName = await UserPreferences.getFirstName();
    final lName = await UserPreferences.getLastName();
    final  id = await UserPreferences.getCustomerId();

    print("cust>>$customer_id");

    setState(() {
      firstName = fName;
      lastName = lName;
      customer_id = id ?? 0;
    });

    print("cust====$customer_id");
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _showSizeChartDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Ensures full-screen modal
      backgroundColor: Colors.transparent, // Make it full screen
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height, // Full height
          width: MediaQuery.of(context).size.width,   // Full width
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    "assets/women_size_chart.png",
                    fit: BoxFit.contain, // Ensures the image fits well
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> onAddToCartPressed() async {
    if (selectedSize.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size')),
      );
      return;
    }

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    try {
      // Step 1: Get admin token
      final tokenResponse = await ioClient.post(
        Uri.parse('https://stage.aashniandco.com/rest/V1/integration/admin/token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': 'mahesh',
          'password': 'mahesh@123',
        }),
      );

      if (tokenResponse.statusCode != 200) {
        print("Failed to generate token: ${tokenResponse.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to authenticate.')),
        );
        return;
      }

      final token = json.decode(tokenResponse.body); // plain token
      final sku = widget.product['prod_sku'];
      print("SKU>>>$sku");

      // Step 2: Get child products of configurable
      final response = await ioClient.get(
        Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$sku/children'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> children = json.decode(response.body);

        final matchedChild = children.firstWhere(
              (child) => child['sku'].toString().toLowerCase().endsWith(selectedSize.toLowerCase()),
          orElse: () => null,
        );

        if (matchedChild != null) {
          final matchedSku = matchedChild['sku'];
          print("Selected SKU: $matchedSku");

          // Save selected product with matched SKU to local storage
          final selectedProduct = {
            ...widget.product,
            'selectedSize': selectedSize,
            'childSku': matchedSku,
          };
          await saveProductToPrefs(selectedProduct);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product added to cart")),
          );

          // Navigate to cart screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Size $selectedSize not available.')),
          );
        }
      } else {
        print("Failed to fetch child SKUs: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred.')),
      );
    }
  }


  Future<void> saveProductToPrefs(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();

    // Optional: Normalize the field names if needed
    final selectedProduct = {
      'name': product['name'] ?? '',
      'prodSmallImg': product['prodSmallImg'] ?? '',
      'selectedSize': product['selectedSize'] ?? '',
      'actualPrice': product['actual_price_1'] ?? '', // Make sure CartScreen expects 'actualPrice'
      'designer_name': product['designer_name'] ?? '',
      'short_desc': product['short_desc'] ?? '',
      'childSku': product['childSku'] ?? '',
    };

    final existing = prefs.getStringList('cartItems') ?? [];
    existing.add(json.encode(selectedProduct));
    await prefs.setStringList('cartItems', existing);
  }


  // Future<void> onAddToCartPressed() async {
  //
  //   if (selectedSize.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select a size')),
  //     );
  //     return;
  //   }
  //
  //   HttpClient httpClient = HttpClient();
  //   httpClient.badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   final sku = widget.product['prod_sku'];
  //   print("SKU>>>$sku");
  //   final response = await ioClient.get(
  //     Uri.parse('https://stage.aashniandco.com/rest/V1/configurable-products/$sku/children'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer bgcvi74rodh85vay2yaj7e6leob2dk4w',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> children = json.decode(response.body);
  //     final matchedChild = children.firstWhere(
  //           (child) => child['sku'].toString().toLowerCase().endsWith(selectedSize.toLowerCase()),
  //       orElse: () => null,
  //     );
  //     print("Status code: ${response.statusCode}");
  //     print("Response body: ${response.body}");
  //     if (matchedChild != null) {
  //       final matchedSku = matchedChild['sku'];
  //       // 🛒 Now use `matchedSku` to call your Add-to-Cart API
  //       print("Selected SKU: $matchedSku");
  //
  //       // Example: call addToCart(matchedSku);
  //     } else {
  //       print("No SKU found for size: $selectedSize");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Size $selectedSize not available.')),
  //       );
  //     }
  //   } else {
  //     print("Failed to fetch child SKUs");
  //   }
  // }




  @override
  Widget build(BuildContext context) {
    print("cust_id$customer_id");
    // Extract small and thumbnail images
    final List<String> images = [
      if (widget.product['prod_small_img'] != null) widget.product['prod_small_img'],
      if (widget.product['prod_thumb_img'] != null) widget.product['prod_thumb_img'],
    ];




    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome $firstName $lastName $customer_id", style: const TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Scrollable Content (Product Details)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel
                  SizedBox(
                    height: 400,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),


                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product['designer_name'] ?? "Unknown Designer",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(widget.product['short_desc'] ?? "No description available",
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text("₹${widget.product['actual_price_1'] ?? 'N/A'}",
                            style: const TextStyle(fontSize: 20, color: Colors.black)),
                        const SizedBox(height: 5),
                        Text("SKU: ${widget.product['prod_sku'] ?? 'N/A'}",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),


                  // Size Selector
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Size Selection Grid
                        SizedBox(
                          height: (sizes.length / 4).ceil() * 80,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: sizes.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSizeIndex = index;
                                    selectedSize = sizes[index];
                                    print(">>>>>$selectedSize");
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black),
                                    color: selectedSizeIndex == index ? Colors.black : Colors.white,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    sizes[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: selectedSizeIndex == index ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),


                        const SizedBox(height: 10),


                        // 🔹 Size Chart Button (Separate from Grid)
                        GestureDetector(
                          onTap: () => _showSizeChartDialog(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "Size Chart",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.insert_chart, size: 24, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),




                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    // child: const Text("Ships In: 3-4 Weeks", style: TextStyle(fontSize: 14, color: Colors.black)),

                    child: Text(
                      "Ship In: ${(widget.product['child_delivery_time'] is List)
                          ? widget.product['child_delivery_time'].join(", ")
                          : widget.product['child_delivery_time'] ?? "No description available"}",
                      style: const TextStyle(fontSize: 14),
                    ),

                  ),
                  const SizedBox(height: 15),


                  // Buy Now & Add to Cart Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(60, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            child: const Text("BUY NOW", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            // onPressed: () {
                            //
                            //
                            // },
                            onPressed: onAddToCartPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(60, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            child: const Text("ADD TO CART", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 10),


                  // Expandable Sections
                  ExpansionTile(
                    title: const Text("DETAILS", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          (widget.product['prod_desc'] is List)
                              ? widget.product['prod_desc'].join(", ")
                              : widget.product['prod_desc'] ?? "No description available",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("DISCLAIMER", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Disclaimer:\n"
                              "This product is made to order.\n"
                              "Product color may slightly vary due to photographic lighting sources or your monitor setting.\n"
                              "For any sizing queries please connect with us on +91 83750 36648\n\n"
                              "${widget.product['disclaimer'] ?? 'No disclaimer available.'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),


          // ✅ Fixed Bottom Section (Customer Support)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: Column(
              children: [
                const Text("CUSTOMER SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _supportButton(Icons.chat, "Chat With Us", () {
                      _openWhatsApp("+918375036648");
                    }),
                    _supportButton(Icons.phone, "+91 8375036648", () {
                      _makePhoneCall("+918375036648");
                    }),
                    _supportButton(Icons.email, "Mail us", () {
                      _sendEmail("support@example.com");
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );


  }


  Widget _supportButton(IconData icon, String text, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          onPressed: onPressed,
        ),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }




  void _openWhatsApp(String phone) async {
    String url;


    if (Platform.isAndroid) {
      url = "whatsapp://send?phone=$phone";
    } else if (Platform.isIOS) {
      print("whatsapp IOS clicked>>");
      url = "https://wa.me/$phone";
    } else {
      url = "https://wa.me/$phone";
    }


    // Ensure launchUrl is called
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }




  void _makePhoneCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");


    if (await canLaunchUrl(url)) {
      print("Launching dialer...");
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("Error: Cannot launch dialer for $phone");
    }
  }




  void _sendEmail(String email) async {
    final Uri url = Uri.parse("mailto:$email"); // ✅ Correct scheme


    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Could not launch email for $email");
    }
  }








}


// class ProductDetailNewInDetailScreen extends StatefulWidget {
//   final Product product;
//
//   const ProductDetailNewInDetailScreen({super.key, required this.product});
//
//   @override
//   State<ProductDetailNewInDetailScreen> createState() => _ProductDetailNewInDetailScreenState();
// }
//
// class _ProductDetailNewInDetailScreenState extends State<ProductDetailNewInDetailScreen> {
//   int selectedSizeIndex = 0; // Default selected size
//   // List<String> sizes = ["S", "M", "L"]; // Dummy size options
//   List<String> sizes = [];
//   late PageController _pageController;
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(widget.product.designerName, style: const TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.shopping_cart),
//             onPressed: () {
//               // Navigate to cart screen
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Product Image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   widget.product.prodSmallImg,
//                   width: double.infinity,
//                   height: 500,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     height: 500,
//                     color: Colors.grey[300],
//                     alignment: Alignment.center,
//                     child: const Icon(Icons.image_not_supported, size: 50),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Designer Name
//               Center(
//                 child: Text(
//                   widget.product.designerName,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//
//               // Description
//               Center(
//                 child: Text(
//                   widget.product.shortDesc,
//                   style: const TextStyle(fontSize: 14, color: Colors.black54),
//                   maxLines: 2,
//                   textAlign: TextAlign.center,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Price
//               Center(
//                 child: Text(
//                   "₹${widget.product.actualPrice.toStringAsFixed(0)}",
//                   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Add to Cart Button
//               Center(
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Add to cart logic
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(
//                       'Add to Cart',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               // Product Specs
//               const Text(
//                 'Product Specifications',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//
//               const SizedBox(height: 8),
//
//               const Text(
//                 '• Material: Cotton\n• Color: Beige\n• Fit: Regular\n• Wash Care: Dry Clean Only',
//                 style: TextStyle(fontSize: 14),
//               ),
//
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
