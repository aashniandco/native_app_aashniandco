import 'dart:convert';

import 'package:aashni_app/constants/text_styles.dart';
import 'package:aashni_app/features/newin/bloc/new_in_bloc.dart';
import 'package:aashni_app/features/newin/bloc/product_te.dart';
import 'package:aashni_app/features/newin/model/new_in_model.dart';
import 'package:aashni_app/features/newin/view/product_details_newin.dart';
import 'package:aashni_app/features/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/user_preferences_helper.dart';
import 'filter_bottom_sheet.dart';
import '../bloc/new_in_state.dart';

// class NewInScreen extends StatefulWidget {
//   const NewInScreen({super.key});
//
//   @override
//   State<NewInScreen> createState() => _NewInScreenState();
// }
//
// class _NewInScreenState extends State<NewInScreen> {
//   String selectedSort = "High to Low";
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<NewInBloc>().add(FetchNewIn());
//   }
//
//   void sortProducts(List<NewInProduct> products) {
//     if (selectedSort == "High to Low") {
//       products.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
//     } else {
//       products.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("New >>"),
//           backgroundColor: Colors.white,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () {
//                 context.read<NewInBloc>().add(FetchNewIn());
//               },
//             )
//           ],
//         ),
//
//       body: BlocBuilder<NewInBloc, NewInState>(
//         builder: (context, state) {
//           if (state is NewInLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is NewInLoaded) {
//             List<NewInProduct> products = state.products;
//             print("Total products in UI: ${products.length}");
//             for (var i = 0; i < products.length && i < 5; i++) {
//               debugPrint("Product $i: ${products[i].shortDesc}, Price: ${products[i].actualPrice}");
//             }
//
//             sortProducts(products);
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Sort Dropdown
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: Container(
//                     height: 35,
//                     margin: const EdgeInsets.all(8),
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(color: Colors.grey),
//                     child: DropdownButton<String>(
//                       value: selectedSort,
//                       icon: const Icon(Icons.sort, color: Colors.black),
//                       style: const TextStyle(color: Colors.white, fontSize: 14),
//                       dropdownColor: Colors.grey,
//                       underline: Container(),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedSort = newValue!;
//                         });
//                       },
//                       items: ["High to Low", "Low to High"]
//                           .map<DropdownMenuItem<String>>((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child:
//                           Text(value, style: const TextStyle(color: Colors.black)),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//
//                 // Product Grid
//                 Expanded(
//                   child: GridView.builder(
//                     padding: const EdgeInsets.all(8),
//                     itemCount: products.length,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                       childAspectRatio: 0.5,
//                     ),
//                     itemBuilder: (context, index) {
//                       final item = products[index];
//
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   ProductDetailScreen(product: item.toJson()),
//                             ),
//                           );
//                         },
//                         child: Card(
//                           color: Colors.white,
//                           elevation: 1,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Flexible(
//                                 child: Image.network(
//                                   item.prodSmallImg.isNotEmpty
//                                       ? item.prodSmallImg
//                                       : item.prodThumbImg,
//                                   width: double.infinity,
//                                   height: 550,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       width: double.infinity,
//                                       height: 550,
//                                       color: Colors.grey[300],
//                                       alignment: Alignment.center,
//                                       child: const Icon(Icons.image_not_supported,
//                                           size: 50),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Padding(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Center(
//                                   child: Text(
//                                     item.designerName,
//                                     style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Center(
//                                   child: Text(
//                                     item.shortDesc,
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(fontSize: 12),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                 child: Center(
//                                   child: Text(
//                                     "₹${item.actualPrice}",
//                                     style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           } else if (state is NewInError) {
//             return Center(child: Text(state.message));
//           } else {
//             return const Center(child: Text("Unexpected state"));
//           }
//         },
//       ),
//     );
//   }
// }

class NewInScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedCategories;
  const NewInScreen({super.key, required this.selectedCategories});

  @override
  State<NewInScreen> createState() => _NewInScreenState();
}

class _NewInScreenState extends State<NewInScreen> {
  String selectedSort = "Latest";
  List<dynamic> sortedProducts = [];
  String firstName = '';
  String lastName = '';
  int currentPage = 0;
  int nextPage = 0;
  bool hasReachedEnd = false;

  final ScrollController _scrollController = ScrollController();

  bool _isFetching = false;


  @override
  void initState() {
    super.initState();
    final selectedData = widget.selectedCategories;
    debugPrint("Selected Categories: $selectedData");
    // context.read<NewInBloc>().add(FetchNewIn(page: nextPage));
    context.read<NewInBloc>().add(FetchNewIn());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !hasReachedEnd) {
        context.read<NewInBloc>().add(FetchNewIn(page: currentPage + 1));
      }
    });


    _loadUserNames();
  }

  Future<void> _loadUserNames() async {
    final fName = await UserPreferences.getFirstName();
    final lName = await UserPreferences.getLastName();
    setState(() {
      firstName = fName;
      lastName = lName;
    });
  }
  void sortProducts(List<Product> products) {
    sortedProducts = List<Product>.from(products);
    if (selectedSort == "High to Low") {
      sortedProducts.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
    } else if (selectedSort == "Low to High") {
      sortedProducts.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
    } else if (selectedSort == "Latest") {
      sortedProducts.sort((a, b) {
        final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
        final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
        return idB.compareTo(idA);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NewInBloc, NewInState>(
        builder: (context, state) {
          if (state is NewInLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NewInError) {
            return Center(child: Text(state.message));
          } else if (state is NewInLoaded) {
            _isFetching = false;
            sortProducts(state.products);

            if (sortedProducts.isEmpty) {
              return const Center(child: Text("No products found"));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "New In",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButton<String>(
                          value: selectedSort,
                          icon: const Icon(Icons.sort, color: Colors.black),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          dropdownColor: Colors.white,
                          underline: Container(),
                          onChanged: (value) {
                            setState(() {
                              selectedSort = value!;
                              sortProducts(state.products);
                            });
                          },
                          items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
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
                      controller: _scrollController,

                      itemCount: state.hasReachedEnd
                          ? sortedProducts.length
                          : sortedProducts.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.5,
                      ),
                      itemBuilder: (context, index) {
                        if (index >= sortedProducts.length) {
                          // Loader item
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final item = sortedProducts[index];
                        return GestureDetector(
                          onTap: () {
                            print("Designer Data: ${jsonEncode(item.toJson())}");
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                Flexible(
                                  child: Image.network(
                                    item.prodSmallImg ?? item.prodThumbImg ?? '',
                                    width: double.infinity,
                                    height: 550,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 550,
                                        color: Colors.grey[300],
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.image_not_supported, size: 50),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Designer Name
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Center(
                                    child: Text(
                                      item.designerName ?? "Unknown",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),

                                // Short Description
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Center(
                                    child: Text(
                                      item.shortDesc ?? "No description",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),

                                // Price
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    child: Text(
                                      "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      ,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),

      // Floating Filter Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const FilterBottomSheet(),
          );
        },
        child: const Icon(Icons.filter_list_alt),
        backgroundColor: Colors.white,
      ),
    );
  }
}

// class NewInScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//   const NewInScreen({super.key, required this.selectedCategories});
//
//   @override
//   State<NewInScreen> createState() => _NewInScreenState();
// }
//
// class _NewInScreenState extends State<NewInScreen> {
//   String selectedSort = "Latest";
//   // List<dynamic> products = [];
//   List<dynamic> sortedProducts = [];
//
//   @override
//   void initState() {
//     super.initState();
//     final selectedData = widget.selectedCategories;
//
//     // Example: Filter products based on category/subCategory if needed
//     debugPrint("Selected Categories: $selectedData");
//     context.read<NewInBloc>().add(FetchNewIn());
//   }
//
//   // void sortProducts(List<Product> products) {
//   //   sortedProducts = List<Product>.from(products); // Clone
//   //   if (selectedSort == "Latest") {
//   //     sortedProducts.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
//   //   } else {
//   //     sortedProducts.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
//   //   }
//   // }
//
//   void sortProducts(List<Product> products) {
//     sortedProducts = List<Product>.from(products); // Clone the list
//     if (selectedSort == "High to Low") {
//       sortedProducts.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
//     } else if (selectedSort == "Low to High") {
//       sortedProducts.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
//     } else if (selectedSort == "Latest") {
//       sortedProducts.sort((a, b) {
//         final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
//         final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
//         return idB.compareTo(idA);
//       });
//     }
//   }
//
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<NewInBloc, NewInState>(
//         builder: (context, state) {
//           if (state is NewInLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is NewInError) {
//             return Center(child: Text(state.message));
//           } else if (state is NewInLoaded) {
//             sortProducts(state.products);
//
//             if (sortedProducts.isEmpty) {
//               return const Center(child: Text("No products found"));
//             }
//
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   /// Header Row with "New In" and Sort Dropdown
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "New In",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Container(
//                         height: 35,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: DropdownButton<String>(
//                           value: selectedSort,
//                           icon: const Icon(Icons.sort, color: Colors.black),
//                           style: const TextStyle(color: Colors.white, fontSize: 14),
//                           dropdownColor: Colors.white,
//                           underline: Container(),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedSort = value!;
//                               sortProducts(state.products);
//                             });
//                           },
//                           items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
//                             return DropdownMenuItem<String>(
//                               value: sortOption,
//                               child: Text(sortOption, style: const TextStyle(color: Colors.black)),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//
//                   Expanded(
//                     child: GridView.builder(
//                       itemCount: sortedProducts.length,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2, // 2 items per row
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                         childAspectRatio: 0.5, // Decrease this to increase height
//                       ),
//                       itemBuilder: (context, index) {
//                         final item = sortedProducts[index];
//                         return GestureDetector(
//                           onTap: () {
//                             print("Designer Data: ${jsonEncode(item)}");
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ProductDetailNewInDetailScreen(product: item),
//                               ),
//                             );
//                           },
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 1,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Increased Image Height
//                                 Flexible(
//                                   child: Image.network(
//                                     item['prod_small_img'] ?? item['prod_thumb_img'] ?? '',
//                                     width: double.infinity,
//                                     height: 550, // Increase height
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         width: double.infinity,
//                                         height: 550, // Match the height
//                                         color: Colors.grey[300],
//                                         alignment: Alignment.center,
//                                         child: const Icon(Icons.image_not_supported, size: 50),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//
//                                 // Designer Name
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       item['designer_name'] ?? "Unknown",
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ),
//
//                                 // Short Description
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       item['short_desc'] ?? "No description",
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(fontSize: 12),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ),
//
//                                 // Price
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       "₹${item['actual_price_1'] ?? 'N/A'}",
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   )
//                   /// Grid of Products
//                   // Expanded(
//                   //   child: GridView.builder(
//                   //     itemCount: sortedProducts.length,
//                   //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   //       crossAxisCount: 2,
//                   //       crossAxisSpacing: 10,
//                   //       mainAxisSpacing: 10,
//                   //       childAspectRatio: 0.55,
//                   //     ),
//                   //     itemBuilder: (context, index) {
//                   //       final item = sortedProducts[index];
//                   //       // final product = sortedProducts[index];
//                   //       return GestureDetector(
//                   //         onTap: () {
//                   //           Navigator.push(
//                   //             context,
//                   //             MaterialPageRoute(
//                   //               builder: (context) =>
//                   //                   ProductDetailNewInDetailScreen(product: item),
//                   //             ),
//                   //           );
//                   //         },
//                   //         child: Card(
//                   //           color: Colors.white,
//                   //           elevation: 1,
//                   //           child: Column(
//                   //             crossAxisAlignment: CrossAxisAlignment.start,
//                   //             children: [
//                   //               Flexible(
//                   //                 child: Image.network(
//                   //                   product.prodSmallImg,
//                   //                   width: double.infinity,
//                   //                   height: 550,
//                   //                   fit: BoxFit.cover,
//                   //                   errorBuilder: (context, error, stackTrace) {
//                   //                     return Container(
//                   //                       height: 550,
//                   //                       color: Colors.grey[300],
//                   //                       alignment: Alignment.center,
//                   //                       child: const Icon(Icons.image_not_supported, size: 50),
//                   //                     );
//                   //                   },
//                   //                 ),
//                   //               ),
//                   //               const SizedBox(height: 8),
//                   //               Padding(
//                   //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   //                 child: Center(
//                   //                   child: Text(
//                   //                     product.designerName,
//                   //                     style: AppTextStyle.designerName,
//                   //                     textAlign: TextAlign.center,
//                   //                     maxLines: 1,
//                   //                     overflow: TextOverflow.ellipsis,
//                   //                   ),
//                   //                 ),
//                   //               ),
//                   //               Padding(
//                   //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   //                 child: Center(
//                   //                   child: Text(
//                   //                     product.shortDesc,
//                   //                     textAlign: TextAlign.center,
//                   //                     style: AppTextStyle.shortDescription,
//                   //                     maxLines: 2,
//                   //                     overflow: TextOverflow.ellipsis,
//                   //                   ),
//                   //                 ),
//                   //               ),
//                   //               Padding(
//                   //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   //                 child: Center(
//                   //                   child: Text(
//                   //                     "₹${product.actualPrice.toStringAsFixed(0)}",
//                   //                     style: AppTextStyle.actualPrice,
//                   //                     textAlign: TextAlign.center,
//                   //                   ),
//                   //                 ),
//                   //               ),
//                   //             ],
//                   //           ),
//                   //         ),
//                   //       );
//                   //     },
//                   //   ),
//                   // ),
//                 ],
//               ),
//             );
//           }
//           return const SizedBox();
//         },
//       ),
//
//       /// Floating Filter Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (context) => const FilterBottomSheet(),
//           );
//         },
//         child: const Icon(Icons.filter_list_alt),
//         backgroundColor: Colors.white,
//       ),
//     );
//   }
//
// }



