abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Map<String, dynamic>> items;
  CartLoaded(this.items);
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
