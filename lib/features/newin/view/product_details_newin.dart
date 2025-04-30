import 'package:flutter/material.dart';


import '../model/new_in_model.dart';  // Adjust import based on where your Product model is located

class ProductDetailNewInDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailNewInDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailNewInDetailScreen> createState() => _ProductDetailNewInDetailScreenState();
}

class _ProductDetailNewInDetailScreenState extends State<ProductDetailNewInDetailScreen> {
  int selectedSizeIndex = 0; // Default selected size
  // List<String> sizes = ["S", "M", "L"]; // Dummy size options
  List<String> sizes = [];
  late PageController _pageController;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product.designerName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.prodSmallImg,
                  width: double.infinity,
                  height: 500,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 500,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Designer Name
              Center(
                child: Text(
                  widget.product.designerName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Center(
                child: Text(
                  widget.product.shortDesc,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 16),

              // Price
              Center(
                child: Text(
                  "₹${widget.product.actualPrice.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Add to Cart Button
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add to cart logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Product Specs
              const Text(
                'Product Specifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                '• Material: Cotton\n• Color: Beige\n• Fit: Regular\n• Wash Care: Dry Clean Only',
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
