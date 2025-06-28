




import '../../newin/model/new_in_model.dart';

abstract class FilteredProductsState {}

class FilteredProductsLoading extends FilteredProductsState {}

class FilteredProductsLoaded extends FilteredProductsState {
  final List<Product> products;
  final bool hasReachedEnd;
  final String currentSort;

  FilteredProductsLoaded({
    required this.products,
    this.hasReachedEnd = false,
    this.currentSort = "Latest",
  });

  // ADD THIS METHOD
  FilteredProductsLoaded copyWith({
    List<Product>? products,
    bool? hasReachedEnd,
    String? currentSort,
  }) {
    return FilteredProductsLoaded(
      products: products ?? this.products,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentSort: currentSort ?? this.currentSort,
    );
  }
}



class FilteredProductsError extends FilteredProductsState {
  final String message;

  FilteredProductsError(this.message);
}

