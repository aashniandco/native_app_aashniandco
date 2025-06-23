import 'package:aashni_app/features/newin/view/category_result_tes_screen.dart';
import 'package:flutter/material.dart';


import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/newin_products_bloc.dart';
import '../../bloc/product_repository.dart';
import '../category_result_screen.dart';
import '../new_in_products_screen.dart';

class CategoryFilterCategoryScreen extends StatefulWidget {
  final String categoryName;
  const CategoryFilterCategoryScreen ({super.key, required this.categoryName});

  @override
  State<CategoryFilterCategoryScreen > createState() => _CategoryFilterCategoryScreenState();
}

class _CategoryFilterCategoryScreenState extends State<CategoryFilterCategoryScreen > {





  final List<Map<String, dynamic>> filter = [
    {"name": "Accessories", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Bags", "isSelected": false, "id": 101},
        {"name": "Shoes", "isSelected": false, "id": 102},
        {"name": "Scarves & Stoles", "isSelected": false, "id": 103},
        {"name": "Belts", "isSelected": false, "id": 104},
      ],},
    {"name": "Jewelry", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Earrings", "isSelected": false, "id": 101},
        {"name": "Necklaces", "isSelected": false, "id": 102},
        {"name": "Jewelry Sets", "isSelected": false, "id": 103},
        {"name": "Bangles & Bracelets", "isSelected": false, "id": 104},
        {"name": "Nose rings", "isSelected": false, "id": 101},
        {"name": "Hair Accessories", "isSelected": false, "id": 102},
        {"name": "Hand Harness", "isSelected": false, "id": 103},
        {"name": "Fine Jewelry", "isSelected": false, "id": 104},
        {"name": "Rings", "isSelected": false, "id": 101},
        {"name": "Foot Harness", "isSelected": false, "id": 102},
        {"name": "Brooches", "isSelected": false, "id": 103},



      ], },
    {"name": "Kidswear", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Kurta Sets for Boys", "isSelected": false, "id": 201},
        {"name": "Lehengas", "isSelected": false, "id": 202},
        {"name": "Dresses", "isSelected": false, "id": 203},
        {"name": "Shararas", "isSelected": false, "id": 204},
        {"name": "Kurta Sets for Girls", "isSelected": false, "id": 205},
        {"name": "Bandi Set", "isSelected": false, "id": 206},
        {"name": "Shirts", "isSelected": false, "id": 207},
        {"name": "Jackets", "isSelected": false, "id": 208},
        {"name": "Co-ord set", "isSelected": false, "id": 209},
        {"name": "Kids Accessories", "isSelected": false, "id": 210},
        {"name": "Dhoti sets", "isSelected": false, "id": 211},
        {"name": "Crop Top And Skirt Sets", "isSelected": false, "id": 212},
        {"name": "Anarkalis", "isSelected": false, "id": 213},
        {"name": "Bandhgalas", "isSelected": false, "id": 214},
        {"name": "Gowns", "isSelected": false, "id": 215},
        {"name": "Jumpsuit", "isSelected": false, "id": 216},
        {"name": "Sherwanis", "isSelected": false, "id": 217},
        {"name": "Achkan", "isSelected": false, "id": 218},
        {"name": "Bags", "isSelected": false, "id": 219},
        {"name": "Sarees", "isSelected": false, "id": 220},
        {"name": "Tops", "isSelected": false, "id": 221},
        {"name": "Skirts", "isSelected": false, "id": 222},
        {"name": "Pants", "isSelected": false, "id": 223},
      ] },

    {"name": "Men", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Kurta Sets", "isSelected": false, "id": 301},
        {"name": "Men's Accessories", "isSelected": false, "id": 302},
        {"name": "Sherwanis", "isSelected": false, "id": 303},
        {"name": "Jackets", "isSelected": false, "id": 304},
        {"name": "Kurtas", "isSelected": false, "id": 305},
        {"name": "Shirts", "isSelected": false, "id": 306},
        {"name": "Bandi Sets", "isSelected": false, "id": 307},
        {"name": "Shoes", "isSelected": false, "id": 308},
        {"name": "Bandhgalas", "isSelected": false, "id": 309},
        {"name": "Blazers", "isSelected": false, "id": 310},
        {"name": "Bandis", "isSelected": false, "id": 311},
        {"name": "Trousers", "isSelected": false, "id": 312},
        {"name": "Nehru Jackets", "isSelected": false, "id": 313},
        {"name": "Co-ords", "isSelected": false, "id": 314},
      ] },

    {"name": "Women's Clothing", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Kurta Sets", "isSelected": false, "id": 401},
        {"name": "Lehengas", "isSelected": false, "id": 402},
        {"name": "Saris", "isSelected": false, "id": 403},
        {"name": "Dresses", "isSelected": false, "id": 404},
        {"name": "Co-ords", "isSelected": false, "id": 405},
        {"name": "Jackets", "isSelected": false, "id": 406},
        {"name": "Sharara Sets", "isSelected": false, "id": 407},
        {"name": "Tops", "isSelected": false, "id": 408},
        {"name": "Anarkalis", "isSelected": false, "id": 409},
        {"name": "Kaftans", "isSelected": false, "id": 410},
        {"name": "Gowns", "isSelected": false, "id": 411},
        {"name": "Pants", "isSelected": false, "id": 412},
        {"name": "Capes", "isSelected": false, "id": 413},
        {"name": "Tunics & Kurtis", "isSelected": false, "id": 414},
        {"name": "Jumpsuits", "isSelected": false, "id": 415},
        {"name": "Kurtas", "isSelected": false, "id": 416},
        {"name": "Skirts", "isSelected": false, "id": 417},
        {"name": "Palazzo Sets", "isSelected": false, "id": 418},
        {"name": "Beach", "isSelected": false, "id": 419},
      ]},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Category"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filter.length,
              itemBuilder: (context, index) {
                final category = filter[index];
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
                                filter[index]["isSelected"] = value!;
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
                          filter[index]["isExpanded"] = expanded;
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
    List<Map<String, dynamic>> selectedFilter = [];

    for (var cat in filter) {
    if (cat["isSelected"] == true) {
    selectedFilter.add({
    "theme": cat["name"],
    "filter": cat["name"],
    "id": null,
    });
    }
    for (var child in cat["children"]) {
    if (child["isSelected"] == true) {
    selectedFilter.add({
    "theme": cat["name"],
    "subCategory": child["name"],
    "id": child["id"]
    });
    }
    }
    }

    if (selectedFilter.isNotEmpty) {
    // Collecting selected subcategories for navigation
    final selectedNames = selectedFilter
        .map((item) => item["subCategory"] ?? item["filter"])
        .where((name) => name != null)
        .join(", ");

    // Check if "Bags" is in selected subcategories
    // final selectedSubcategory = selectedFilter
    //     .firstWhere((item) => item["subCategory"] == "Bags", orElse: () => {});
// Get the first valid selected subcategory
      final selectedSubcategory = selectedFilter
          .firstWhere(
            (item) => item["subCategory"] != null,
        orElse: () => {}, // Return an empty map if no subcategory is selected
      );

    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => BlocProvider(
    create: (_) => NewInProductsBloc(
    productRepository: ProductRepository(),
    subcategory: selectedNames,
    selectedCategories: selectedFilter,
    ),
    child: NewInProductsScreen(
    selectedCategories: selectedFilter,
    subcategory: selectedSubcategory["subCategory"] ?? '',
    initialTab: selectedFilter.first["filter"] ?? '',
    productListBuilder: (category, sort) {
    return CategoryResultScreen(
    selectedCategories: selectedFilter,
    );
    },
    ),
    ),
    ),
    );
    }
    },

    // onPressed: () {
                //   List<Map<String, dynamic>> selectedFilter = [];
                //
                //   for (var cat in filter) {
                //     if (cat["isSelected"] == true) {
                //       selectedFilter.add({
                //         "theme": cat["name"],
                //         "filter": cat["name"],
                //         "id": null,
                //       });
                //     }
                //     for (var child in cat["children"]) {
                //       if (child["isSelected"] == true) {
                //         selectedFilter.add({
                //           "theme": cat["name"],
                //           "subCategory": child["name"],
                //           "id": child["id"]
                //         });
                //       }
                //     }
                //   }
                //
                //   if (selectedFilter.isNotEmpty) {
                //     // Collecting selected subcategories for navigation
                //     final selectedNames = selectedFilter
                //         .map((item) => item["subCategory"] ?? item["filter"])
                //         .where((name) => name != null)
                //         .join(", ");
                //
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => BlocProvider(
                //           create: (_) => NewInProductsBloc(
                //             productRepository: ProductRepository(),
                //             subcategory: selectedNames,
                //             selectedCategories: selectedFilter,
                //           ),
                //           child: NewInProductsScreen(
                //             selectedCategories: selectedFilter,
                //             subcategory: selectedNames,
                //             initialTab: selectedFilter.first["filter"] ?? '',
                //             productListBuilder: (category, sort) {
                //               return CategoryResultScreen(
                //                 selectedCategories: selectedFilter,
                //               );
                //             },
                //           ),
                //         ),
                //       ),
                //     );
                //   }
                // },
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

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text("Select Category"),
  //       backgroundColor: Colors.white,
  //       foregroundColor: Colors.black,
  //       elevation: 1,
  //     ),
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: filter.length,
  //             itemBuilder: (context, index) {
  //               final category = filter[index];
  //               return Container(
  //                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFD3D4D3),
  //                   borderRadius: BorderRadius.circular(12),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.grey.withOpacity(0.15),
  //                       blurRadius: 4,
  //                       offset: const Offset(0, 3),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Theme(
  //                   data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
  //                   child: ExpansionTile(
  //                     tilePadding: const EdgeInsets.symmetric(horizontal: 16),
  //                     childrenPadding: const EdgeInsets.only(bottom: 12),
  //                     title: Row(
  //                       children: [
  //                         Checkbox(
  //                           value: category["isSelected"],
  //                           onChanged: (bool? value) {
  //                             setState(() {
  //                               filter[index]["isSelected"] = value!;
  //                             });
  //                           },
  //                         ),
  //                         Expanded(
  //                           child: Text(
  //                             category["name"],
  //                             style: const TextStyle(
  //                               fontWeight: FontWeight.w600,
  //                               fontSize: 16,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     initiallyExpanded: category["isExpanded"],
  //                     onExpansionChanged: (bool expanded) {
  //                       setState(() {
  //                         filter[index]["isExpanded"] = expanded;
  //                       });
  //                     },
  //                     children: (category["children"] as List).map<Widget>((child) {
  //                       return Padding(
  //                         padding: const EdgeInsets.symmetric(horizontal: 16),
  //                         child: Row(
  //                           children: [
  //                             Checkbox(
  //                               value: child["isSelected"] ?? false,
  //                               onChanged: (bool? value) {
  //                                 setState(() {
  //                                   child["isSelected"] = value!;
  //                                 });
  //                               },
  //                             ),
  //                             Expanded(child: Text(child["name"] ?? "")),
  //                           ],
  //                         ),
  //                       );
  //                     }).toList(),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //
  //         /// Apply Button
  //         Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.black,
  //                 padding: const EdgeInsets.symmetric(vertical: 16),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //               ),
  //
  //               onPressed: () {
  //                 List<Map<String, dynamic>> selectedFilter = [];
  //
  //                 for (var cat in filter) {
  //                   if (cat["isSelected"] == true) {
  //                     selectedFilter.add({
  //                       "theme": cat["name"],
  //                       "filter": cat["name"],
  //                       "id": null,
  //                     });
  //                   }
  //                   for (var child in cat["children"]) {
  //                     if (child["isSelected"] == true) {
  //                       selectedFilter.add({
  //                         "theme": cat["name"],
  //                         "subCategory": child["name"],
  //                         "id": child["id"]
  //                       });
  //                     }
  //                   }
  //                 }
  //
  //                 if (selectedFilter.isNotEmpty) {
  //                   // Collecting selected subcategories for navigation
  //                   final selectedNames = selectedFilter
  //                       .map((item) => item["subCategory"] ?? item["filter"])
  //                       .where((name) => name != null)
  //                       .join(", ");
  //
  //
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (_) => BlocProvider(
  //                         create: (_) => NewInProductsBloc(
  //                           productRepository: ProductRepository(),
  //                           subcategory: selectedNames,
  //                           selectedCategories: selectedFilter,
  //                         ),
  //                         child: NewInProductsScreen(
  //                           selectedCategories: selectedFilter,
  //                           subcategory: selectedNames,
  //                           initialTab: selectedFilter.first["filter"] ?? '',
  //                           productListBuilder: (category, sort) {
  //                             return CategoryResultScreen(
  //                               selectedCategories: selectedFilter,
  //                             );
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 }
  //               },
  //
  //               // onPressed: () {
  //               //   List<Map<String, dynamic>> selectedFilter = [];
  //               //
  //               //   for (var cat in filter) {
  //               //     if (cat["isSelected"] == true) {
  //               //       selectedFilter.add({
  //               //         "theme": cat["name"],
  //               //         "filter": cat["name"],
  //               //         "id": null,
  //               //       });
  //               //     }
  //               //     for (var child in cat["children"]) {
  //               //       if (child["isSelected"] == true) {
  //               //         selectedFilter.add({
  //               //           "theme": cat["name"],
  //               //           "subCategory": child["name"],
  //               //           "id": child["id"]
  //               //         });
  //               //       }
  //               //     }
  //               //   }
  //               //
  //               //   if (selectedFilter.isNotEmpty) {
  //               //     final selectedNames = selectedFilter
  //               //         .map((item) => item["filter"] ?? item["subCategory"])
  //               //         .join(", ");
  //               //
  //               //     Navigator.push(
  //               //       context,
  //               //       MaterialPageRoute(
  //               //         builder: (_) => BlocProvider(
  //               //           create: (_) => NewInProductsBloc(
  //               //             productRepository: ProductRepository(),
  //               //             subcategory: selectedNames,
  //               //             selectedCategories: selectedFilter,
  //               //           ),
  //               //           child: NewInProductsScreen(
  //               //             selectedCategories: selectedFilter,
  //               //             subcategory: selectedNames,
  //               //             initialTab: selectedFilter.first["filter"] ?? '',
  //               //             productListBuilder: (category, sort) {
  //               //               return CategoryResultScreen(
  //               //                 selectedCategories: selectedFilter,
  //               //               );
  //               //             },
  //               //           ),
  //               //         ),
  //               //       ),
  //               //     );
  //               //     ;
  //               //   }
  //               // },
  //               child: const Text(
  //                 "Apply",
  //                 style: TextStyle(fontSize: 16, color: Colors.white),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
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
