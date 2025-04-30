import 'package:flutter/material.dart';

import 'category_result_screen.dart';
import 'new_in_products_screen.dart';

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
      "name": "1_2Weeks",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    }
    ,

    {
      "name": "2_4Weeks",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    },

    {
      "name": "4_6Weeks",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    },

    {
      "name": "6_8Weeks",
      "isExpanded": false,
      "isSelected": false,
      "children": [],
    },

    {
      "name": "8Weeks",
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
                  List<Map<String, dynamic>> selected = [];

                  // Populate selected categories and subcategories
                  for (var cat in shipin) {
                    if (cat["isSelected"] == true) {
                      selected.add({"theme": cat["name"], "id": null});
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

                  // Build selected subcategories
                  final List<Map<String, dynamic>> selectedSubcategories = [];
                  for (final mainCategory in shipin) {
                    for (final sub in mainCategory['children']) {
                      if (sub['isSelected'] == true) {
                        selectedSubcategories.add({
                          "subCategory": sub['name'],
                          "id": sub['id'],
                          "isSelected": true,
                        });
                      }
                    }
                  }

                  if (selected.any((item) => item["subCategory"] != null)) {
                    // ✅ Navigate if any subcategory is selected
                    final selectedSubcategoryNames = selected
                        .where((item) => item["subCategory"] != null)
                        .map((e) => e["subCategory"] as String)
                        .toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewInProductsScreen(
                          selectedCategories: selected,
                          subcategory: selectedSubcategoryNames.join(", "),
                          initialTab: selectedSubcategoryNames.isNotEmpty
                              ? selectedSubcategoryNames.first
                              : '',
                          productListBuilder: (category, sort) {
                            return CategoryResultScreen(
                              selectedCategories: selectedSubcategories,
                            );
                          },
                        ),
                      ),
                    );
                  } else if (selected.length == 1 && selected[0]["id"] == null) {
                    // ✅ Navigate when only theme (like Contemporary or Ethnic) is selected
                    String themeName = selected[0]["theme"];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewInProductsScreen(
                          selectedCategories: selected,
                          subcategory: themeName,
                          initialTab: themeName,
                          productListBuilder: (category, sort) {
                            return CategoryResultScreen(
                              selectedCategories: [],
                            );
                          },
                        ),
                      ),
                    );
                  }
                }
                ,

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

