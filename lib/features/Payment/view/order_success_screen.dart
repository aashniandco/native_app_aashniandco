// lib/features/checkout/order_success_screen.dart

import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final int orderId;

  const OrderSuccessScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Successful')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              Text(
                'Thank You!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Your Order ID is:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '#$orderId',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to your app's home screen
                  // Replace with your actual home screen route
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}