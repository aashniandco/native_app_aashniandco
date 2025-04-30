
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aashni_app/constants/api_constants.dart';
import 'package:aashni_app/features/designer/model/designer_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart'; // Import for IOClient
part 'designers_event.dart';
part 'designers_state.dart';



class DesignersBloc extends Bloc<DesignersEvent, DesignersState> {
  DesignersBloc() : super(DesignersLoading()) {
    on<FetchDesigners>(_onFetchDesigners);
  }
  final String solrUrl = "https://78b1-114-143-109-126.ngrok-free.app/solr/aashni_dev/select?"
      "q=*:*&fq=categories-store-1_url_path:%22designers%22"
      "&facet=true&facet.field=designer_name&facet.limit=-1";

  // Future<void> _onFetchDesigners(
  //     FetchDesigners event, Emitter<DesignersState> emit) async {
  //   emit(DesignersLoading());
  //   // http://130.61.35.64:8983/solr/aashni_dev/select?q=*:*&fq=categories-store-1_url_path:%22designers%22&facet=true&facet.field=designer_name&facet.limit=-1
  //   final url = Uri.parse(
  //       "http://130.61.35.64:8983/solr/aashni_dev/select?q=*:*&fq=categories-store-1_url_path:%22designers%22&facet=true&facet.field=designer_name&facet.limit=-1");
  //
  //   try {
  //     // ✅ Create a custom HttpClient that ignores SSL certificate validation
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  //
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     final response = await ioClient.get(url, headers: {
  //       "Connection": "keep-alive",
  //     });
  //
  //     // ✅ Print the raw response for debugging
  //     print("Raw API Response: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       print("Parsed JSON Response: $jsonResponse");
  //       final List<dynamic> facetFields =
  //       jsonResponse['facet_counts']['facet_fields']['designer_name'];
  //
  //       List<Designer> designers = facetFields
  //           .where((e) => e is String)
  //           .map((name) => Designer.fromJson(name))
  //           .toList();
  //
  //       emit(DesignersLoaded(designers));
  //     } else {
  //       emit(DesignersError("Failed to load designers: ${response.statusCode}"));
  //     }
  //   } catch (e) {
  //     emit(DesignersError("Error fetching designers: $e"));
  //   }
  // }
}



// import 'dart:async';
// import 'dart:convert';
// import 'package:aashni_app/features/designer/model/new_in_model.dart';
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:http/http.dart' as http;
//
//
// part 'new_in_theme_event.dart';
// part 'new_in_theme_state.dart';
//
// class DesignersBloc extends Bloc<DesignersEvent, DesignersState> {
//   DesignersBloc() : super(DesignersLoading()) {
//     on<FetchDesigners>(_onFetchDesigners);
//   }
//

// prod solr
//   Future<void> _onFetchDesigners(
//       FetchDesigners event, Emitter<DesignersState> emit) async {
//     emit(DesignersLoading());
//
//     final url = Uri.parse(
//         "http://130.61.35.64:8983/solr/aashni_dev/select?q=*:*&fq=categories-store-1_url_path:%22designers%22&facet=true&facet.field=designer_name&facet.limit=-1");
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         final List<dynamic> facetFields =
//         jsonResponse['facet_counts']['facet_fields']['designer_name'];
//
//         List<Designer> designers = facetFields
//             .where((e) => e is String)
//             .map((name) => Designer.fromJson(name))
//             .toList();
//
//         emit(DesignersLoaded(designers));
//       } else {
//         emit(DesignersError("Failed to load designers"));
//       }
//     } catch (e) {
//       emit(DesignersError("Error fetching designers: $e"));
//     }
//   }

//"https://stage.aashniandco.com/rest/V1/solr/products"

Future<void> _onFetchDesigners(
    FetchDesigners event, Emitter<DesignersState> emit) async {
  emit(DesignersLoading());

  final url = Uri.parse(
      ApiConstants.designers);

  try {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.get(
        url, headers: {"Connection": "keep-alive"});

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);

      print("Parsed JSON Response: $jsonResponse");


      if (jsonResponse.isNotEmpty &&
          jsonResponse.last is Map<String, dynamic>) {
        final Map<String, dynamic> facetCounts = jsonResponse.last;

        if (facetCounts.containsKey('facet_fields') &&
            facetCounts['facet_fields'].containsKey('designer_name')) {
          final List<
              dynamic> facetFields = facetCounts['facet_fields']['designer_name'];

          // ✅ Extract only string values (designer names) from facetFields
          List<Designer> designers = [];
          for (int i = 0; i < facetFields.length; i += 2) {
            if (facetFields[i] is String) {
              designers.add(Designer(name: facetFields[i]));
            }
          }

          emit(DesignersLoaded(designers));
        } else {
          emit(DesignersError("Invalid API Response: Missing 'facet_fields'"));
        }
      } else {
        emit(DesignersError("Invalid API Response: Expected a JSON object"));
      }
    } else {
      emit(DesignersError("Failed to load designers: ${response.statusCode}"));
    }
  } catch (e) {
    emit(DesignersError("Error fetching designers: $e"));
  }
}
