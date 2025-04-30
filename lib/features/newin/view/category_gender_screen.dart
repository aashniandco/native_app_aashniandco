import 'dart:convert';

import 'package:flutter/material.dart';

import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:http/http.dart'as http;
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

class CategoryGenderScreen extends StatefulWidget {
  const CategoryGenderScreen({super.key});

  @override
  State<CategoryGenderScreen> createState() => _CategoryGenderScreenState();
}

class _CategoryGenderScreenState extends State<CategoryGenderScreen> {
  final List<Map<String, dynamic>> gender = [
    {
      "name": "Men",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    },
    {
      "name": "Women",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    }
  ];

  // List<Map<String, dynamic>> fetchedProducts = [];
  //
  // Future<List<dynamic>> fetchProductsByGender(String genderName) async {
  //   const String url = "https://stage.aashniandco.com/rest/V1/solr/search";
  //
  //   try {
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     final Map<String, dynamic> body = {
  //       "queryParams": {
  //         "query": 'gender_name:("$genderName")',
  //         "params": {
  //           "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,color_name",
  //           "rows": "100"
  //         }
  //       }
  //     };
  //
  //     final response = await ioClient.post(
  //       Uri.parse(url),
  //       headers: {
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode(body),
  //     );
  //
  //     print("📡 Status Code: ${response.statusCode}");
  //     print("📨 Raw Body: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //
  //       if (decoded is List) {
  //         final Map<String, dynamic>? docsWrapper = decoded.firstWhere(
  //               (e) => e is Map<String, dynamic> && e.containsKey('docs'),
  //           orElse: () => {},
  //         );
  //         return docsWrapper?['docs'] ?? [];
  //       } else {
  //         throw Exception("Unexpected response format");
  //       }
  //     } else {
  //       throw Exception("Failed to fetch products: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("❌ Error fetching data: $e");
  //     return [];
  //   }
  // }
  //

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Gender"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gender.length,
              itemBuilder: (context, index) {
                final category = gender[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3D4D3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: const EdgeInsets.only(bottom: 12),
                      title: Row(
                        children: [
                          Checkbox(
                            value: category["isSelected"],
                            onChanged: (bool? value) {
                              setState(() {
                                gender[index]["isSelected"] = value!;
                                if (value) {
                                  for (var child in category["children"]) {
                                    child["isSelected"] = false;
                                  }
                                }
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              category["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const SizedBox.shrink(),
                      initiallyExpanded: category["isExpanded"],
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          gender[index]["isExpanded"] = expanded;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          /// Apply Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  List<Map<String, dynamic>> selected = [];

                  for (var cat in gender) {
                    if (cat["isSelected"] == true) {
                      // selected.add({"theme": cat["name"], "id": null});
                      selected.add({
                        "theme": cat["name"],
                        "gender": cat["name"], // 👈 Add this line
                        "id": null,
                      });
                    }
                    for (var child in cat["children"]) {
                      if (child["isSelected"] == true) {
                        selected.add({
                          "theme": cat["name"],
                          "subCategory": child["name"],
                          "id": child["id"]
                        });
                      }
                    }
                  }

                  final selectedThemes = selected
                      .where((item) => item["id"] == null && item["theme"] != null)
                      .map((e) => e["theme"] as String)
                      .toList();

                  final selectedSubcategories = selected
                      .where((item) => item["subCategory"] != null)
                      .map((item) => {
                    "subCategory": item["subCategory"],
                    "id": item["id"],
                    "isSelected": true,
                  })
                      .toList();

                  final subcategoryText =
                  selectedSubcategories.map((e) => e["subCategory"]).join(", ");
                  final themeText = selectedThemes.join(", ");

                  final combinedText = [
                    if (themeText.isNotEmpty) themeText,
                    if (subcategoryText.isNotEmpty) subcategoryText
                  ].join(" • ");

                  if (selected.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewInProductsScreen(
                          selectedCategories: selected,
                          subcategory: combinedText,
                          initialTab: selectedThemes.isNotEmpty
                              ? selectedThemes.first
                              : (selectedSubcategories.isNotEmpty
                              ? selectedSubcategories.first["subCategory"]
                              : ''),
                          productListBuilder: (category, sort) {
                            return CategoryResultScreen(
                              selectedCategories: selectedSubcategories,
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Apply",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
// class CategoryGenderScreen extends StatefulWidget {
//   const CategoryGenderScreen({super.key});
//
//   @override
//   State<CategoryGenderScreen> createState() => _CategoryGenderScreenState();
// }
//
// class _CategoryGenderScreenState extends State<CategoryGenderScreen> {
//
//   final List <Map<String,dynamic>>gender= [
//
//     {
//
//       "name": "Men",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//
//     },
//
//     {
//       "name": "Women",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     }
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       appBar:AppBar(
//         title: Text("Select Gender"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: gender.length,
//               itemBuilder: (context, index) {
//                 final category = gender[index];
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFD3D4D3),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.15),
//                         blurRadius: 4,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Theme(
//                     data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//                     child: ExpansionTile(
//                       tilePadding: const EdgeInsets.symmetric(horizontal: 16),
//                       childrenPadding: const EdgeInsets.only(bottom: 12),
//                       title: Row(
//                         children: [
//                           Checkbox(
//                             value: category["isSelected"],
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 gender[index]["isSelected"] = value!;
//                                 if (value) {
//                                   for (var child in category["children"]) {
//                                     child["isSelected"] = false;
//                                   }
//                                 }
//                               });
//                             },
//                           ),
//                           Expanded(
//                             child: Text(
//                               category["name"],
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       trailing: const SizedBox.shrink(),
//                       initiallyExpanded: category["isExpanded"],
//                       onExpansionChanged: (bool expanded) {
//                         setState(() {
//                           gender[index]["isExpanded"] = expanded;
//                         });
//                       },
//
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           /// Apply Button
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//
//                 onPressed: () {
//                   List<Map<String, dynamic>> selected = [];
//
//                   // Populate selected categories and subcategories
//                   for (var cat in gender) {
//                     if (cat["isSelected"] == true) {
//                       selected.add({"theme": cat["name"], "id": null});
//                     }
//                     for (var child in cat["children"]) {
//                       if (child["isSelected"] == true) {
//                         selected.add({
//                           "theme": cat["name"],
//                           "subCategory": child["name"],
//                           "id": child["id"]
//                         });
//                       }
//                     }
//                   }
//
//                   // // Build selected subcategories
//                   // final List<Map<String, dynamic>> selectedSubcategories = [];
//                   // for (final mainCategory in gender) {
//                   //   for (final sub in mainCategory['children']) {
//                   //     if (sub['isSelected'] == true) {
//                   //       selectedSubcategories.add({
//                   //         "subCategory": sub['name'],
//                   //         "id": sub['id'],
//                   //         "isSelected": true,
//                   //       });
//                   //     }
//                   //   }
//                   // }
//                   //
//                   // if (selected.any((item) => item["subCategory"] != null)) {
//                   //   // ✅ Navigate if any subcategory is selected
//                   //   final selectedSubcategoryNames = selected
//                   //       .where((item) => item["subCategory"] != null)
//                   //       .map((e) => e["subCategory"] as String)
//                   //       .toList();
//                   //
//                   //   Navigator.push(
//                   //     context,
//
//                   final selectedThemes = selected
//                       .where((item) => item["id"] == null && item["theme"] != null)
//                       .map((e) => e["theme"] as String)
//                       .toList();
//
//
//                   final selectedSubcategories = selected
//                       .where((item) => item["subCategory"] != null)
//                       .map((item) => {
//                     "subCategory": item["subCategory"],
//                     "id": item["id"],
//                     "isSelected": true,
//                   })
//                       .toList();
//
//
//                   final subcategoryText = selectedSubcategories.map((e) => e["subCategory"]).join(", ");
//                   final themeText = selectedThemes.join(", ");
//
//
//                   // Combine both if needed
//                   final combinedText = [
//                     if (themeText.isNotEmpty) themeText,
//                     if (subcategoryText.isNotEmpty) subcategoryText
//                   ].join(" • ");
//
//
//                   if (selected.isNotEmpty) {
//                     Navigator.push(
//                       context,
//
//                       MaterialPageRoute(
//                         builder: (_) => NewInProductsScreen(
//                           selectedCategories: selected,
//                           subcategory: combinedText,
//                           initialTab: selectedThemes.isNotEmpty
//                               ? selectedThemes.first
//                               : (selectedSubcategories.isNotEmpty
//                               ? selectedSubcategories.first["subCategory"]
//                               : ''),
//                           productListBuilder: (category, sort) {
//                             return CategoryResultScreen(
//                               selectedCategories: selectedSubcategories,
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   }
//                 }
//
//                 ,
//
//                 child: const Text(
//                   "Apply",
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }
//
