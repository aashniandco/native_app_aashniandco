
// lib/features/newin/view/menu_categories_screen.dart (or your path)
// lib/features/newin/view/menu_categories_screen.dart (or your path)
import 'package:aashni_app/features/newin/view/plpfilterscreens/filter_bottom_sheet_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../newin/model/new_in_model.dart';
import '../../newin/view/filter_bottom_sheet.dart';
import '../../newin/view/product_details_newin.dart';
import '../bloc/category_products_bloc.dart';
import '../bloc/category_products_event.dart';
import '../bloc/category_products_state.dart';
// Make sure to import your actual Product model
// import 'package:aashni_app/models/product_model.dart';

// lib/features/newin/view/menu_categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Assuming your filter bottom sheet exists, import it here
// import 'package:aashni_app/widgets/filter_bottom_sheet.dart';

// Make sure to import your actual Product model


import '../bloc/category_products_bloc.dart';
import '../bloc/category_products_event.dart';
import '../bloc/category_products_state.dart';
import '../repository/api_service.dart';

// 1. Converted to a StatefulWidget to manage sorting state
class MenuCategoriesScreen extends StatefulWidget {
  final String categoryName;

  const MenuCategoriesScreen({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<MenuCategoriesScreen> createState() => _MenuCategoriesScreenState();
}

class _MenuCategoriesScreenState extends State<MenuCategoriesScreen> {
  // 2. State variables for sorting
  String selectedSort = "Latest";
  List<Product> sortedProducts = [];

  // ✅ NEW STATE VARIABLES FOR ASYNC DATA
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _categoryMetadataFuture;



  // 3. Sorting logic adapted from your example
  // 3. Sorting logic adapted from your reference
  // 3. Sorting logic adapted from your reference
  // 3. Sorting logic with added DEBUGGING
// 3. Sorting logic adapted from your reference

  void sortProducts(List<Product> products) {
    // Create a mutable copy of the product list to sort
    List<Product> productsToSort = List<Product>.from(products);

    if (selectedSort == "High to Low") {
      productsToSort.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
    } else if (selectedSort == "Low to High") {
      productsToSort.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
    } else { // Default to "Latest"
      // --- FINAL LOGIC THAT MIMICS YOUR WEBSITE'S BEHAVIOR ---
      productsToSort.sort((a, b) {

        // This helper function can now handle all 3 formats:
        // 1. Modern Date-based SKUs (SRKAUG2403)
        // 2. Legacy Alphanumeric SKUs (Dhr006382)
        // 3. Legacy Simple Numeric IDs (635065)
        int getSortableValue(String? id) {
          if (id == null || id.isEmpty) {
            return 0;
          }

          // --- Priority 1: Check for the Modern Date-based format FIRST. ---
          // This is the most reliable way to determine "newness".
          const monthMap = {
            'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
            'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
          };

          // Use a regular expression to find the date pattern
          final RegExp datePattern = RegExp(r'[A-Z]{3}([0-9]{2})');
          final match = datePattern.firstMatch(id.toUpperCase());

          if (match != null && monthMap.containsKey(id.substring(match.start, match.start + 3))) {
            try {
              String monthStr = id.substring(match.start, match.start + 3);
              String yearStr = match.group(1)!;
              // Find what's left for the sequence number
              String sequencePart = id.substring(match.end);
              String sequenceDigits = sequencePart.replaceAll(RegExp(r'[^0-9]'), '');

              if (sequenceDigits.isNotEmpty) {
                int year = int.parse(yearStr) + 2000;
                int month = monthMap[monthStr]!;
                int sequence = int.parse(sequenceDigits);
                // Return a very large number to ensure these are always sorted highest
                return (year * 10000000) + (month * 100000) + sequence;
              }
            } catch (e) { /* Fall through to legacy parsing */ }
          }

          // --- Priority 2: Fallback for Legacy SKUs (Dhr006382 or 635065) ---
          // If it's not a modern SKU, extract any numbers we can find.
          String numericPart = id.replaceAll(RegExp(r'[^0-9]'), '');
          if (numericPart.isNotEmpty) {
            return int.tryParse(numericPart) ?? 0;
          }

          // If all else fails
          return 0;
        }

        final valA = getSortableValue(a.prod_en_id);
        final valB = getSortableValue(b.prod_en_id);

        return valB.compareTo(valA);
      });
    }

    // Update the state to trigger a rebuild
    setState(() {
      sortedProducts = productsToSort;
    });
  }
  // void sortProducts(List<Product> products) {
  //   // Create a mutable copy of the product list to sort
  //   List<Product> productsToSort = List<Product>.from(products);
  //
  //   if (selectedSort == "High to Low") {
  //     productsToSort.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
  //   } else if (selectedSort == "Low to High") {
  //     productsToSort.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
  //   } else { // Default to "Latest"
  //     // --- UNIVERSAL SORT LOGIC FOR INCONSISTENT prod_en_id ---
  //     productsToSort.sort((a, b) {
  //
  //       // This "smart" helper function can handle both simple numbers AND complex SKUs.
  //       int getSortableValue(String? id) {
  //         if (id == null || id.isEmpty) {
  //           return 0; // Invalid ID, sort to bottom
  //         }
  //
  //         // --- Step 1: Try to parse as a simple number first. ---
  //         // This handles IDs like "635065".
  //         final simpleId = int.tryParse(id);
  //         if (simpleId != null) {
  //           return simpleId;
  //         }
  //
  //         // --- Step 2: If it's not a simple number, try parsing it as a complex SKU. ---
  //         // This handles IDs like "SWJJUL24D2026".
  //         // It will only run if the int.tryParse above fails.
  //         if (id.length < 9) return 0; // Complex SKU is too short
  //
  //         const monthMap = {
  //           'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
  //           'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
  //         };
  //
  //         try {
  //           String monthStr = id.substring(3, 6).toUpperCase();
  //           String yearStr = id.substring(6, 8);
  //           String sequencePart = id.substring(8);
  //           String sequenceDigits = sequencePart.replaceAll(RegExp(r'[^0-9]'), '');
  //
  //           if (sequenceDigits.isEmpty) return 0;
  //
  //           int year = int.parse(yearStr) + 2000;
  //           int month = monthMap[monthStr] ?? 0;
  //           int sequence = int.parse(sequenceDigits);
  //
  //           // The large number ensures date-based SKUs are always "newer"
  //           // than the simple number IDs from the older system.
  //           return (year * 10000000) + (month * 100000) + sequence;
  //
  //         } catch (e) {
  //           // If all parsing attempts fail, sort it to the bottom.
  //           return 0;
  //         }
  //       }
  //
  //       // --- THE CRITICAL PART ---
  //       // We now call our universal helper function on prod_en_id.
  //       final valA = getSortableValue(a.prod_en_id);
  //       final valB = getSortableValue(b.prod_en_id);
  //
  //       return valB.compareTo(valA);
  //     });
  //   }
  //
  //   // Update the state to trigger a rebuild with the sorted list
  //   setState(() {
  //     sortedProducts = productsToSort;
  //   });
  // }

//   void sortProducts(List<Product> products) {
//     // Create a mutable copy of the product list to sort
//     List<Product> productsToSort = List<Product>.from(products);
//
//     if (selectedSort == "High to Low") {
//       // Sort by price, highest first
//       productsToSort.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
//     } else if (selectedSort == "Low to High") {
//       // Sort by price, lowest first
//       productsToSort.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
//     } else { // Default to "Latest"
//       // *** NEW LOGIC FOR "LATEST" BASED ON YOUR REFERENCE ***
//       // This logic sorts the products by their SKU (prodEnId) in descending numerical order.
//       productsToSort.sort((a, b) {
//         // Safely parse the SKU string to an integer. If it's not a valid number
//         // or is null, it defaults to 0.
//         // Note: We use 'prodEnId' to match the property in your Product model on this screen.
//         final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
//         final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
//
//         // By comparing B to A, we get a descending sort order.
//         // The product with the higher ID (idB) will come first.
//         return idB.compareTo(idA);
//       });
//     }
//
//     // Update the state to trigger a rebuild with the sorted list
//     setState(() {
//       sortedProducts = productsToSort;
//     });
//   }

  @override
  void initState() {
    super.initState();
    // Start the metadata fetch when the screen loads
    _categoryMetadataFuture = _apiService.fetchCategoryMetadataByName(widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The AppBar title remains dynamic
        title: Text(widget.categoryName),
      ),
      // 4. BlocProvider is now in the body to trigger the fetch once
      body: BlocProvider(
        create: (context) => CategoryProductsBloc()
          ..add(FetchProductsForCategory(categoryName: widget.categoryName)),

        // 5. BlocListener is used to react to data loading without rebuilding the whole screen
        child: BlocListener<CategoryProductsBloc, CategoryProductsState>(
          listener: (context, state) {
            if (state is CategoryProductsLoaded) {
              // When products are loaded, sort them based on the current selection
              sortProducts(state.products);
            }
          },
          // 6. BlocBuilder handles UI changes for loading/error and the main content
          child: BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
            builder: (context, state) {
              if (state is CategoryProductsLoading && sortedProducts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CategoryProductsError) {
                return Center(child: Text(state.message));
              }

              if (sortedProducts.isEmpty && state is CategoryProductsLoaded) {
                return const Center(child: Text("No products found in this category."));
              }

              // The main UI structure from your example
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Header Row with Title and Sort Dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.categoryName, // Dynamic title
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: DropdownButton<String>(
                            value: selectedSort,
                            icon: const Icon(Icons.sort, color: Colors.black),
                            style: const TextStyle(fontSize: 14),
                            dropdownColor: Colors.white,
                            underline: Container(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedSort = value;
                                // Re-sort the existing list when the user changes selection
                                if (state is CategoryProductsLoaded) {
                                  sortProducts(state.products);
                                }
                              }
                            },
                            items: ["Latest", "High to Low", "Low to High"]
                                .map((sortOption) {
                              return DropdownMenuItem<String>(
                                value: sortOption,
                                child: Text(sortOption, style: const TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Product Grid
                    Expanded(
                      child: GridView.builder(
                        itemCount: sortedProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.55, // Adjusted for better layout
                        ),
                        itemBuilder: (context, index) {
                          final item = sortedProducts[index];
                          return GestureDetector(
                            onTap: () {
                              // TODO: Implement navigation to product detail screen
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: item)));
                              print("Tapped on ${item.designerName}");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailNewInDetailScreen(product: item.toJson()),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              elevation: 1,
                              clipBehavior: Clip.antiAlias, // Ensures image respects border radius
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    item.prodSmallImg ?? '', // Use correct property name
                                    width: double.infinity,
                                    height: 250, // Fixed height for consistency
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 250,
                                        color: Colors.grey[200],
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                      );
                                    },
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.designerName ?? "Unknown Designer",
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.shortDesc ?? "No description",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}", // Use actualPrice1
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),

      // Floating Filter Button from your example
      floatingActionButton: FutureBuilder<Map<String, dynamic>>(
        future: _categoryMetadataFuture,
        builder: (context, snapshot) {
          // If data is loading or has an error, show a disabled button
          if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
            return FloatingActionButton(
              onPressed: null, // Disabled
              backgroundColor: Colors.grey,
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.filter_list_alt, color: Colors.black54),
            );
          }

          // Data is loaded, we can get the ID!
          final categoryData = snapshot.data!;
          // final String categoryId = categoryData['cat_id']?.toString() ?? '';
          final String parentCategoryId = categoryData['pare_cat_id']?.toString() ?? '';
          // Show the enabled button
          return FloatingActionButton(
            onPressed: () {
              if (parentCategoryId.isNotEmpty) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FilterBottomSheetCategories(
                    // Pass the dynamically fetched ID
                    categoryId: parentCategoryId,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Filter not available for this category.")),
                );
              }
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.filter_list_alt, color: Colors.black),
          );
        },
      ),
    );
  }
}

// class MenuCategoriesScreen extends StatelessWidget {
//   final String categoryName;
//
//   const MenuCategoriesScreen({
//     Key? key,
//     required this.categoryName,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(categoryName),
//       ),
//       // 1. Wrap the body with BlocProvider to create and provide the BLoC
//       body: BlocProvider(
//         create: (context) => CategoryProductsBloc()
//         // 2. Immediately add the event to start fetching data
//           ..add(FetchProductsForCategory(categoryName: categoryName)),
//         child: BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
//           builder: (context, state) {
//             // 3. Build UI based on the current state
//             if (state is CategoryProductsLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is CategoryProductsLoaded) {
//               // If there are no products, show a message
//               if (state.products.isEmpty) {
//                 return const Center(
//                   child: Text('No products found in this category.'),
//                 );
//               }
//               // Display the products in a list or grid
//               return ListView.builder(
//                 itemCount: state.products.length,
//                 itemBuilder: (context, index) {
//                   final product = state.products[index];
//
//                   // ✅ CORRECTED: Use the actual property names from your Product model
//                   // These names should match the fields from the API response.
//                   return ListTile(
//                     leading: product.prodSmallImg != null && product.prodSmallImg!.isNotEmpty
//                         ? Image.network(product.prodSmallImg!)
//                         : const Icon(Icons.broken_image), // Placeholder for missing image
//
//                     title: Text(product.designerName ?? 'Unnamed Product'), // Use 'prodName' instead of 'name'
//
//                     subtitle: Text(product.designerName ?? 'No designer'), // This one was likely correct
//
//                     trailing: Text(
//                         product.actualPrice?.toString() ?? 'N/A' // Use 'actualPrice1' instead of 'price'
//                     ),
//                   );
//                 },
//               );
//             } else if (state is CategoryProductsError) {
//               return Center(child: Text(state.message));
//             } else {
//               return const Center(child: Text('Something went wrong.'));
//             }
//           },
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
//
// class MenuCategoriesScreen extends StatelessWidget {
//   // 1. Declare a final variable to hold the category name
//   final String categoryName;
//
//   // 2. Add it to the constructor as a required parameter
//   const MenuCategoriesScreen({
//     Key? key,
//     required this.categoryName,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // 3. Use the categoryName dynamically, for example, in the AppBar title
//       appBar: AppBar(
//         title: Text(categoryName),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Sub-categories for',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             SizedBox(height: 8),
//             Text(
//               categoryName,
//               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             // TODO: Here you would typically use this 'categoryName'
//             // to fetch and display the sub-categories or products
//             // associated with it, likely using another BLoC.
//           ],
//         ),
//       ),
//     );
//   }
// }