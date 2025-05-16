import 'package:aashni_app/features/newin/view/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/dialog.dart';
import '../../../constants/user_preferences_helper.dart';
import '../../auth/view/auth_screen.dart';
import '../../auth/view/login_screen.dart';
import '../../auth/view/wishlist_screen.dart';
import '../../categories/view/categories_screen.dart';
import '../../designer/bloc/designers_screen.dart';
import '../../shoppingbag/shopping_bag.dart';
import '../bloc/new_in_products_event.dart';
import '../bloc/new_in_products_state.dart';
import '../bloc/newin_products_bloc.dart';
import '../bloc/product_repository.dart';
import '../model/new_in_model.dart';

class NewInProductsScreen extends StatefulWidget {

  final String subcategory;
  final List<Map<String, dynamic>> selectedCategories;
  final String initialTab;
  final Widget Function(String selectedCategory, String selectedSort) productListBuilder;

  const NewInProductsScreen({
    super.key,
    required this.selectedCategories,
    required this.initialTab,
    required this.productListBuilder,
    required this.subcategory,
  });



  @override
  State<NewInProductsScreen> createState() => _NewInProductsScreenState();
}

class _NewInProductsScreenState extends State<NewInProductsScreen> {
  String selectedSort = "Latest";

  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    _loadUserNames();
    // Trigger the default sort to show "Latest" data
    context.read<NewInProductsBloc>().add(SortProductsEvent(SortOrder.latest));

    // Fetch products based on the selected subcategory (e.g., "Bags")
    // context.read<NewInProductsBloc>().add(FetchProductsBySubcategoryFilterEvent(widget.subcategory));
    // context.read<NewInProductsBloc>().add(FetchProductsBySubcategoryEvent(widget.subcategory));

    context.read<NewInProductsBloc>().add(FetchProductsBySubcategoryFilterEvent(widget.subcategory));
  }

  Future<void> _loadUserNames() async {
    final fName = await UserPreferences.getFirstName();
    final lName = await UserPreferences.getLastName();
    setState(() {
      firstName = fName;
      lastName = lName;
    });
  }
  @override
  Widget build(BuildContext context) {
    final selectedText = widget.selectedCategories
        .map((e) => e["subCategory"] ?? e["category"] ?? e["theme"])
        .whereType<String>()
        .join(", ");

    final tabTitles = ["Exclusives", "New In", "Categories", "Designers"];
    final initialIndex = tabTitles.indexOf("New In");

    final genders = widget.selectedCategories
        .map((e) => e['gender'])
        .whereType<String>()
        .toSet()
        .toList();

    final themes = widget.selectedCategories
        .map((e) => e['theme'])
        .whereType<String>()
        .toSet()
        .toList();

    final colors = widget.selectedCategories
        .map((e) => e['color'])
        .whereType<String>()
        .toSet()
        .toList();

    final sizes = widget.selectedCategories
        .map((e) => e['size'])
        .whereType<String>()
        .toSet()
        .toList();

    final shipin = widget.selectedCategories
        .map((e) => e['shipin'])
        .whereType<String>()
        .toSet()
        .toList();

    final acoedit = widget.selectedCategories
        .map((e) => e['acoedit'])
        .whereType<String>()
        .toSet()
        .toList();

    final occassions = widget.selectedCategories
        .map((e) => e['occassions'])
        .whereType<String>()
        .toSet()
        .toList();

    final price = widget.selectedCategories
        .map((e) => e['price'])
        .whereType<String>()
        .toSet()
        .toList();

    final filter = widget.selectedCategories
        .map((e) => e['filter'])
        .whereType<String>()
        .toSet()
        .toList();

    final subcat_filter= widget.selectedCategories
        .map((e) => e['subcat_filter'])
        .whereType<String>()
        .toSet()
        .toList();

    return BlocProvider(
      create: (_) {
        final bloc = NewInProductsBloc(
          productRepository: ProductRepository(),
          subcategory: widget.subcategory,
          selectedCategories: widget.selectedCategories,
        );

        if (shipin.isNotEmpty) {
          print("🎯 Fetching by SHIPSIN: $shipin");
          bloc.add(FetchProductsByShipsinEvent(shipin));
        }

        if (genders.isNotEmpty) {
          print("🎯 Fetching by GENDERS: $genders");
          bloc.add(FetchProductsByGendersEvent(genders));
        }

        if (colors.isNotEmpty) {
          print("🎯 Fetching by COLORS: $colors");
          bloc.add(FetchProductsByColorsEvent(colors));
        }

        if (themes.isNotEmpty) {
          print("🎯 Fetching by THEMES: $themes");
          bloc.add(FetchProductsByThemesEvent(themes));
        }

        if (sizes.isNotEmpty) {
          print("🎯 Fetching by SIZES: $sizes");
          bloc.add(FetchProductsBySizesEvent(sizes));
        }

        if (acoedit.isNotEmpty) {
          print("🎯 Fetching by acoedit: $acoedit");
          bloc.add(FetchProductsByAcoEditEvent(acoedit));
        }

        if (occassions.isNotEmpty) {
          print("🎯 Fetching by occassions: $occassions");
          bloc.add(FetchProductsByOccassionsEvent(occassions));
        }

        if (price.isNotEmpty) {
          print("🎯 Fetching by price: $price");
          bloc.add(FetchProductsByPricesEvent(price));
        }

        if (filter.isNotEmpty) {
          print("🎯 Fetching by cat_filter: $filter");
          bloc.add(FetchProductsByCategoryFilterEvent(filter));
        }

        // Send subcategory-specific event like "Bags"


        if (widget.subcategory.isNotEmpty) {
          bloc.add(FetchProductsBySubcategoryFilterEvent([widget.subcategory]));
        }

        return bloc;
      },
      child: DefaultTabController(
        length: 4,
        initialIndex: initialIndex,
        child: Scaffold(

          appBar: AppBar(
            title:
            Column(
              children: [
                Image.asset('assets/logo.jpeg', height: 30),
                const SizedBox(width: 10), // space between image and text
                // Text("Welcome $firstName $lastName", style: const TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.bold)),
              ],
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double fontSize = screenWidth > 360 ? 13 : 10;

                  return TabBar(
                    isScrollable: false,
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: tabTitles.map((title) {
                      return Tab(
                        child: Text(
                          title,
                          style: TextStyle(fontSize: fontSize),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const SearchScreen(),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_bag_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
                  );
                },
              ),
            ],
          ),
          body: TabBarView(
            children: [
              HomeScreen(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Builder(
                          builder: (innerContext) {
                            return Container(
                              height: 35,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DropdownButton<String>(
                                value: selectedSort,
                                icon: const Icon(Icons.sort, color: Colors.black),
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                dropdownColor: Colors.white,
                                underline: const SizedBox(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedSort = value;
                                    });

                                    final sortOrder = value == "High to Low"
                                        ? SortOrder.highToLow
                                        : value == "Low to High"
                                        ? SortOrder.lowToHigh
                                        : SortOrder.latest;

                                    innerContext.read<NewInProductsBloc>().add(SortProductsEvent(sortOrder));
                                  }
                                },
                                items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
                                  return DropdownMenuItem<String>(
                                    value: sortOption,
                                    child: Text(sortOption),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<NewInProductsBloc, NewInProductsState>(
                      builder: (context, state) {
                        if (state is NewInProductsLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is NewInProductsLoaded) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: state.products.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 270,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemBuilder: (context, index) =>
                                ProductCard(product: state.products[index]),
                          );
                        } else if (state is NewInProductsError) {
                          return Center(child: Text(state.message));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
              CategoriesPage(),
              DesignersScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (route) => false,
                  );
                  break;
                case 1:
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                        (route) => false,
                  );
                  break;
                case 2:
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                        (route) => false,
                  );
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}


// class NewInProductsScreen extends StatefulWidget {
//   final String subcategory;
//   final List<Map<String, dynamic>> selectedCategories;
//   final String initialTab;
//
//   final Widget Function(String selectedCategory, String selectedSort) productListBuilder;
//
//   const NewInProductsScreen({super.key,  required this.selectedCategories,
//
//     required this.initialTab,
//     required this.productListBuilder,required this.subcategory});
//
//   @override
//   State<NewInProductsScreen> createState() => _NewInProductsScreenState();
// }
// class _NewInProductsScreenState extends State<NewInProductsScreen> {
//   String selectedSort = "Latest";
//
//   @override
//   void initState() {
//     super.initState();
//     // Trigger the default sort to show "Latest" data
//     context.read<NewInProductsBloc>().add(SortProductsEvent(SortOrder.latest));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final selectedText = widget.selectedCategories
//         .map((e) => e["subCategory"] ?? e["category"] ?? e["theme"])
//         .whereType<String>()
//         .join(", ");
//
//     final tabTitles = ["Exclusives", "New In", "Categories", "Designers"];
//     final initialIndex = tabTitles.indexOf("New In");
//
//     //************** add all direct calls categories
//     // final gender = widget.selectedCategories
//     //     .map((e) => e['gender'])
//     //     .whereType<String>()
//     //     .firstOrNull ?? "Women"; // fallback if nothing is found
//
//
//
//
//     final genders = widget.selectedCategories
//         .map((e) => e['gender'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     // if (genders.isEmpty) genders.add("Women"); // Fallback
//
//     print("🧍 Genders selected: $genders");
//
//     final themes = widget.selectedCategories
//         .map((e) => e['theme'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     // if (themes.isEmpty) themes.add("Ethnic"); // Fallback
//
//     print("🧍 Themes selected: $themes");
//     //************** add all direct calls categories
//     final colors = widget.selectedCategories
//         .map((e) => e['color'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//     print("🧍 Colors selected: $colors");
//
//     final sizes = widget.selectedCategories
//         .map((e) => e['size'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//     print("🧍 Sizes selected: $sizes");
//
//     final shipin = widget.selectedCategories
//         .map((e) => e['shipin'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//     print("🧍 Shipin selected: $shipin");
//
//     final acoedit = widget.selectedCategories
//         .map((e) => e['acoedit'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//     print("🧍 acoedit selected: $acoedit");
//
//
//     return DefaultTabController(
//       length: 4,
//       initialIndex: initialIndex,
//       child: BlocProvider(
//         create: (_) {
//           final bloc = NewInProductsBloc(
//             productRepository: ProductRepository(),
//             subcategory: widget.subcategory,
//             selectedCategories: widget.selectedCategories,
//           );
//           if (shipin.isNotEmpty) {
//             print("🎯 Fetching by SHIPSIN: $shipin");
//             bloc.add(FetchProductsByShipsinEvent(shipin));
//           }
//
//           if (genders.isNotEmpty) {
//             print("🎯 Fetching by GENDERS: $genders");
//             bloc.add(FetchProductsByGendersEvent(genders));
//           }
//
//           if (colors.isNotEmpty) {
//             print("🎯 Fetching by COLORS: $colors");
//             bloc.add(FetchProductsByColorsEvent(colors));
//           }
//
//           if (themes.isNotEmpty) {
//             print("🎯 Fetching by THEMES: $themes");
//             bloc.add(FetchProductsByThemesEvent(themes));
//           }
//
//           if (sizes.isNotEmpty) {
//             print("🎯 Fetching by SIZES: $sizes");
//             bloc.add(FetchProductsBySizesEvent(sizes));
//           }
//
//           if (acoedit.isNotEmpty) {
//             print("🎯 Fetching by acoedit: $acoedit");
//             bloc.add(FetchProductsByAcoEditEvent(acoedit));
//           }
//           return bloc;
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: Image.asset('assets/logo.jpeg', height: 30),
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(kToolbarHeight),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   double screenWidth = constraints.maxWidth;
//                   double fontSize = screenWidth > 360 ? 13 : 10;
//
//                   return TabBar(
//                     isScrollable: false,
//                     labelColor: Colors.black,
//                     indicatorColor: Colors.black,
//                     unselectedLabelColor: Colors.grey,
//                     tabs: tabTitles.map((title) {
//                       return Tab(
//                         child: Text(
//                           title,
//                           style: TextStyle(fontSize: fontSize),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => const SearchScreen(),
//                   );
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.shopping_bag_rounded),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//           body: TabBarView(
//             children: [
//
//               HomeScreen(),
//
//               // ✅ New In Products Tab
//               Column(
//                 children: [
//
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           selectedText,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//
//                         // ✅ Wrap DropdownButton in Builder to get correct context
//                         Builder(
//                           builder: (innerContext) {
//                             return Container(
//                               height: 35,
//                               padding: const EdgeInsets.symmetric(horizontal: 12),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: DropdownButton<String>(
//                                 value: selectedSort,
//                                 icon: const Icon(Icons.sort, color: Colors.black),
//                                 style: const TextStyle(color: Colors.black, fontSize: 14),
//                                 dropdownColor: Colors.white,
//                                 underline: const SizedBox(),
//                                 onChanged: (value) {
//                                   if (value != null) {
//                                     setState(() {
//                                       selectedSort = value;
//                                     });
//
//                                     final sortOrder = value == "High to Low"
//                                         ? SortOrder.highToLow
//                                         : value == "Low to High"
//                                         ? SortOrder.lowToHigh
//                                         : SortOrder.latest;
//
//
//                                     innerContext.read<NewInProductsBloc>().add(SortProductsEvent(sortOrder));
//                                   }
//                                 },
//                                 items: ["Latest","High to Low", "Low to High"].map((sortOption) {
//                                   return DropdownMenuItem<String>(
//                                     value: sortOption,
//                                     child: Text(sortOption),
//                                   );
//                                 }).toList(),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: BlocBuilder<NewInProductsBloc, NewInProductsState>(
//                       builder: (context, state) {
//                         if (state is NewInProductsLoading) {
//                           return const Center(child: CircularProgressIndicator());
//                         } else if (state is NewInProductsLoaded) {
//                           return GridView.builder(
//                             padding: const EdgeInsets.all(12),
//                             itemCount: state.products.length,
//                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               mainAxisExtent: 270,
//                               crossAxisSpacing: 10,
//                               mainAxisSpacing: 10,
//                             ),
//                             itemBuilder: (context, index) =>
//                                 ProductCard(product: state.products[index]),
//                           );
//                         } else if (state is NewInProductsError) {
//                           return Center(child: Text(state.message));
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//
//               CategoriesPage(),
//               DesignersScreen(),
//             ],
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//               BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
//               BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
//             ],
//             onTap: (index) {
//               switch (index) {
//                 case 0:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AuthScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 1:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const WishlistScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 2:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AccountScreen()),
//                         (route) => false,
//                   );
//                   break;
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
// class _NewInProductsScreenState extends State<NewInProductsScreen> {
//   String selectedSort = "High to Low";
//
//
//   @override
//   Widget build(BuildContext context) {
//     // final selectedText = widget.selectedCategories.isNotEmpty
//     //     ? (widget.selectedCategories[0]["subCategory"] ?? widget.selectedCategories[0]["category"])
//     //     : "No Category Selected";
//     final selectedText = widget.selectedCategories
//         .map((e) => e["subCategory"] ?? e["category"] ?? e["theme"])
//         .whereType<String>()
//         .join(", ");
//
//     final tabTitles = ["Exclusives", "New In", "Categories", "Designers"];
//     final initialIndex = tabTitles.indexOf("New In");
//
//     return DefaultTabController(
//       length: 4,
//       initialIndex: initialIndex,
//       child: BlocProvider(
//         // create: (_) => NewInProductsBloc(
//         //   productRepository: ProductRepository(),
//         //   subcategory: widget.subcategory,
//         // )
//
//         create: (_) => NewInProductsBloc(
//           productRepository: ProductRepository(),
//           subcategory: widget.subcategory,
//           selectedCategories: widget.selectedCategories,
//         )
//
//           ..add(FetchProductsEvent()),
//         child: Scaffold(
//           appBar: AppBar(
//             title: Image.asset('assets/logo.jpeg', height: 30),
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(kToolbarHeight),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   double screenWidth = constraints.maxWidth;
//                   double fontSize = screenWidth > 360 ? 13 : 10;
//
//                   return TabBar(
//                     isScrollable: false,
//                     labelColor: Colors.black,
//                     indicatorColor: Colors.black,
//                     unselectedLabelColor: Colors.grey,
//                     tabs: tabTitles.map((title) {
//                       return Tab(
//                         child: Text(
//                           title,
//                           style: TextStyle(fontSize: fontSize),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => const SearchScreen(),
//                   );
//                 },
//               ),
//
//
//
//
//
//               IconButton(
//                 icon: const Icon(Icons.shopping_bag_rounded),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//           body: TabBarView(
//             children: [
//               HomeScreen(),
//
//               /// New In Tab (Product List)
//             Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "$selectedText",
//                         style: const TextStyle(
//                           fontSize: 16,
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
//                           style: const TextStyle(color: Colors.black, fontSize: 14),
//                           dropdownColor: Colors.white,
//                           underline: const SizedBox(),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedSort = value!;
//                               final sortOrder = selectedSort == "High to Low"
//                                   ? SortOrder.highToLow
//                                   : SortOrder.lowToHigh;
//                               context.read<NewInProductsBloc>().add(SortProductsEvent(sortOrder));
//                             });
//                           },
//                           items: ["High to Low", "Low to High"].map((sortOption) {
//                             return DropdownMenuItem<String>(
//                               value: sortOption,
//                               child: Text(sortOption),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: BlocBuilder<NewInProductsBloc, NewInProductsState>(
//                     builder: (context, state) {
//                       if (state is NewInProductsLoading) {
//                         return const Center(child: CircularProgressIndicator());
//                       } else if (state is NewInProductsLoaded) {
//                         return GridView.builder(
//                           padding: const EdgeInsets.all(12),
//                           itemCount: state.products.length,
//                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             mainAxisExtent: 270,
//                             crossAxisSpacing: 10,
//                             mainAxisSpacing: 10,
//                           ),
//                           itemBuilder: (context, index) =>
//                               ProductCard(product: state.products[index]),
//                         );
//                       } else if (state is NewInProductsError) {
//                         return Center(child: Text(state.message));
//                       }
//                       return const SizedBox.shrink();
//                     },
//                   ),
//                 ),
//               ],
//             ),
//
//
//               CategoriesPage(),
//               DesignersScreen(),
//             ],
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//               BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
//               BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
//             ],
//             onTap: (index) {
//               switch (index) {
//                 case 0:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AuthScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 1:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const WishlistScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 2:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AccountScreen()),
//                         (route) => false,
//                   );
//                   break;
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
