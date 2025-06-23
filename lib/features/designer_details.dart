import 'dart:convert';
import 'dart:io';
import 'package:aashni_app/features/product_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'newin/view/product_details_newin.dart';

class DesignerDetailScreen extends StatefulWidget {
  final String designerName;
  DesignerDetailScreen({required this.designerName});

  @override
  _DesignerDetailScreenState createState() => _DesignerDetailScreenState();
}

class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
  bool isLoading = true;
  List<dynamic> products = []; // Holds the original fetched product list
  List<dynamic> sortedProducts = []; // Holds the list to be displayed and sorted
  String selectedSort = "Latest"; // Default sorting order

  @override
  void initState() {
    super.initState();
    fetchDesignerDetails(widget.designerName);
  }

  Future<void> fetchDesignerDetails(String designerName) async {
    // Using Uri.encodeComponent to handle names with spaces or special characters
    final encodedName = Uri.encodeComponent(designerName);
    final String url = 'https://stage.aashniandco.com/rest/V1/solr/designer?designer_name=$encodedName';

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);
      final response = await ioClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.length > 1 && data[1]['docs'] is List) {
          List<dynamic> allProducts = data[1]['docs'];
          List<dynamic> filteredProducts = allProducts.where((product) {
            var price = product['actual_price_1'];
            return price != null && (price is num && price > 0);
          }).toList();

          setState(() {
            products = filteredProducts;
            sortProducts(); // Apply initial sorting
            isLoading = false;
          });
        } else {
          throw Exception("Unexpected API response format");
        }
      } else {
        throw Exception('Failed to load designer details: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching designer details: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void sortProducts() {
    // Always sort from the original 'products' list to ensure correctness
    sortedProducts = List<dynamic>.from(products);

    if (selectedSort == "High to Low") {
      sortedProducts.sort((a, b) => (b['actual_price_1'] ?? 0).compareTo(a['actual_price_1'] ?? 0));
    } else if (selectedSort == "Low to High") {
      sortedProducts.sort((a, b) => (a['actual_price_1'] ?? 0).compareTo(b['actual_price_1'] ?? 0));
    } else if (selectedSort == "Latest") {
      // Sort by entity_id in descending order to get the latest products first
      sortedProducts.sort((a, b) {
        final idA = int.tryParse(a['entity_id']?.toString() ?? '0') ?? 0;
        final idB = int.tryParse(b['entity_id']?.toString() ?? '0') ?? 0;
        return idB.compareTo(idA);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.designerName),
        backgroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sortedProducts.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(
              //   "${sortedProducts.length} Items",
              //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              // ),
              Text(
               ""
              ),
              Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<String>(
                  value: selectedSort,
                  icon: const Icon(Icons.sort, color: Colors.black),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  dropdownColor: Colors.white,
                  underline: Container(), // Hides the default underline
                  onChanged: (value) {
                    setState(() {
                      selectedSort = value!;
                      sortProducts();
                    });
                  },
                  items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
                    return DropdownMenuItem<String>(
                      value: sortOption,
                      child: Text(sortOption, style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Product Grid
          Expanded(
            child: GridView.builder(
              itemCount: sortedProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.5,
              ),
              itemBuilder: (context, index) {
                final item = sortedProducts[index];
                return GestureDetector(
                  onTap: () {
                    print("Designer Data: ${jsonEncode(item)}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // ProductDetailNewInDetailScreen(product: item.toJson()),
                        builder: (context) => ProductDetailNewInDetailScreen(product: item),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 1,
                    clipBehavior: Clip.antiAlias, // Ensures content respects card corners
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Flexible(
                          child: Image.network(
                            item['prod_small_img'] ?? item['prod_thumb_img'] ?? '',
                            width: double.infinity,
                            height: 550,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 550,
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
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                              "₹${(item['actual_price_1'] as num?)?.toStringAsFixed(0) ?? 'N/A'}",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
    );
  }
}