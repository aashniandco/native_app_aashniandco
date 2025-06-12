// lib/features/checkout/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ✅ REMOVED: flutter_multi_formatter is no longer needed.
import 'package:flutter_stripe/flutter_stripe.dart'; // ✅ IMPORT STRIPE
import 'package:intl/intl.dart';

// Your BLoC and Screen imports (adjust paths as needed)
import '../../shoppingbag/ shipping_bloc/shipping_bloc.dart';
import '../../shoppingbag/ shipping_bloc/shipping_event.dart';
import '../../shoppingbag/ shipping_bloc/shipping_state.dart';
import 'order_success_screen.dart';

// ✅ REMOVED: CardDetails model is no longer needed.

class PaymentScreen extends StatefulWidget {
  final List<dynamic> paymentMethods;
  final Map<String, dynamic> totals;
  final Map<String, dynamic> billingAddress;

  const PaymentScreen({
    Key? key,
    required this.paymentMethods,
    required this.totals,
    required this.billingAddress,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isBillingSameAsShipping = true;
  // Local state for immediate button feedback while talking to Stripe
  bool _isProcessing = false;

  final NumberFormat _currencyFormat =
  NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  Widget build(BuildContext context) {
    final stripePaymentMethod = widget.paymentMethods.firstWhere(
          (m) => m['code'] == 'stripe_payments',
      orElse: () => null,
    );
    final cartItemQty = (widget.totals['items_qty'] as num?)?.toInt() ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: BlocListener<ShippingBloc, ShippingState>(
        listener: (context, state) {
          // Stop all loading indicators on a final state
          if (state is PaymentSuccess || state is ShippingError) {
            if (mounted) {
              setState(() { _isProcessing = false; });
            }
          }

          if (state is PaymentSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => OrderSuccessScreen(orderId: state.orderId)),
                  (route) => false,
            );
          } else if (state is ShippingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment Failed: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          // ✅ A Form widget is no longer needed for the card details
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEstimatedTotal(widget.totals['grand_total'], cartItemQty),
              const SizedBox(height: 24),
              Text('Payment Method',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              if (stripePaymentMethod != null) ...[
                // ✅ USE THE NEW, SECURE STRIPE WIDGET
                _buildStripePaymentSection(),
                const SizedBox(height: 24),
                _buildPlaceOrderButton(),
                const SizedBox(height: 24),
                _buildBillingAddressSection(),
              ] else
                const Text("No supported payment methods available."),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ THIS WIDGET IS NOW SECURE AND PCI-COMPLIANT
  Widget _buildStripePaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            // You can replace this with a local asset if you prefer
            Image.network('https://i.imgur.com/khpvoZl.png', height: 20),
          ],
        ),
        const SizedBox(height: 16),
        // --- Use Stripe's secure, pre-built CardField widget ---
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: CardField(
            onCardChanged: (details) {
              // You can use this callback to enable/disable the place order button
              // based on whether the card details are complete.
              print('Card details complete: ${details?.complete}');
            },
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.lock, color: Colors.green, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your card details are protected using PCI DSS v3.2 security standards.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return BlocBuilder<ShippingBloc, ShippingState>(
      builder: (context, state) {
        // Disable button if BLoC is working OR if we are talking to Stripe
        final isSubmitting = state is PaymentSubmitting || _isProcessing;
        return ElevatedButton(
          onPressed: isSubmitting ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: isSubmitting
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          )
              : const Text('PLACE ORDER'),
        );
      },
    );
  }

  // ✅ THIS IS THE CORE LOGIC IMPLEMENTATION
  // lib/features/checkout/payment_screen.dart

// ✅ THIS IS THE CORE LOGIC FOR THE WORKAROUND
  // lib/features/checkout/payment_screen.dart

// ✅ THIS IS THE CORE LOGIC FOR THE WORKAROUND
  // lib/features/checkout/payment_screen.dart

  void _placeOrder() async {
    // Start local loading indicator immediately for better UX
    if (mounted) {
      setState(() { _isProcessing = true; });
    }

    try {
      // ------------------- START OF THE FINAL FIX -------------------
      // STEP 1: Create a modern "PaymentMethod" instead of a legacy token.
      // This will generate a payment method with a 'pm_...' prefix.
      print("--- 1. Requesting MODERN PaymentMethod from Stripe... ---");
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(), // Uses data from the CardField
        ),
      );

      print("--- 2. Stripe API Response (PaymentMethod Success!) ---");
      print("PaymentMethod ID: ${paymentMethod.id}"); // This will be like "pm_card_..."
      print("Card Brand: ${paymentMethod.card.brand}");
      print("Card Last 4: ${paymentMethod.card.last4}");
      print("-----------------------------------------------------");

      // STEP 2: Dispatch the event to your BLoC with the modern PaymentMethod ID.
      if (mounted) {
        print("--- 3. Dispatching event to ShippingBloc... ---");
        context.read<ShippingBloc>().add(
          SubmitPaymentInfo(
            paymentMethodCode: 'stripe_payments',
            billingAddress: widget.billingAddress,
            // Pass the modern 'pm_...' ID here. Your backend is ready for this.
            paymentMethodNonce: paymentMethod.id,
          ),
        );
      }
      // -------------------- END OF THE FINAL FIX --------------------

    } on StripeException catch (e) {
      // This catches errors from Stripe's side (e.g., invalid card, network error).
      print("--- Stripe SDK Error ---");
      print(e.error.localizedMessage ?? e.toString());
      print("-------------------------");
      if (mounted) {
        setState(() { _isProcessing = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.error.localizedMessage ?? "An unknown error occurred"}')),
        );
      }
    } catch (e) {
      // This catches any other unexpected errors.
      print("--- Generic Error ---");
      print(e.toString());
      print("----------------------");
      if (mounted) {
        setState(() { _isProcessing = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    }
  }

  // --- Omitted for brevity, your existing _buildEstimatedTotal and _buildBillingAddressSection methods are fine ---
  Widget _buildEstimatedTotal(dynamic grandTotalValue, int qty) {
    final grandTotal = (grandTotalValue as num?)?.toDouble() ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estimated Total', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                _currencyFormat.format(grandTotal),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  qty.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('My billing and shipping address are the same'),
          value: _isBillingSameAsShipping,
          onChanged: (bool? value) {
            setState(() {
              _isBillingSameAsShipping = value ?? true;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (_isBillingSameAsShipping) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              '${widget.billingAddress['firstname']} ${widget.billingAddress['lastname']}\n'
                  '${widget.billingAddress['street']?.join(', ')}\n'
                  '${widget.billingAddress['city']}, ${widget.billingAddress['region']} ${widget.billingAddress['postcode']}\n'
                  '${widget.billingAddress['country_id']}\n' // You might want to map this ID to a full country name
                  '${widget.billingAddress['telephone']}',
              style: const TextStyle(height: 1.5, color: Colors.black87),
            ),
          )
        ]
        // You can add another form here if the checkbox is unchecked
      ],
    );
  }
}