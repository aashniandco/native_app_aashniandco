abstract class CartEvent {}

class FetchCartItems extends CartEvent {}

class RemoveCartItem extends CartEvent {
  final int itemId;
  RemoveCartItem(this.itemId);
}

class UpdateCartItemQty extends CartEvent {
  final int itemId;
  final int newQty;
  UpdateCartItemQty(this.itemId, this.newQty);
}
