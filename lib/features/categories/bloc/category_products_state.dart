// lib/features/category_products/bloc/category_products_state.dart



import '../../newin/model/new_in_model.dart';

abstract class CategoryProductsState {}

class CategoryProductsLoading extends CategoryProductsState {}

class CategoryProductsLoaded extends CategoryProductsState {
  final List<Product> products; // Assuming you have a Product model

  CategoryProductsLoaded({required this.products});
}

class CategoryProductsError extends CategoryProductsState {
  final String message;

  CategoryProductsError(this.message);
}