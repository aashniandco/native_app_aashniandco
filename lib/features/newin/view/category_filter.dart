import 'package:aashni_app/features/newin/view/new_in_filter_screen.dart';

import 'package:flutter/material.dart';

import 'package:aashni_app/features/newin/view/new_in_filter_accessories_screen.dart';



// Dummy screen to display selected categories
class CategoryResultScreen extends StatelessWidget {
  final List<Map<String,dynamic>> selectedCategories;

  const CategoryResultScreen({super.key, required this.selectedCategories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filtered Results")),
      body: ListView.builder(
        itemCount: selectedCategories.length,
        itemBuilder: (context, index) {
          final item= selectedCategories[index];
          return ListTile(
            title: Text(item["subCategory"]?? item["category"]),
            subtitle: item["id"] != null ? Text("ID: ${item["id"]}") : null,
            leading: const Icon(Icons.label),
          );
        },
      ),
    );
  }
}

class CategoryFilterScreen extends StatefulWidget {
  const CategoryFilterScreen({super.key});

  @override
  State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      "name": "Accessories",
      "isExpanded": false,
      "isSelected": false,
      "children": [
        {"id": 1, "name": "Bags", "isSelected": false},
        {"id": 2, "name": "Jewelry", "isSelected": false}
      ]
    },
    {
      "name": "Women's Clothing",
      "isExpanded": false,
      "isSelected": false,
      "children": [
        {"id": 2295, "name": "Lehengas", "isSelected": false},
        {"id": 4454, "name": "Kurta Sets", "isSelected": false},
        {"id": 2297, "name": "Sarees", "isSelected": false},
        {"id": 2299, "name": "Tops", "isSelected": false},
        {"id": 4046, "name": "Kaftans", "isSelected": false},
        {"id": 3264, "name": "Gowns", "isSelected": false},
        {"id": 3247, "name": "Pants", "isSelected": false},
        {"id": 3293, "name": "Tunics & Kurtis", "isSelected": false},
        {"id": 4491, "name": "Capes", "isSelected": false},
        {"id": 3027, "name": "Jumpsuits", "isSelected": false},
        {"id": 4450, "name": "Kurtas", "isSelected": false},
        {"id": 3219, "name": "Skirts", "isSelected": false},
        {"id": 4460, "name": "Palazzo Sets", "isSelected": false},
        {"id": 2596, "name": "Beach", "isSelected": false},
        {"id": 3973, "name": "Loungewear", "isSelected": false}
      ]
    },
    {
      "name": "Shoes",
      "isExpanded": false,
      "isSelected": false,
      "children": [
        {"id": 18, "name": "Heels", "isSelected": false},
        {"id": 19, "name": "Flats", "isSelected": false}
      ]
    }
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
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Checkbox(
                          value: category["isSelected"],
                          onChanged: (bool? value) {
                            setState(() {
                              categories[index]["isSelected"] = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            category["name"],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    initiallyExpanded: category["isExpanded"],
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        categories[index]["isExpanded"] = expanded;
                      });
                    },
                    children: List.generate(
                      category["children"].length,
                          (childIndex) {
                        final child = category["children"][childIndex];
                        return Padding(
                          padding: const EdgeInsets.only(left: 60.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: child["isSelected"],
                                onChanged: (bool? value) {
                                  setState(() {
                                    child["isSelected"] = value!;
                                  });
                                },
                              ),
                              Text(child["name"]),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  List<Map<String, dynamic>> selected = [];

                  for (var cat in categories) {
                    if (cat["isSelected"] == true) {
                      selected.add({"category": cat["name"], "id": null});
                    }
                    for (var child in cat["children"]) {
                      if (child["isSelected"] == true) {
                        selected.add({
                          "category": cat["name"],
                          "subCategory": child["name"],
                          "id": child["id"]
                        });
                      }
                    }
                  }


                  if (selected.length == 1 &&
                      selected[0]["id"] == null &&
                      selected[0]["category"] == "Women's Clothing") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewInFilterScreen(
                          selectedCategories: selected,
                        ),
                      ),
                    );
                  } else if (selected.length == 1 &&
                      selected[0]["id"] == null &&
                      selected[0]["category"] == "Accessories") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  NewInFilterAccessoriesScreen(
                          selectedCategories: selected,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryResultScreen(
                          selectedCategories: selected,
                        ),
                      ),
                    );
                  }


                }
                ,
                child: const Text("Apply", style: TextStyle(fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }

}
