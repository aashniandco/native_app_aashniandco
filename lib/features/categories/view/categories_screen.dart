import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../newin/view/new_in_category_designer.dart';
import '../../newin/view/new_in_screen.dart';
import '../bloc/megamenu_bloc.dart';
import '../bloc/megamenu_event.dart';
import '../bloc/megamenu_state.dart';
import '../repository/megamenu_repository.dart';
import 'menu_categories_screen.dart';
import 'menu_categories_screen1.dart'; // Make sure this import is correct

// No changes needed here
class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MegamenuBloc(MegamenuRepository())..add(LoadMegamenu()),
      child: CategoriesView(),
    );
  }
}

class CategoriesView extends StatelessWidget {
  // 1. Implement the navigation logic in this function
  void _navigateToMenuScreen(BuildContext context, String categoryName) {
    final nameLower = categoryName.toLowerCase();

    if (nameLower.contains('NEW IN')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NewInScreen(selectedCategories: [],)), // Replace with your NewInScreen
      );
    } else if (nameLower.contains('DESIGNERS') || nameLower.contains('designers')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DesignerListScreen()), // Replace with your Designer screen
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MenuCategoriesScreen(categoryName: categoryName),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: Add an AppBar for better UI
      // appBar: AppBar(
      //   // title: Text('Categories'),
      // ),
      body: BlocBuilder<MegamenuBloc, MegamenuState>(
        builder: (context, state) {
          if (state is MegamenuLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is MegamenuLoaded) {
            final categories = state.menuNames;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final name = categories[index];
                  return GestureDetector(
                    // 2. Call the function with the specific category name
                    onTap: () => _navigateToMenuScreen(context, name),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.vertical(top: Radius.circular(8)),
                              child: Image.asset(
                                "assets/Banner-3.jpeg", // Replace with dynamic image if available
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is MegamenuError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Center(child: Text('No categories found.'));
          }
        },
      ),
    );
  }
}


// import 'package:aashni_app/features/newin/view/new_in_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/megamenu_bloc.dart';
// import '../bloc/megamenu_event.dart';
// import '../bloc/megamenu_state.dart';
//
// import '../repository/megamenu_repository.dart';
// import 'menu_categories_screen.dart';
// import 'package:http/io_client.dart';
//
// class CategoriesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => MegamenuBloc(MegamenuRepository())..add(LoadMegamenu()),
//       child: CategoriesView(),
//     );
//   }
// }
//
// class CategoriesView extends StatelessWidget {
//   void _navigateToMenuScreen(BuildContext context, String category) {
//     // if (category == 'NEW IN') {
//     //   Navigator.push(
//     //     context,
//     //     MaterialPageRoute(builder: (_) => NewInScreen(selectedCategories: [],)),
//     //   );
//     // }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<MegamenuBloc, MegamenuState>(
//         builder: (context, state) {
//           if (state is MegamenuLoading) {
//             return Center(child: CircularProgressIndicator());
//           } else if (state is MegamenuLoaded) {
//             final categories = state.menuNames;
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                   childAspectRatio: 3 / 2,
//                 ),
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   final name = categories[index];
//                   return GestureDetector(
//                     onTap: () => _navigateToMenuScreen(context, name),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.grey[200],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
//                               child: Image.asset(
//                                 "assets/Banner-3.jpeg", // use dynamic if needed
//                                 fit: BoxFit.cover,
//                                 width: double.infinity,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               name,
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           } else if (state is MegamenuError) {
//             return Center(child: Text('Error: ${state.message}'));
//           } else {
//             return Center(child: Text('No data'));
//           }
//         },
//       ),
//     );
//   }
// }
