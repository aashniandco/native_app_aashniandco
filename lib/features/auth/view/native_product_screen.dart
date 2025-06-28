import 'package:flutter/material.dart';

class NativeProductScreen extends StatelessWidget {
  // This screen accepts the URL of the product/banner that was clicked.
  final String url;

  const NativeProductScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    // You can parse the URL here to get a product ID, name, etc.
    // For this example, we just display the full URL.

    return Scaffold(
      appBar: AppBar(
        title: const Text("Native Product Page"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Navigation Intercepted!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Instead of the WebView navigating, we have opened this native Flutter screen with the following link:",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                url,
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}