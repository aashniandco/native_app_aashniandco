// lib/features/category_products/bloc/category_products_event.dart


import 'package:flutter/cupertino.dart';

@immutable
abstract class CategoryProductsEvent {}

// Event to trigger fetching data for a specific category
class FetchProductsForCategory extends CategoryProductsEvent {
  final String categoryName;

  FetchProductsForCategory({required this.categoryName});
}