import 'package:aashni_app/features/newin/bloc/newin_products_bloc.dart';
import 'package:flutter/material.dart';

import '../bloc/product_repository.dart';
import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategorySizeScreen extends StatefulWidget {
  const CategorySizeScreen({super.key});

  @override
  State<CategorySizeScreen> createState() => _CategorySizeScreenState();
}

class _CategorySizeScreenState extends State<CategorySizeScreen> {

  final List <Map<String,dynamic>> size = [

    {
     "name": "XXSmall",
      "isExpanded" : false,
      "isSelected" : false,
      "children" : []

    },

    {

      "name": "XSmall",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,


    {

      "name": "Small",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Medium",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Large",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "XLarge",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "XXLarge",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "3XLarge",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "4XLarge",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "5XLarge",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "6XLarge",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Custom Made",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Free Size",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Euro Size 32",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Euro Size 33",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Euro Size 34",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Euro Size 35",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Euro Size 36",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Euro Size 37",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Euro Size 38",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Euro Size 39",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Euro Size 40",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Euro Size 41",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    , {

      "name": "Euro Size 42",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    , {

      "name": "Euro Size 43",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "Euro Size 44",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Euro Size 45",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Euro Size 46",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Euro Size 47",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Euro Size 48",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Euro Size 49",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Bangle Size- 2.2",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Bangle Size- 2.4",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Bangle Size- 2.6",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "Bangle Size- 2.8",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "6-12 Months",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "1-2 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "2-3 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "3-4 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "4-5 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "5-6 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "6-7 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "7-8 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,
    {

      "name": "8-9 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "9-10 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "10-11 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "11-12 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "12-13 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "13-14 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "14-15 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,

    {

      "name": "15-16 Years",
      "isExpanded": false,
      "isSelected": false,
      "children": []
    }
    ,




  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      appBar: AppBar(title: Text('Select Size'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation:1),

      body: Column(
        children: [
         Expanded(
             child:
             ListView.builder(
                 itemCount: size.length,
                 itemBuilder:(context,index){

                   final category= size[index];
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
                                   size[index]["isSelected"] = value!;
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
                             size[index]["isExpanded"] = expanded;
                           });
                         },

                       ),
                     ),
                   );





             })
         )
          ,
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
                  List<Map<String, dynamic>> selectedSizes = [];

                  // Populate selected categories and subcategories
                  for (var cat in size) {
                    if (cat["isSelected"] == true) {
                      // selected.add({"theme": cat["name"], "id": null});

                      selectedSizes.add({
                        "theme": cat["name"],
                        "size": cat["name"], // 👈 Add this line
                        "id": null,
                      });
                    }
                    for (var child in cat["children"]) {
                      if (child["isSelected"] == true) {
                        selectedSizes.add({
                          "theme": cat["name"],
                          "subCategory": child["name"],
                          "id": child["id"]
                        });
                      }
                    }
                  }

                  if (selectedSizes.isNotEmpty) {
                    final selectedNames = selectedSizes
                        .map((item) => item["size"] ?? item["subCategory"])
                        .join(", ");


                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => NewInProductsBloc(
                            productRepository: ProductRepository(),
                            subcategory: selectedNames,
                            selectedCategories: selectedSizes,
                          ),
                          child: NewInProductsScreen(
                            selectedCategories: selectedSizes,
                            subcategory: selectedNames,
                            initialTab: selectedSizes.first["size"] ?? '',
                            productListBuilder: (category, sort) {
                              return CategoryResultScreen(
                                selectedCategories: selectedSizes,
                              );
                            },
                          ),
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

