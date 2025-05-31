

import '../repository/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  List<Map<String, dynamic>> currentItems = [];

  CartBloc() : super(CartInitial()) {
    on<FetchCartItems>(_onFetchCartItems);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<UpdateCartItemQty>(_onUpdateCartItemQty);
  }

  Future<void> _onFetchCartItems(FetchCartItems event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await CartRepository().getCartItems();
      currentItems = List.from(items);
      emit(CartLoaded(currentItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) async {
    try {
      // Optimistically remove locally
      currentItems.removeWhere((item) => item['item_id'] == event.itemId);
      emit(CartLoaded(List.from(currentItems))); // Emit new state immediately

      final success = await CartRepository().removeItem(event.itemId);

      if (!success) {
        // Rollback if needed, or refetch
        add(FetchCartItems());
      }
    } catch (e) {
      emit(CartError("Failed to remove item"));
    }
  }

  Future<void> _onUpdateCartItemQty(UpdateCartItemQty event, Emitter<CartState> emit) async {
    try {
      // Optimistically update qty locally
      for (var item in currentItems) {
        if (item['item_id'] == event.itemId) {
          item['qty'] = event.newQty;
          break;
        }
      }
      emit(CartLoaded(List.from(currentItems))); // Emit new state immediately

      final updatedQty = await CartRepository().updateCartItemQty(event.itemId, event.newQty);

      if (updatedQty == null || updatedQty != event.newQty) {
        // Rollback or refetch if failed or inconsistent
        add(FetchCartItems());
      }
    } catch (e) {
      emit(CartError("Failed to update quantity"));
    }
  }
}

