// lib/features/category_products/bloc/category_products_bloc.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:meta/meta.dart';

// Assuming these are defined elsewhere
import 'package:aashni_app/constants/api_constants.dart';

import '../../newin/model/new_in_model.dart';
import 'category_products_event.dart';
import 'category_products_state.dart';


class CategoryProductsBloc extends Bloc<CategoryProductsEvent, CategoryProductsState> {
  CategoryProductsBloc() : super(CategoryProductsLoading()) {
    on<FetchProductsForCategory>(_onFetchProductsForCategory);
  }

  Future<void> _onFetchProductsForCategory(
      FetchProductsForCategory event, Emitter<CategoryProductsState> emit) async {
    emit(CategoryProductsLoading());

    // Use the categoryName from the event to make the query dynamic
    final String categoryName = event.categoryName.toLowerCase();
    print("cat name$categoryName");
    final uri = Uri.parse(ApiConstants.url);

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final Map<String, dynamic> body = {
        "queryParams": {
          // ✅ DYNAMIC QUERY: Use the category name from the event
          "query": 'categories-store-1_name:("$categoryName")',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time",
            "rows": "1400000",
            "sort": "prod_en_id desc"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
// 👇 Add this to print the response body
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // It's safer to check the structure before accessing indices
        if (decoded is List && decoded.length > 1 && decoded[1]['docs'] is List) {
          final docs = decoded[1]['docs'] as List;
          final products = docs.map((doc) => Product.fromJson(doc)).toList();

          print("Products>> ");
          emit(CategoryProductsLoaded(products: products));
        } else {
          emit(CategoryProductsError("Invalid response format from server."));
        }
      } else {
        emit(CategoryProductsError("Failed to load products. Status code: ${response.statusCode}"));
      }
    } on SocketException {
      emit(CategoryProductsError("No internet connection. Please check your network."));
    } catch (e) {
      emit(CategoryProductsError("An unexpected error occurred: $e"));
    }
  }
}