
import 'package:flutter/material.dart';
import 'menu_categories_screen.dart';  // Import the new screen that we will create

class CategoriesPage extends StatefulWidget {
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}
//https://reqres.in/api/login
class _CategoriesPageState extends State<CategoriesPage> {
  final List<Map<String, String>> categories = [
    {"name": "New Season>>", "image": "assets/Banner-3.jpeg"},
    {"name": "Men", "image": "assets/mens1.png"},
    {"name": "Women", "image": "assets/Banner-3.jpeg"},
    {"name": "Kids", "image": "assets/kids.png"},
    {"name": "Shoes", "image": "assets/Banner-3.jpeg"},
    {"name": "Accessories", "image": "assets/Banner-3.jpeg"},
    {"name": "Weddings", "image": "assets/Banner-3.jpeg"},
    {"name": "BestSeller", "image": "assets/Banner-3.jpeg"},  
    {"name": "Jewellery", "image": "assets/Banner-3.jpeg"},
    {"name": "Sale", "image": "assets/Banner-3.jpeg"},
    {"name": "Ready To Ship", "image": "assets/Banner-3.jpeg"},
    {"name": "Journal", "image": "assets/Banner-3.jpeg"},
  ];

  void _navigateToMenuScreen() {
    // Navigate to the Menu screen when "Men" category is tapped
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShopByCategoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3 / 2, // Adjust for rectangle shapes
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (categories[index]['name'] == 'Men') {
                  _navigateToMenuScreen(); // Navigate to menu screen when "Men" is clicked
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: Image.asset(
                          categories[index]['image']!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    // Text Section
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        categories[index]['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
      ),
    );
  }
}
