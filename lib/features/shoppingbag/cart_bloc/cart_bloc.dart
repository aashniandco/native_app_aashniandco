

import '../../auth/data/auth_repository.dart';
import '../repository/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  List<Map<String, dynamic>> currentItems = [];

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


  // Helper method to fetch all derived data
  Future<CartLoaded> _loadCartData() async {


    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('customer_id');
    print("Stored customer_id: $customerId ");// Or your _loadUserNames()
    final items = await _cartRepository.getCartItems();
    final weight = await _cartRepository.fetchCartTotalWeight(customerId!);
    // final shipping = await _shippingRepository.estimateShipping(weight); // Example

    return CartLoaded(
      items: items,
      totalCartWeight: weight,
      // shippingEstimate: shipping
    );
  }




  Future<void> _onFetchCartItems(FetchCartItems event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      // Fetch all necessary data at once and emit a complete state
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

    // Emit the optimistic state, keeping old weight for now but flagging it as updating
    emit(currentState.copyWith(items: optimisticItems, isUpdating: true));

    try {
      // 2. Perform the actual network call and wait for it
      await _cartRepository.removeItem(event.itemId);

      // 3. After success, fetch ALL fresh data to ensure consistency
      final finalState = await _loadCartData();
      emit(finalState); // This will have the correct items, weight, and shipping

    } catch (e) {
      // If it fails, revert to the previous state and show an error
      emit(CartError("Failed to remove item."));
      // Then emit the original state to restore the UI
      emit(currentState);
    }
  }
  Future<void> _onUpdateCartItemQty(UpdateCartItemQty event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    // 1. Optimistic UI update: Create a new list with the updated quantity
    final optimisticItems = currentState.items.map((item) {
      if (item['item_id'] == event.itemId) {
        return {...item, 'qty': event.newQty}; // Create a new map with updated qty
      }
      return item;
    }).toList();

    // Emit the new state immediately for a responsive UI
    // Mark as updating so the UI can show a subtle indicator if desired
    emit(currentState.copyWith(items: optimisticItems, isUpdating: true));

    try {
      // 2. AWAIT the actual API call. This is the key to solving the race condition.
      await _cartRepository.updateCartItemQty(event.itemId, event.newQty);

      // 3. AFTER the update succeeds, fetch the new weight and any other data.
      final prefs = await SharedPreferences.getInstance();
      final customerId= prefs.getInt('customer_id');
      print("Stored customer_id: $customerId");
      final newWeight = await _cartRepository.fetchCartTotalWeight(customerId!);
      // final newShipping = await _shippingRepository.estimateShipping(newWeight);

      // 4. Emit the final, fully consistent state.
      // We use the optimisticItems list and just update the derived data.
      emit(currentState.copyWith(
        items: optimisticItems,
        totalCartWeight: newWeight,
        // shippingEstimate: newShipping,
        isUpdating: false, // Done updating
      ));
    } catch (e) {
      emit(CartError("Failed to update quantity."));
      // On failure, revert to the state before the optimistic update
      emit(currentState);
    }
  }
}


