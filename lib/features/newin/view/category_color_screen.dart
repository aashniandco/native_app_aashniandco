import 'package:aashni_app/features/newin/view/category_result_tes_screen.dart';
import 'package:flutter/material.dart';

import '../bloc/newin_products_bloc.dart';
import '../bloc/product_repository.dart';
import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryColorScreen extends StatefulWidget {
  const CategoryColorScreen({super.key});

  @override
  State<CategoryColorScreen> createState() => _CategoryColorScreenState();
}

class _CategoryColorScreenState extends State<CategoryColorScreen> {
  final List<Map<String, dynamic>> color = [
    {"name": "Black", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Blue", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Brown", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Burgundy", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Green", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Grey", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Metallic", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Multicolor", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Neutrals", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Orange", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Peach", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Pink", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Print", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Purple", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Red", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Gold", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Silver", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "White", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Yellow", "isExpanded": false, "isSelected": false, "children": []},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Color"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: color.length,
              itemBuilder: (context, index) {
                final category = color[index];
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
                                color[index]["isSelected"] = value!;
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
                      initiallyExpanded: category["isExpanded"],
                      onExpansionChanged: (bool expanded) {
                        setState(() {
                          color[index]["isExpanded"] = expanded;
                        });
                      },
                      children: (category["children"] as List).map<Widget>((child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Checkbox(
                                value: child["isSelected"] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    child["isSelected"] = value!;
                                  });
                                },
                              ),
                              Expanded(child: Text(child["name"] ?? "")),
                            ],
                          ),
                        );
                      }).toList(),
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
                  List<Map<String, dynamic>> selectedColors = [];

                  for (var cat in color) {
                    if (cat["isSelected"] == true) {
                      selectedColors.add({
                        "theme": cat["name"],
                        "color": cat["name"],
                        "id": null,
                      });
                    }
                    for (var child in cat["children"]) {
                      if (child["isSelected"] == true) {
                        selectedColors.add({
                          "theme": cat["name"],
                          "subCategory": child["name"],
                          "id": child["id"]
                        });
                      }
                    }
                  }

                  if (selectedColors.isNotEmpty) {
                    final selectedNames = selectedColors
                        .map((item) => item["color"] ?? item["subCategory"])
                        .join(", ");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => NewInProductsBloc(
                            productRepository: ProductRepository(),
                            subcategory: selectedNames,
                            selectedCategories: selectedColors,
                          ),
                          child: NewInProductsScreen(
                            selectedCategories: selectedColors,
                            subcategory: selectedNames,
                            initialTab: selectedColors.first["color"] ?? '',
                            productListBuilder: (category, sort) {
                              return CategoryResultScreen(
                                selectedCategories: selectedColors,
                              );
                            },
                          ),
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


// class CategoryColorScreen extends StatefulWidget {
//   const CategoryColorScreen({super.key});
//
//   @override
//   State<CategoryColorScreen> createState() => _CategoryColorScreenState();
// }
//
// class _CategoryColorScreenState extends State<CategoryColorScreen> {
//
//   final List <Map<String,dynamic>>color= [
//
//     {
//
//       "name": "Black",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//
//     },
//
//     {
//       "name": "Blue",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "Brown",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Burgundy",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "Green",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Grey",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Metallic",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Multicolor",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Neutrals",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Orange",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Peach",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Pink",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Print",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Purple",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Red",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Gold",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Silver",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "White",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Yellow",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
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
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: color.length,
//               itemBuilder: (context, index) {
//                 final category = color[index];
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
//                                 color[index]["isSelected"] = value!;
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
//                           color[index]["isExpanded"] = expanded;
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
//                   for (var cat in color) {
//                     if (cat["isSelected"] == true) {
//                       // selected.add({"theme": cat["name"], "id": null});
//
//                       selected.add({
//                         "theme": cat["name"],
//                         "color": cat["name"], // 👈 Add this line
//                         "id": null,
//                       });
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
//
//                   // Build selected subcategories
//                   final List<Map<String, dynamic>> selectedSubcategories = [];
//                   for (final mainCategory in color) {
//                     for (final sub in mainCategory['children']) {
//                       if (sub['isSelected'] == true) {
//                         selectedSubcategories.add({
//                           "subCategory": sub['name'],
//                           "id": sub['id'],
//                           "isSelected": true,
//                         });
//                       }
//                     }
//                   }
//
//                   if (selected.any((item) => item["subCategory"] != null)) {
//                     // ✅ Navigate if any subcategory is selected
//                     final selectedSubcategoryNames = selected
//                         .where((item) => item["subCategory"] != null)
//                         .map((e) => e["subCategory"] as String)
//                         .toList();
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => NewInProductsScreen(
//                           selectedCategories: selected,
//                           subcategory: selectedSubcategoryNames.join(", "),
//                           initialTab: selectedSubcategoryNames.isNotEmpty
//                               ? selectedSubcategoryNames.first
//                               : '',
//                           productListBuilder: (category, sort) {
//                             return CategoryResultScreen(
//                               selectedCategories: selectedSubcategories,
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   } else if (selected.length == 1 && selected[0]["id"] == null) {
//                     // ✅ Navigate when only theme (like Contemporary or Ethnic) is selected
//                     String themeName = selected[0]["theme"];
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => NewInProductsScreen(
//                           selectedCategories: selected,
//                           subcategory: themeName,
//                           initialTab: themeName,
//                           productListBuilder: (category, sort) {
//                             return CategoryResultScreen(
//                               selectedCategories: [],
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   }
//                 }
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
