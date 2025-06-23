
import 'package:aashni_app/features/auth/view/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../bloc/order_details_bloc.dart';
import '../bloc/order_details_event.dart';
import '../bloc/order_details_state.dart';
import '../model/order_details_model.dart';
import '../repositories/order_repository.dart';

class OrderSuccessScreen extends StatelessWidget {
  final int orderId;

  const OrderSuccessScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The main build method remains the same
    return BlocProvider(
      create: (context) => OrderDetailsBloc(orderRepository: OrderRepository())
        ..add(FetchOrderDetails(orderId)),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
            builder: (context, state) {
              if (state is OrderDetailsLoading || state is OrderDetailsInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is OrderDetailsFailure) {
                return Center( /* ... Error UI remains the same ... */ );
              }

              if (state is OrderDetailsSuccess) {
                final order = state.order;
                final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, order.orderId),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildOrderDetails(context, order.orderDate),
                        const SizedBox(height: 24),
                        Text(
                          'Order Information',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildAddresses(context, order.shippingAddress, order.billingAddress),
                        const SizedBox(height: 24),
                        _buildMethods(context, order.shippingMethod, order.paymentMethod),
                        const SizedBox(height: 32),
                        // ✅ CALLING THE NEW, REDESIGNED WIDGET
                        _buildItemsOrdered(context, order.items, currencyFormat),
                        const SizedBox(height: 32),
                        _buildStatusTracker(context, order.status),
                        const SizedBox(height: 32),
                        _buildTotals(context, order.totals, currencyFormat),
                        const SizedBox(height: 48),
                        SizedBox( /* ... Button remains the same ... */ ),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // --- Helper widgets are mostly the same, except for the item list ---
  // ... _buildHeader, _buildOrderDetails, etc. are unchanged ...

  // ✅ ENTIRELY NEW AND IMPROVED WIDGET FOR THE ITEM LIST
  Widget _buildItemsOrdered(BuildContext context, List<OrderItem> items, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Items Ordered', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // We use a Column to list our new custom cards vertically
        Column(
          children: items.map((item) => _buildOrderItemCard(context, item, currencyFormat)).toList(),
        ),
      ],
    );
  }

  // ✅ THIS IS THE NEW MOBILE-FRIENDLY CARD WIDGET THAT REPLACES DATATABLE
  Widget _buildOrderItemCard(BuildContext context, OrderItem item, NumberFormat currencyFormat) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          // Top section: Image + Name/SKU/Options
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              SizedBox(
                width: 80,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (item.options.isNotEmpty) ...[
                      Text(item.options, style: textTheme.bodyMedium),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'SKU: ${item.sku}',
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          // Bottom section: Price, Qty, Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Price', currencyFormat.format(item.price), context),
              _buildMetric('Qty', item.qty.toString(), context),
              _buildMetric('Subtotal', currencyFormat.format(item.subtotal), context, isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for the small price/qty/subtotal metrics
  Widget _buildMetric(String label, String value, BuildContext context, {bool isBold = false}) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  Widget _buildHeader(BuildContext context, String orderNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thank you for your purchase!', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
            children: [
              const TextSpan(text: 'Your order number is: '),
              TextSpan(
                text: orderNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We'll email you an order confirmation with details and tracking info.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildOrderDetails(BuildContext context, String orderDateStr) {
    String formattedDate = orderDateStr;
    try {
      final dateTime = DateTime.parse(orderDateStr);
      formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order details:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Order Date: $formattedDate', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildAddresses(BuildContext context, Address? shipping, Address? billing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildAddressColumn(context, 'Shipping Address', shipping)),
        const SizedBox(width: 16),
        Expanded(child: _buildAddressColumn(context, 'Billing Address', billing)),
      ],
    );
  }

  Widget _buildAddressColumn(BuildContext context, String title, Address? address) {
    if (address == null) return const SizedBox.shrink();

    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
        const SizedBox(height: 12),
        Text(address.name, style: bodyStyle),
        Text(address.street, style: bodyStyle),
        Text(address.cityPostcode, style: bodyStyle),
        Text(address.country, style: bodyStyle),
        Text(address.telephone, style: bodyStyle),
      ],
    );
  }

  Widget _buildMethods(BuildContext context, String shippingMethod, PaymentMethod paymentMethod) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shipping Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 12),
              Text(shippingMethod, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 12),
              Text(paymentMethod.title, style: Theme.of(context).textTheme.bodyMedium),
              const Divider(height: 16),
              _buildKeyValueRow('', paymentMethod.details, context: context),
            ],
          ),
        ),
      ],
    );
  }


  DataRow _buildItemRow(BuildContext context, OrderItem item, NumberFormat currencyFormat) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final nameStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);

    return DataRow(
      cells: [
        DataCell(
          // ✅ Use a ConstrainedBox to give the cell a max-width, preventing overflow.
          // This works better with DataTable's layout calculations.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250), // Adjust this width as needed
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // ✅ Add mainAxisAlignment to center the text vertically in the cell.
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        style: nameStyle,
                        overflow: TextOverflow.ellipsis,
                        // ✅ Use maxLines to prevent text from wrapping and causing vertical overflow.
                        maxLines: 2,
                      ),
                      if (item.options.isNotEmpty)
                        Text(
                          item.options,
                          style: textStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(Text(item.sku, style: textStyle)),
        DataCell(Text(currencyFormat.format(item.price), style: textStyle)),
        DataCell(Text(item.qty.toString(), style: textStyle)),
        DataCell(Text(currencyFormat.format(item.subtotal), style: textStyle)),
      ],
    );
  }
  Widget _buildStatusTracker(BuildContext context, String currentStatus) {
    return Row(
      children: [
        const Text('Order Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            currentStatus,
            style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTotals(BuildContext context, Totals totals, NumberFormat currencyFormat) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final grandTotalStyle = textStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 20);

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 300,
        child: Column(
          children: [
            _buildKeyValueRow('Subtotal', currencyFormat.format(totals.subtotal), context: context, style: textStyle),
            const SizedBox(height: 8),
            _buildKeyValueRow('Shipping & Handling', currencyFormat.format(totals.shipping), context: context, style: textStyle),
            const Divider(height: 24, thickness: 1),
            _buildKeyValueRow('Grand Total', currencyFormat.format(totals.grandTotal), context: context, style: grandTotalStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyValueRow(String label, String value, {
    required BuildContext context,
    TextStyle? style,
  }) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium;

    return Row(
      // We no longer need mainAxisAlignment.spaceBetween
      children: [
        // Wrap the label in an Expanded widget.
        // This makes it take up all available space, pushing the value to the right.
        Expanded(
          child: Text(
            label,
            style: effectiveStyle,
          ),
        ),
        // The value will now be aligned to the right, taking up only the space it needs.
        Text(
          value,
          style: effectiveStyle,
        ),
      ],
    );
  }
}