import 'package:aashni_app/features/newin/bloc/newin_products_bloc.dart';
import 'package:aashni_app/features/newin/bloc/product_repository.dart';
import 'package:flutter/material.dart';

import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class CategoryShipinScreen extends StatefulWidget {
  const CategoryShipinScreen({super.key});

  @override
  State<CategoryShipinScreen> createState() => _CategoryShipinScreenState();
}

class _CategoryShipinScreenState extends State<CategoryShipinScreen> {

  final List <Map<String,dynamic>>shipin= [

    {

      "name": "Immediate",
      "isExpanded": false,
      "isSelected": false,
      "children": [],

    },

    {
      "name": "1-2 Weeks",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    }
    ,

    {
      "name": "2-4 Weeks",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    },

    {
      "name": "4-6 Weeks",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    },

    {
      "name": "6-8 Weeks",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    },

    {
      "name": "8 Weeks",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar:AppBar(
        title: Text("Select Ships In"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: shipin.length,
              itemBuilder: (context, index) {
                final category = shipin[index];
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
                                shipin[index]["isSelected"] = value!;
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
                          shipin[index]["isExpanded"] = expanded;
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
                  List<Map<String, dynamic>> selectedShipsin = [];

                  // Populate selected categories and subcategories
                  for (var cat in shipin) {
                    if (cat["isSelected"] == true) {
                      // selected.add({"theme": cat["name"], "id": null});
                      selectedShipsin.add({
                        "theme": cat["name"],
                        "shipin": cat["name"], // 👈 Add this line
                        "id": null,
                      });
                    }
                    for (var child in cat["children"]) {
                      if (child["isSelected"] == true) {
                        selectedShipsin.add({
                          "theme": cat["name"],
                          "subCategory": child["name"],
                          "id": child["id"]
                        });
                      }
                    }
                  }

                  if (selectedShipsin.isNotEmpty) {
                    final selectedNames = selectedShipsin
                        .map((item) => item["color"] ?? item["subCategory"])
                        .join(", ");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => NewInProductsBloc(
                            productRepository: ProductRepository(),
                            subcategory: selectedNames,
                            selectedCategories: selectedShipsin,
                          ),
                          child: NewInProductsScreen(
                            selectedCategories: selectedShipsin,
                            subcategory: selectedNames,
                            initialTab: selectedShipsin.first["shipin"] ?? '',
                            productListBuilder: (category, sort) {
                              return CategoryResultScreen(
                                selectedCategories: selectedShipsin,
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

