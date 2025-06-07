import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Map<String, dynamic>> items;
  final double totalCartWeight;
  final bool isUpdating; // Useful for showing loading indicators on specific items

  const CartLoaded({
    required this.items,
    this.totalCartWeight = 0.0,
    this.isUpdating = false,
  });

  CartLoaded copyWith({
    List<Map<String, dynamic>>? items,
    double? totalCartWeight,
    bool? isUpdating,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      totalCartWeight: totalCartWeight ?? this.totalCartWeight,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [items, totalCartWeight, isUpdating];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}

// These states are optional but can be useful for showing specific feedback
class CartItemUpdated extends CartState {}
class CartItemRemoved extends CartState {}