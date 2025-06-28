part of 'filtered_products_bloc.dart';


abstract class FilteredProductsEvent {}

// Event to fetch products based on filters and page number
class FetchFilteredProducts extends FilteredProductsEvent {
  final List<Map<String, dynamic>> selectedFilters;
  final int page;

  FetchFilteredProducts({required this.selectedFilters, this.page = 0});
}

// Event to sort the currently loaded products
class SortProducts extends FilteredProductsEvent {
  final String sortOrder;

  SortProducts(this.sortOrder);
}

