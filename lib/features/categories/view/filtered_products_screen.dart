import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import your new BLoC and related files
import '../bloc/filtered_products_bloc.dart';
import '../../newin/model/new_in_model.dart';
import '../bloc/filtered_products_state.dart'; // Reuse the Product model

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import your BLoC, models, and other necessary files
import '../bloc/filtered_products_bloc.dart';
import '../../newin/model/new_in_model.dart'; // Reuse the Product model
import '../../newin/view/product_details_newin.dart'; // For navigation to detail screen
import 'dart:convert'; // For jsonEncode in onTap


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/filtered_products_bloc.dart';
import '../../newin/model/new_in_model.dart';
import '../../newin/view/product_details_newin.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert'; // For jsonEncode in onTap

// Import your BLoC, models, and other necessary files
import '../bloc/filtered_products_bloc.dart';
import '../../newin/model/new_in_model.dart';
import '../../newin/view/product_details_newin.dart';

// The parent widget's only jobs are to receive data and provide the BLoC.
class FilteredProductsScreen extends StatelessWidget {
  final String categoryId;
  final List<Map<String, dynamic>> selectedFilters;

  const FilteredProductsScreen({
    Key? key,
    required this.categoryId,
    required this.selectedFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String appBarTitle = selectedFilters.map((f) => f['name']).join(', ');
    if (appBarTitle.length > 25) appBarTitle = 'Filtered Results';

    return BlocProvider(
      // 1. CHANGE: The BlocProvider now ONLY creates the BLoC.
      // We removed "..add()" because the initial fetch should be triggered
      // by the view itself, once it has the complete filter information.
      create: (context) => FilteredProductsBloc(),
      child: _FilteredProductsView(
        headerTitle: appBarTitle,
        // 2. CHANGE: Pass ALL necessary data down to the view.
        categoryId: categoryId,
        selectedFilters: selectedFilters,
      ),
    );
  }
}

// The view is a StatefulWidget to manage the ScrollController and initial data fetch.
class _FilteredProductsView extends StatefulWidget {
  final String headerTitle;
  // 3. CHANGE: Add categoryId here to receive it from the parent.
  final String categoryId;
  final List<Map<String, dynamic>> selectedFilters;

  const _FilteredProductsView({
    required this.headerTitle,
    required this.categoryId,
    required this.selectedFilters,
  });

  @override
  State<_FilteredProductsView> createState() => _FilteredProductsViewState();
}

class _FilteredProductsViewState extends State<_FilteredProductsView> {
  final ScrollController _scrollController = ScrollController();
  // This will be the single source of truth for all filters.
  late final List<Map<String, dynamic>> _allFilters;

  @override
  void initState() {
    super.initState();

    // 4. CHANGE: This logic now works perfectly because widget.categoryId exists.
    // We combine the base category filter with the user's selections.
    final baseCategoryFilter = {
      'id': widget.categoryId,
      'type': 'categories',
    };

    _allFilters = [
      baseCategoryFilter,
      ...widget.selectedFilters,
    ];

    // 5. CHANGE: This is now the ONE place we trigger the initial fetch,
    // and it uses the COMPLETE list of filters.
    context.read<FilteredProductsBloc>().add(
      FetchFilteredProducts(
        selectedFilters: _allFilters,
        page: 0,
      ),
    );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<FilteredProductsBloc>().state;
      if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
        context.read<FilteredProductsBloc>().add(
          FetchFilteredProducts(
            // 6. CHANGE: Use the complete "_allFilters" list for pagination.
            selectedFilters: _allFilters,
            page: (currentState.products.length / 20).ceil(),
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.headerTitle)),
      body: BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
        builder: (context, state) {
          if (state is FilteredProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FilteredProductsError) {
            return Center(child: Text(state.message));
          }
          if (state is FilteredProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text("No products found for this filter."));
            }
            // The rest of your build method is great and needs no changes.
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.headerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                        child: DropdownButton<String>(
                          value: state.currentSort,
                          icon: const Icon(Icons.sort, color: Colors.black),
                          underline: Container(),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<FilteredProductsBloc>().add(SortProducts(value));
                            }
                          },
                          items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
                            return DropdownMenuItem<String>(
                              value: sortOption,
                              child: Text(sortOption, style: const TextStyle(color: Colors.black, fontSize: 14)),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      itemCount: state.hasReachedEnd ? state.products.length : state.products.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.5),
                      itemBuilder: (context, index) {
                        if (index >= state.products.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final product = state.products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                ProductDetailNewInDetailScreen(product: product.toJson()),
                            ));
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  product.prodSmallImg,
                                  width: double.infinity, height: 250, fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(width: double.infinity, height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(product.designerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(product.shortDesc, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Text("₹${product.actualPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
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
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// class FilteredProductsScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const FilteredProductsScreen({Key? key, required this.selectedFilters}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Create a title based on selected filters for the AppBar
//     String appBarTitle = selectedFilters.map((f) => f['name']).join(', ');
//     if (appBarTitle.length > 30) appBarTitle = 'Filtered Results';
//
//     // ✅ LIFT THE BLOCPROVIDER UP
//     // The BlocProvider now wraps the entire screen.
//     return BlocProvider(
//       create: (context) => FilteredProductsBloc()
//         ..add(FetchFilteredProducts(selectedFilters: selectedFilters)),
//       child: _FilteredProductsView(
//         appBarTitle: appBarTitle,
//         selectedFilters: selectedFilters,
//       ),
//     );
//   }
// }

// // Create a new private widget for the view to get the correct context
// class _FilteredProductsView extends StatefulWidget {
//   final String appBarTitle;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const _FilteredProductsView({
//     Key? key,
//     required this.appBarTitle,
//     required this.selectedFilters
//   }) : super(key: key);
//
//   @override
//   State<_FilteredProductsView> createState() => _FilteredProductsViewState();
// }
//
// class _FilteredProductsViewState extends State<_FilteredProductsView> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     if (_isBottom) {
//       // ✅ THIS NOW WORKS
//       // The context here is a descendant of the BlocProvider.
//       final currentState = context.read<FilteredProductsBloc>().state;
//       if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
//         context.read<FilteredProductsBloc>().add(
//           FetchFilteredProducts(
//             selectedFilters: widget.selectedFilters,
//             page: (currentState.products.length / 20).ceil(),
//           ),
//         );
//       }
//     }
//   }
//
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.appBarTitle)),
//       body: BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
//         builder: (context, state) {
//           if (state is FilteredProductsLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (state is FilteredProductsError) {
//             return Center(child: Text(state.message));
//           }
//           if (state is FilteredProductsLoaded) {
//             if (state.products.isEmpty) {
//               return const Center(child: Text("No products found for this filter."));
//             }
//             return Column(
//               children: [
//                 Expanded(
//                   child: GridView.builder(
//                     controller: _scrollController,
//                     itemCount: state.hasReachedEnd
//                         ? state.products.length
//                         : state.products.length + 1,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2, childAspectRatio: 0.55),
//                     itemBuilder: (context, index) {
//                       if (index >= state.products.length) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       final product = state.products[index];
//                       // Return your standard product card widget
//                       return Card(child: Center(child: Text(product.designerName ?? '')));
//                     },
//                   ),
//                 ),
//               ],
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }