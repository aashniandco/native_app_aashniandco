import 'package:aashni_app/features/auth/data/auth_repository.dart';
import 'package:aashni_app/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;
  final AuthRepository _authRepository;

  CartBloc({
    required CartRepository cartRepository,
    required AuthRepository authRepository,
  })  : _cartRepository = cartRepository,
        _authRepository = authRepository,
        super(CartInitial()) {
    on<FetchCartItems>(_onFetchCartItems);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<UpdateCartItemQty>(_onUpdateCartItemQty);
  }

  // Central helper method to get a complete, consistent cart state.
  Future<CartLoaded> _loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ Use the correct key and handle null case
    final customerId = prefs.getInt('user_customer_id');

    if (customerId == null) {
      // If user is not logged in, return an empty cart state
      return  CartLoaded(items: [], totalCartWeight: 0.0);
    }

    // Fetch all data in parallel for efficiency
    final results = await Future.wait([
      _cartRepository.getCartItems(),
      _cartRepository.fetchCartTotalWeight(customerId),
    ]);

    final items = results[0] as List<Map<String, dynamic>>;
    final weight = results[1] as double;

    return CartLoaded(items: items, totalCartWeight: weight);
  }

  Future<void> _onFetchCartItems(FetchCartItems event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final loadedState = await _loadCartData();
      emit(loadedState);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    // 1. Optimistic UI update
    final optimisticItems = List<Map<String, dynamic>>.from(currentState.items)
      ..removeWhere((item) => item['item_id'] == event.itemId);
    emit(currentState.copyWith(items: optimisticItems, isUpdating: true));

    try {
      // 2. Perform the actual network call
      await _cartRepository.removeItem(event.itemId);

      // 3. After success, fetch ALL fresh data to ensure consistency.
      final finalState = await _loadCartData();
      emit(finalState);
    } catch (e) {
      emit(CartError("Failed to remove item."));
      // On failure, revert to the state before the optimistic update
      emit(currentState);
    }
  }

  Future<void> _onUpdateCartItemQty(UpdateCartItemQty event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    // 1. Optimistic UI update for instant feedback
    final optimisticItems = currentState.items.map((item) {
      if (item['item_id'] == event.itemId) {
        return {...item, 'qty': event.newQty}; // Create a new map with updated qty
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: optimisticItems, isUpdating: true));

    try {
      // 2. Await the actual API call.
      await _cartRepository.updateCartItemQty(event.itemId, event.newQty);

      // 3. ✅ CORRECTED: After success, call _loadCartData to get the final, consistent state.
      final finalState = await _loadCartData();
      emit(finalState);
    } catch (e) {
      emit(CartError("Failed to update quantity."));
      // On failure, revert to the original state
      emit(currentState);
    }
  }
}