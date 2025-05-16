import 'package:aashni_app/features/newin/view/category_result_tes_screen.dart';
import 'package:flutter/material.dart';

import '../bloc/newin_products_bloc.dart';
import '../bloc/product_repository.dart';
import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryAcoeditScreen extends StatefulWidget {
  const CategoryAcoeditScreen ({super.key});

  @override
  State<CategoryAcoeditScreen> createState() => _CategoryAcoeditScreenState();
}

class _CategoryAcoeditScreenState extends State<CategoryAcoeditScreen> {
  final List<Map<String, dynamic>> acoedit = [
    {"name": "Belted Sarees", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Cotton Kurtas", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Cult Finds", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Embellished Tops", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Exclusive", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Festive Kurtas", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Festive Potlis", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Floral Sarees", "isEx"
        "panded": false, "isSelected": false, "children": []},
    {"name": "Heritage Weaves", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Kurtas Under \$500", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Lehengas Under \$2000", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Off The Runway", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "Sustainable Edit", "isExpanded": false, "isSelected": false, "children": []},
    {"name": "The Summer Edit", "isExpanded": false, "isSelected": false, "children": []},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select A+CO Edit"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: acoedit.length,
              itemBuilder: (context, index) {
                final category = acoedit[index];
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
                                acoedit[index]["isSelected"] = value!;
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
                          acoedit[index]["isExpanded"] = expanded;
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
                  List<Map<String, dynamic>> selectedacoedit = [];

                  for (var cat in acoedit) {
                    if (cat["isSelected"] == true) {
                      selectedacoedit.add({
                        "theme": cat["name"],
                        "acoedit": cat["name"],
                        "id": null,
                      });
                    }
                    for (var child in cat["children"]) {
                      if (child["isSelected"] == true) {
                        selectedacoedit.add({
                          "theme": cat["name"],
                          "subCategory": child["name"],
                          "id": child["id"]
                        });
                      }
                    }
                  }

                  if (selectedacoedit.isNotEmpty) {
                    final selectedNames = selectedacoedit
                        .map((item) => item["acoedit"] ?? item["subCategory"])
                        .join(", ");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => NewInProductsBloc(
                            productRepository: ProductRepository(),
                            subcategory: selectedNames,
                            selectedCategories: selectedacoedit,
                          ),
                          child: NewInProductsScreen(
                            selectedCategories: selectedacoedit,
                            subcategory: selectedNames,
                            initialTab: selectedacoedit.first["acoedit"] ?? '',
                            productListBuilder: (category, sort) {
                              return CategoryResultScreen(
                                selectedCategories: selectedacoedit,
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



