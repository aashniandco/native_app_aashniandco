import 'package:aashni_app/features/newin/bloc/newin_products_bloc.dart';
import 'package:aashni_app/features/newin/view/new_in_products_screen.dart';
import 'package:aashni_app/features/newin/view/plpfilterscreens/contemporary_filter_screen.dart';
import 'package:aashni_app/features/newin/view/plpfilterscreens/ethnic_filter_screen.dart';
import 'package:flutter/material.dart';

import '../bloc/product_repository.dart';
import 'category_result_screen.dart';

// class CategoryThemeScreen extends StatefulWidget {
//   const CategoryThemeScreen({super.key});
//
//   @override
//   State<CategoryThemeScreen> createState() => _CategoryThemeScreenState();
// }
//
// class _CategoryThemeScreenState extends State<CategoryThemeScreen> {
//   final List<Map<String, dynamic>> theme = [
//     {
//       "name": "Contemporary",
//       "isExpanded": false,
//       "isSelected": false,
//       "id": "1372", // Static ID for Contemporary
//     },
//     {
//       "name": "Ethnic",
//       "isExpanded": false,
//       "isSelected": false,
//       "id": "1373", // Static ID for Ethnic
//     }
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Select Theme"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: theme.length,
//               itemBuilder: (context, index) {
//                 final category = theme[index];
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
//                                 theme[index]["isSelected"] = value!;
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
//                           theme[index]["isExpanded"] = expanded;
//                         });
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
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
//                 onPressed: () {
//                   List<Map<String, dynamic>> selected = [];
//
//                   // Populate selected themes
//                   for (var cat in theme) {
//                     if (cat["isSelected"] == true) {
//                       selected.add({
//                         "theme": cat["name"],
//                         "id": cat["id"], // Add selected theme's ID
//                       });
//                     }
//                   }
//
//                   if (selected.isNotEmpty) {
//                     // Log the selected themes
//                     for (var item in selected) {
//                       print("Selected Theme: ${item['theme']}, ID: ${item['id']}");
//                     }
//
//                     // Example API call logging (you can replace this with your actual API logic)
//                     final apiUrl =
//                         "https://stage.aashniandco.com/rest/V1/solr/products?theme_id=${selected.first['id']}&theme_name=${Uri.encodeComponent(selected.first['theme'])}";
//                     print("Calling API: $apiUrl");
//
//                     // Navigate when a theme is selected
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => NewInProductsScreen(
//                           selectedCategories: selected,
//                           subcategory: selected.first["theme"],
//                           initialTab: selected.first["theme"],
//                           productListBuilder: (category, sort) {
//                             return CategoryResultScreen(
//                               selectedCategories: selected,
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   }
//                 },
//
//                 // onPressed: () {
//                 //   List<Map<String, dynamic>> selected = [];
//                 //
//                 //   // Populate selected themes
//                 //   for (var cat in theme) {
//                 //     if (cat["isSelected"] == true) {
//                 //       selected.add({
//                 //         "theme": cat["name"],
//                 //         "id": cat["id"], // Add selected theme's ID
//                 //       });
//                 //     }
//                 //   }
//                 //
//                 //   if (selected.isNotEmpty) {
//                 //     // Navigate when a theme is selected
//                 //     Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //         builder: (_) => NewInProductsScreen(
//                 //           selectedCategories: selected,
//                 //           subcategory: selected.first["theme"],
//                 //           initialTab: selected.first["theme"],
//                 //           productListBuilder: (category, sort) {
//                 //             return CategoryResultScreen(
//                 //               selectedCategories: selected,
//                 //             );
//                 //           },
//                 //         ),
//                 //       ),
//                 //     );
//                 //   }
//                 // },
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
// }
//
//


import 'package:aashni_app/features/newin/view/new_in_products_screen.dart';
import 'package:aashni_app/features/newin/view/plpfilterscreens/contemporary_filter_screen.dart';
import 'package:aashni_app/features/newin/view/plpfilterscreens/ethnic_filter_screen.dart';
import 'package:flutter/material.dart';

import 'category_result_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class CategoryThemeScreen extends StatefulWidget {
  const CategoryThemeScreen({super.key});

  @override
  State<CategoryThemeScreen> createState() => _CategoryThemeScreenState();
}

class _CategoryThemeScreenState extends State<CategoryThemeScreen> {

  final List <Map<String,dynamic>>theme= [

    {

      "name": "Contemporary",
      "isExpanded": false,
      "isSelected": false,
      "children": [],

    },

    {
      "name": "Ethnic",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    }
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar:AppBar(
        title: Text("Select Theme"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: theme.length,
              itemBuilder: (context, index) {
                final category = theme[index];
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
                                theme[index]["isSelected"] = value!;
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
                          theme[index]["isExpanded"] = expanded;
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
                  List<Map<String, dynamic>> selectedThemes = [];

                  for (var cat in theme) {
                    if (cat["isSelected"] == true) {
                      // selected.add({"theme": cat["name"], "id": null});

                      selectedThemes.add({
                        "theme": cat["name"],
                        "themes": cat["name"], // 👈 Add this line
                        "id": null,
                      });
                    }
                    for (var child in cat["children"]) {
                      if (child["isSelected"] == true) {
                        selectedThemes.add({
                          "theme": cat["name"],
                          "subCategory": child["name"],
                          "id": child["id"]
                        });
                      }
                    }
                  }

                  if (selectedThemes.isNotEmpty) {
                    final selectedNames = selectedThemes
                        .map((item) => item["theme"] ?? item["subCategory"])
                        .join(", ");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => NewInProductsBloc(
                            productRepository: ProductRepository(),
                            subcategory: selectedNames,
                            selectedCategories: selectedThemes,
                          ),
                          child: NewInProductsScreen(
                            selectedCategories: selectedThemes,
                            subcategory: selectedNames,
                            initialTab: selectedThemes.first["theme"] ?? '',
                            productListBuilder: (category, sort) {
                              return CategoryResultScreen(
                                selectedCategories: selectedThemes,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                    ;
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





// class CategoryThemeScreen extends StatefulWidget {
//   const CategoryThemeScreen({super.key});
//
//   @override
//   State<CategoryThemeScreen> createState() => _CategoryThemeScreenState();
// }
//
// class _CategoryThemeScreenState extends State<CategoryThemeScreen> {
//
//   final List <Map<String,dynamic>>theme= [
//
//     {
//
//       "name": "Contemporary",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//
//     },
//
//     {
//       "name": "Ethnic",
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
//         title: Text("Select Theme"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//
//         body: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: theme.length,
//                 itemBuilder: (context, index) {
//                   final category = theme[index];
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFD3D4D3),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.15),
//                           blurRadius: 4,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Theme(
//                       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//                       child: ExpansionTile(
//                         tilePadding: const EdgeInsets.symmetric(horizontal: 16),
//                         childrenPadding: const EdgeInsets.only(bottom: 12),
//                         title: Row(
//                           children: [
//                             Checkbox(
//                               value: category["isSelected"],
//                               onChanged: (bool? value) {
//                                 setState(() {
//                                   theme[index]["isSelected"] = value!;
//                                   if (value) {
//                                     for (var child in category["children"]) {
//                                       child["isSelected"] = false;
//                                     }
//                                   }
//                                 });
//                               },
//                             ),
//                             Expanded(
//                               child: Text(
//                                 category["name"],
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         trailing: const SizedBox.shrink(),
//                         initiallyExpanded: category["isExpanded"],
//                         onExpansionChanged: (bool expanded) {
//                           setState(() {
//                             theme[index]["isExpanded"] = expanded;
//                           });
//                         },
//
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             /// Apply Button
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//
//                   onPressed: () {
//                     List<Map<String, dynamic>> selected = [];
//
//                     // Populate selected categories and subcategories
//                     for (var cat in theme) {
//                       if (cat["isSelected"] == true) {
//                         selected.add({"theme": cat["name"], "id": null});
//                       }
//                       for (var child in cat["children"]) {
//                         if (child["isSelected"] == true) {
//                           selected.add({
//                             "theme": cat["name"],
//                             "subCategory": child["name"],
//                             "id": child["id"]
//                           });
//                         }
//                       }
//                     }
//
//                     // Build selected subcategories
//                     final List<Map<String, dynamic>> selectedSubcategories = [];
//                     for (final mainCategory in theme) {
//                       for (final sub in mainCategory['children']) {
//                         if (sub['isSelected'] == true) {
//                           selectedSubcategories.add({
//                             "subCategory": sub['name'],
//                             "id": sub['id'],
//                             "isSelected": true,
//                           });
//                         }
//                       }
//                     }
//
//                     if (selected.any((item) => item["subCategory"] != null)) {
//                       // ✅ Navigate if any subcategory is selected
//                       final selectedSubcategoryNames = selected
//                           .where((item) => item["subCategory"] != null)
//                           .map((e) => e["subCategory"] as String)
//                           .toList();
//
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => NewInProductsScreen(
//                             selectedCategories: selected,
//                             subcategory: selectedSubcategoryNames.join(", "),
//                             initialTab: selectedSubcategoryNames.isNotEmpty
//                                 ? selectedSubcategoryNames.first
//                                 : '',
//                             productListBuilder: (category, sort) {
//                               return CategoryResultScreen(
//                                 selectedCategories: selectedSubcategories,
//                               );
//                             },
//                           ),
//                         ),
//                       );
//                     } else if (selected.length == 1 && selected[0]["id"] == null) {
//                       // ✅ Navigate when only theme (like Contemporary or Ethnic) is selected
//                       String themeName = selected[0]["theme"];
//
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => NewInProductsScreen(
//                             selectedCategories: selected,
//                             subcategory: themeName,
//                             initialTab: themeName,
//                             productListBuilder: (category, sort) {
//                               return CategoryResultScreen(
//                                 selectedCategories: [],
//                               );
//                             },
//                           ),
//                         ),
//                       );
//                     }
//                   }
//                   ,
//
//                   child: const Text(
//                     "Apply",
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//     );
//   }
//
//
// }
