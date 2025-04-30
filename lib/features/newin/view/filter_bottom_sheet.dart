import 'package:aashni_app/features/newin/view/category_color_screen.dart';
import 'package:aashni_app/features/newin/view/category_shipin_screen.dart';
import 'package:aashni_app/features/newin/view/new_in_category_designer.dart';
import 'package:flutter/material.dart';

import 'cat_theme_screen.dart';
import 'category_filter.dart';
import 'category_gender_screen.dart';
import 'category_size_screen.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final List<String> filterOptions = [
    "CATEGORY",
    "THEME",
    "GENDER",
    "DESIGNER",
    "COLOR",
    "SIZE",
    "SHIPS IN",
    "PRICE",
    "A+CO EDITS"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 680,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title & Close Icon
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Apply Filters",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 26, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Filter Options List
          Expanded(
            child: ListView.builder(
              itemCount: filterOptions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3D4D3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      filterOptions[index],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                    onTap: () {
                      final selectedOption = filterOptions[index];
                      if (selectedOption == "CATEGORY") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryFilterScreen(),
                          ),
                        );
                      }

                      else if(selectedOption == "THEME"){

                     Navigator.push(context, MaterialPageRoute(builder:
                     (_)=> const CategoryThemeScreen()
                     )
                     );

                      }

                      else if(selectedOption == "GENDER"){

                        Navigator.push(context, MaterialPageRoute(builder:
                            (_)=> const CategoryGenderScreen()
                        )
                        );

                      }

                      else if(selectedOption == "DESIGNER"){

                        // Navigator.push(context, MaterialPageRoute(builder:
                        //     (_)=> const DesignerListScreen()
                        // )
                        // );

                      }

                      else if(selectedOption == "COLOR"){

                        Navigator.push(context, MaterialPageRoute(builder:
                            (_)=> const CategoryColorScreen()
                        )
                        );

                      }

                      else if (selectedOption == "SIZE"){
                        Navigator.push(context, MaterialPageRoute(builder: (_)=> const

                        CategorySizeScreen()));

                      }

                      else if (selectedOption == "SHIPS IN"){

                        // Navigator.push(context, MaterialPageRoute(builder: (_)=> const
                        // CategoryShipinScreen()
                        // ));
                      }

                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                "Apply",
                style: TextStyle(fontSize: 16, color: Colors.white, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }


}

