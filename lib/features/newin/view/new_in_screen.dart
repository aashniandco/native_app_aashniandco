import 'package:aashni_app/constants/text_styles.dart';
import 'package:aashni_app/features/newin/bloc/new_in_bloc.dart';
import 'package:aashni_app/features/newin/bloc/product_te.dart';
import 'package:aashni_app/features/newin/model/new_in_model.dart';
import 'package:aashni_app/features/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String selectedSort = "High to Low";
  List<Product> sortedProducts = [];

  @override
  void initState() {
    super.initState();
    final selectedData = widget.selectedCategories;

    // Example: Filter products based on category/subCategory if needed
    debugPrint("Selected Categories: $selectedData");
    context.read<NewInBloc>().add(FetchNewIn());
  }

  void sortProducts(List<Product> products) {
    sortedProducts = List<Product>.from(products); // Clone
    if (selectedSort == "High to Low") {
      sortedProducts.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
    } else {
      sortedProducts.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
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
            sortProducts(state.products);

            if (sortedProducts.isEmpty) {
              return const Center(child: Text("No products found"));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 35,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey),
                      child: DropdownButton<String>(
                        value: selectedSort,
                        icon: const Icon(Icons.sort, color: Colors.black),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        dropdownColor: Colors.grey,
                        underline: Container(),
                        onChanged: (value) {
                          setState(() {
                            selectedSort = value!;
                            sortProducts(state.products);
                          });
                        },
                        items: ["High to Low", "Low to High"].map((sortOption) {
                          return DropdownMenuItem<String>(
                            value: sortOption,
                            child: Text(sortOption, style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      itemCount: sortedProducts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.55,
                      ),
                      itemBuilder: (context, index) {
                        final product = sortedProducts[index];
                        return Card(
                          color: Colors.white,
                          elevation: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Image.network(
                                  product.prodSmallImg,
                                  width: double.infinity,
                                  height: 550,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 550,
                                      color: Colors.grey[300],
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.image_not_supported, size: 50),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Center(
                                  child: Text(
                                    product.designerName,
                                    style: AppTextStyle.designerName,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Center(
                                  child: Text(
                                    product.shortDesc,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.shortDescription,

                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Center(
                                  child: Text(
                                    "₹${product.actualPrice.toStringAsFixed(0)}",
                                    style: AppTextStyle.actualPrice,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),

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



