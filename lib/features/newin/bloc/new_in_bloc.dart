// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:aashni_app/features/newin/model/new_in_model.dart';
// import 'package:bloc/bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/io_client.dart';
// import 'package:meta/meta.dart';
//
// import 'new_in_theme_state.dart';
// part 'new_in_theme_event.dart';
//
// class NewInBloc extends Bloc<NewInEvent, NewInState> {
//   NewInBloc() : super(NewInLoading()) {
//     on<FetchNewIn>(_onFetchNewIn);
//   }
//
//   Future<void> _onFetchNewIn(
//       FetchNewIn event, Emitter<NewInState> emit) async {
//     emit(NewInLoading());
//
//     final url = Uri.parse("https://stage.aashniandco.com/rest/V1/solr/newin");
//
//     try {
//       // Allow bad SSL certs
  //       HttpClient httpClient = HttpClient();
  //       httpClient.badCertificateCallback =
  //           (X509Certificate cert, String host, int port) => true;
  //       IOClient ioClient = IOClient(httpClient);
//
//       final response = await ioClient.get(
//         url,
//         headers: {"Connection": "keep-alive"},
//       );
//
//       // print('🔁 Raw Response: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//
//         final List<dynamic> productList = jsonData['products'] ?? [];
//
//         print("Parsed product list length: ${productList.length}");
//
//         final List<NewInProduct> products = productList
//             .map((item) => NewInProduct.fromJson(item))
//             .toList();
//
//         emit(NewInLoaded(products: products));
//       } else {
//         emit(NewInError("Failed to fetch products: ${response.statusCode}"));
//       }
//     } catch (e) {
//       emit(NewInError("Error: $e"));
//     }
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aashni_app/constants/api_constants.dart';
import 'package:aashni_app/features/newin/model/new_in_model.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:meta/meta.dart';

import 'new_in_state.dart';




part 'new_in_event.dart';

class NewInBloc extends Bloc<NewInEvent,NewInState>{
  NewInBloc() : super(NewInLoading()) {
    on<FetchNewIn>(_onFetchNewIn);
  }

  // Future<void> _onFetchNewIn(
  //     FetchNewIn event, Emitter<NewInState> emit) async {
  //   emit(NewInLoading());
  //
  //   final url = Uri.parse("https://stage.aashniandco.com/rest/V1/solr/newin");
  //
  //   try {
  //     // Allow bad SSL certs
  //         HttpClient httpClient = HttpClient();
  //         httpClient.badCertificateCallback =
  //             (X509Certificate cert, String host, int port) => true;
  //         IOClient ioClient = IOClient(httpClient);
  //
  //     final response = await ioClient.get(
  //       url,
  //       headers: {"Connection": "keep-alive"},
  //     );
  //
  //     // print('🔁 Raw Response: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final jsonData = jsonDecode(response.body);
  //
  //       final List<dynamic> productList = jsonData['products'] ?? [];
  //
  //       print("Parsed product list length: ${productList.length}");
  //
  //       final List<Product> products = productList
  //           .map((item) => Product.fromJson(item))
  //           .toList();
  //
  //       emit(NewInLoaded(products: products));
  //     } else {
  //       emit(NewInError("Failed to fetch products: ${response.statusCode}"));
  //     }
  //   } catch (e) {
  //     emit(NewInError("Error: $e"));
  //   }
  // }


  Future<void> _onFetchNewIn(
      FetchNewIn event, Emitter<NewInState> emit) async {
    emit(NewInLoading());

    final uri = Uri.parse(ApiConstants.url);

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      // Static subcategory
      final subcategory = 'new in';

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": 'categories-store-1_name:("$subcategory")',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time",
            "rows": "40000",
            "sort": "prod_en_id desc"
          }
        }
      };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();
          emit(NewInLoaded(products: products));
        } else {
          emit(NewInError("Invalid docs format"));
        }
      } else {
        emit(NewInError("Failed with status: ${response.statusCode}"));
      }
    } on SocketException {
      emit(NewInError("No internet connection"));
    } catch (e) {
      emit(NewInError("Error: $e"));
    }
  }



  // Future<void> _onFetchNewIn(
  //     FetchNewIn event, Emitter<NewInState> emit) async {
  //   emit(NewInLoading());
  //
  //   final uri = Uri.parse(ApiConstants.url);
  //
  //   try {
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     // Static subcategory
  //     final subcategory = 'new in';
  //
  //     final Map<String, dynamic> body = {
  //       "queryParams": {
  //         "query": 'categories-store-1_name:("$subcategory")',
  //         "params": {
  //           "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name",
  //           "rows": "40000",
  //           "sort": "prod_en_id desc"
  //         }
  //       }
  //     };
  //
  //     final response = await ioClient.post(
  //       uri,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //       final secondItem = decoded[1];
  //       final docs = secondItem['docs'];
  //
  //       if (docs is List) {
  //         final products = docs.map((doc) => Product.fromJson(doc)).toList();
  //         emit(NewInLoaded(products: products));
  //       } else {
  //         emit(NewInError("Invalid docs format"));
  //       }
  //     } else {
  //       emit(NewInError("Failed with status: ${response.statusCode}"));
  //     }
  //   }
  //   catch (e) {
  //     emit(NewInError("Error: $e"));
  //   }
  // }



// Future<void> _onFetchNewIn(
  //     FetchNewIn event, Emitter<NewInState> emit) async {
  //   emit(NewInLoading());
  //
  //   final url = Uri.parse(ApiConstants.newIn);
  //
  //   try {
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     final response = await ioClient.get(url, headers: {"Connection": "keep-alive"});
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> responseList = jsonDecode(response.body);
  //       final Map<String, dynamic> productData = responseList[1];
  //       final List<dynamic> docs = productData['docs'];
  //
  //       final List<Product> products = docs.map((json) => Product.fromJson(json)).toList();
  //
  //       emit(NewInLoaded(products: products));
  //     } else {
  //       emit(NewInError("Failed to load products"));
  //     }
  //   } catch (e) {
  //     emit(NewInError("Error: $e"));
  //   }
  // }

}