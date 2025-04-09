import 'dart:convert';
import 'dart:io';
import 'package:aashni_app/features/product_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class DesignerDetailScreen extends StatefulWidget {
  final String designerName;
  DesignerDetailScreen({required this.designerName});

  @override
  _DesignerDetailScreenState createState() => _DesignerDetailScreenState();
}

class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
  bool isLoading = true;
  List<dynamic> products = [];
  String selectedSort = "High to Low"; // Default sorting order

  @override
  void initState() {
    super.initState();
    fetchDesignerDetails(widget.designerName);
  }

//   Future<void> fetchDesignerDetails() async {
//     final encodedName = Uri.encodeComponent(widget.designerName);
//     final url = Uri.parse(
//         "https://stage.aashniandco.com/rest/V1/solr/designer?designer_name=$encodedName");
//
//     print("$url");
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         List<dynamic> allProducts = jsonResponse['response']['docs'];
//
//         // Filter out products where actual_price_1 is 0
//         List<dynamic> filteredProducts = allProducts.where((product) {
//           var price = product['actual_price_1'];
//           return price != null && price != 0 && price.toString() != '0';
//         }).toList();
// print("$filteredProducts");
//         setState(() {
//           products = filteredProducts;
//           sortProducts(); // Apply sorting after fetching data
//           isLoading = false;
//         });
//       } else {
//         throw Exception("Failed to load designer details");
//       }
//     } catch (e) {
//       print("Error fetching details: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

  Future<void> fetchDesignerDetails(String designerName) async {
    final String url = 'https://stage.aashniandco.com/rest/V1/solr/designer?designer_name=$designerName';

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

      IOClient ioClient = IOClient(httpClient);
      final response = await ioClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response Data: $data');

        // ✅ Check if API response is a list
        if (data is List && data.length > 1) {
          var docs = data[1]['docs'];

          // ✅ Ensure `docs` is a list
          if (docs is! List) {
            print("Error: Expected a list but got ${docs.runtimeType}");
            setState(() {
              isLoading = false;
            });
            return;
          }

          List<dynamic> allProducts = docs;

          // ✅ Filter products safely
          List<dynamic> filteredProducts = allProducts.where((product) {
            var price = product['actual_price_1'];
            return price != null && price is int && price > 0;
          }).toList();

          print("Filtered Products: ${filteredProducts.length}");

          setState(() {
            products = filteredProducts;
            sortProducts();
            isLoading = false;
          });
        } else {
          print("Error: Unexpected API response format");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        isLoading = false;
      });
    }
  }




  void sortProducts() {
    setState(() {
      if (selectedSort == "High to Low") {
        products.sort((a, b) => (b['actual_price_1'] ?? 0).compareTo(a['actual_price_1'] ?? 0));
      } else {
        products.sort((a, b) => (a['actual_price_1'] ?? 0).compareTo(b['actual_price_1'] ?? 0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designerName),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(child: Text("No data available"))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown for sorting
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  // borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedSort,
                  icon: const Icon(Icons.sort, color: Colors.black),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  dropdownColor: Colors.grey,
                  underline: Container(), // Remove default underline
                  onChanged: (newValue) {
                    setState(() {
                      selectedSort = newValue!;
                      sortProducts();
                    });
                  },
                  items: ["High to Low", "Low to High"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Expanded to take remaining space
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.5, // Decrease this to increase height
                ),
                itemBuilder: (context, index) {
                  final item = products[index];
                  return GestureDetector(
                    onTap: () {
                      print("Designer Data: ${jsonEncode(item)}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: item),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Increased Image Height
                          Flexible(
                            child: Image.network(
                              item['prod_small_img'] ?? item['prod_thumb_img'] ?? '',
                              width: double.infinity,
                              height: 550, // Increase height
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 550, // Match the height
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported, size: 50),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Designer Name
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Center(
                              child: Text(
                                item['designer_name'] ?? "Unknown",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          // Short Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Center(
                              child: Text(
                                item['short_desc'] ?? "No description",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          // Price
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(
                              child: Text(
                                "₹${item['actual_price_1'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
