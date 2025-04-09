
import 'package:aashni_app/constants/text_styles.dart';
import 'package:aashni_app/features/auth/view/login_screen.dart';
import 'package:aashni_app/features/newin/bloc/new_in_bloc.dart';
import 'package:aashni_app/features/newin/bloc/product_te.dart';
import 'package:aashni_app/features/newin/model/new_in_model.dart';
import 'package:aashni_app/features/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/dialog.dart';
import '../../auth/view/auth_screen.dart';
import '../../auth/view/wishlist_screen.dart';
import '../../categories/view/categories_screen.dart';
import '../../designer/bloc/designers_screen.dart';
import '../../shoppingbag/shopping_bag.dart';
import 'filter_bottom_sheet.dart';
import '../bloc/new_in_state.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'new_in_screen.dart'; // For NewInScreen

class NewInFilterScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedCategories;

  const NewInFilterScreen({super.key, required this.selectedCategories});

  @override
  Widget build(BuildContext context) {
    final selectedText = selectedCategories.isNotEmpty
        ? selectedCategories[0]["category"]
        : "No Category Selected";

    final bool isLoading = false; // Replace with your real authState check

    return DefaultTabController(
      length: 4,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/logo.jpeg',
            height: 30,
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelPadding: EdgeInsets.symmetric(horizontal: 0),
            tabs: [
              Tab(child: Text("Exclusives", style: TextStyle(fontSize: 14))),
              Tab(child: Text("New In", style: TextStyle(fontSize: 14))),
              Tab(child: Text("Categories", style: TextStyle(fontSize: 14))),
              Tab(child: Text("Designers", style: TextStyle(fontSize: 14))),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => const SearchScreen(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_bag_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShoppingBagScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            // 1. Exclusives tab
            HomeScreen(),

            // 2. New In tab with selected filter applied
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Filtered by: $selectedText",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NewInScreen(selectedCategories: []),
                            ),
                          );
                        },
                        child: const Text("Clear Filter"),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: NewInScreen(
                    selectedCategories: selectedCategories,
                  ),
                ),
              ],
            ),

            // 3. Categories tab
            CategoriesPage(),

            // 4. Designers tab
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
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (Route<dynamic> route) => false,
                );
                break;
              case 1:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistScreen()),
                      (Route<dynamic> route) => false,
                );
                break;
              case 2:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                      (Route<dynamic> route) => false,
                );
                break;
            }
          },
        ),
      ),
    );
  }
}


// class NewInFilterScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//
//   const NewInFilterScreen({super.key, required this.selectedCategories});
//
//   @override
//   Widget build(BuildContext context) {
//     // Safely get the category name (in your case it'll be "Women's Clothing")
//     final selectedText = selectedCategories.isNotEmpty
//         ? selectedCategories[0]["category"]
//         : "No Category Selected";
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("New In Filter"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: Center(
//         child: Text(
//           "Selected Category: $selectedText",
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }
