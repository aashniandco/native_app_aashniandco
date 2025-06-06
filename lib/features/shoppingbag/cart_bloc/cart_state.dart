abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Map<String, dynamic>> items;
  final double totalCartWeight;
  final double shippingEstimate;
  final bool isUpdating;
  CartLoaded({
    required this.items,
    this.totalCartWeight = 0.0,
    this.shippingEstimate = 0.0,
    this.isUpdating = false,
  });

  // copyWith is essential for creating new states based on the old one
  CartLoaded copyWith({
    List<Map<String, dynamic>>? items,
    double? totalCartWeight,
    double? shippingEstimate,
    bool? isUpdating,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      totalCartWeight: totalCartWeight ?? this.totalCartWeight,
      shippingEstimate: shippingEstimate ?? this.shippingEstimate,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

}

class CartError extends CartState {
  final String message;
  CartError(this.message);
}

class CartItemUpdated extends CartState {
  final int itemId;
  final int qty;
  CartItemUpdated(this.itemId, this.qty);
}

class CartItemRemoved extends CartState {
  final int itemId;
  CartItemRemoved(this.itemId);
}
