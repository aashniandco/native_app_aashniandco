class OrderDetails {
  final String orderId;
  final String orderDate;
  final String status;
  final Address? shippingAddress;
  final Address? billingAddress;
  final String shippingMethod;
  final PaymentMethod paymentMethod;
  final List<OrderItem> items;
  final Totals totals;

  OrderDetails({
    required this.orderId,
    required this.orderDate,
    required this.status,
    this.shippingAddress,
    this.billingAddress,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.items,
    required this.totals,
  });

  // ... inside the OrderDetails class ...

  factory OrderDetails.fromJson(dynamic json) {
    // The API returns a List (JSON Array), not a Map (JSON Object).
    // We must parse it by index.
    if (json is! List || json.length < 9) {
      // Basic validation to prevent crashing if the array is malformed.
      throw const FormatException("Invalid JSON format: Expected an array with at least 9 elements.");
    }

    return OrderDetails(
      // Accessing elements by their position in the array
      orderId: json[0] as String? ?? '',
      orderDate: json[1] as String? ?? '',
      status: json[2] as String? ?? 'N/A',

      shippingAddress: json[3] != null
          ? Address.fromJson(json[3] as Map<String, dynamic>)
          : null,

      billingAddress: json[4] != null
          ? Address.fromJson(json[4] as Map<String, dynamic>)
          : null,

      shippingMethod: json[5] as String? ?? '',

      paymentMethod: PaymentMethod.fromJson(json[6] as Map<String, dynamic>? ?? {}),

      items: (json[7] as List<dynamic>?)
          ?.map((itemJson) => OrderItem.fromJson(itemJson as Map<String, dynamic>))
          .toList() ??
          [],

      totals: Totals.fromJson(json[8] as Map<String, dynamic>? ?? {}),
    );
  }
}

class Address {
  final String name;
  final String street;
  final String city;
  final String postcode;
  final String country;
  final String telephone;

  Address({
    required this.name,
    required this.street,
    required this.city,
    required this.postcode,
    required this.country,
    required this.telephone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] as String? ?? '',
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postcode: json['postcode'] as String? ?? '',
      country: json['country'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
    );
  }

  String get cityPostcode => '$city, $postcode';
}

class PaymentMethod {
  final String title;
  final String details;

  PaymentMethod({required this.title, required this.details});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      title: json['title'] as String? ?? '',
      details: json['details'] as String? ?? 'N/A',
    );
  }
}

class OrderItem {
  final String name;
  final String options;
  final String sku;
  final double price;
  final int qty;
  final double subtotal;
  final String? imageUrl;

  OrderItem({
    required this.name,
    required this.options,
    required this.sku,
    required this.price,
    required this.qty,
    required this.subtotal,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String? ?? '',
      options: json['options'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class Totals {
  final double subtotal;
  final double shipping;
  final double grandTotal;

  Totals({required this.subtotal, required this.shipping, required this.grandTotal});

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}