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
// import 'new_in_state.dart';
// part 'new_in_event.dart';
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

    final url = Uri.parse("https://stage.aashniandco.com/rest/V1/solr/newin");

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.get(url, headers: {"Connection": "keep-alive"});

      if (response.statusCode == 200) {
        final List<dynamic> responseList = jsonDecode(response.body);
        final Map<String, dynamic> productData = responseList[1];
        final List<dynamic> docs = productData['docs'];

        final List<Product> products = docs.map((json) => Product.fromJson(json)).toList();

        emit(NewInLoaded(products: products));
      } else {
        emit(NewInError("Failed to load products"));
      }
    } catch (e) {
      emit(NewInError("Error: $e"));
    }
  }

}