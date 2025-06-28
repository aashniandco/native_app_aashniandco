
import 'package:flutter/material.dart';

import '../../../categories/model/filter_model.dart';
import '../../../categories/repository/api_service.dart';
import '../../../categories/view/filtered_products_screen.dart';

class GenericFilterScreen extends StatefulWidget {
  final String categoryId;
  final String filterType; // e.g., 'categories', 'designers'
  final String appBarTitle;

  const GenericFilterScreen({
    Key? key,
    required this.categoryId,
    required this.filterType,
    required this.appBarTitle,
  }) : super(key: key);

  @override
  State<GenericFilterScreen> createState() => _GenericFilterScreenState();
}

class _GenericFilterScreenState extends State<GenericFilterScreen> {
  late Future<List<FilterItem>> _filterFuture;
  final ApiService _apiService = ApiService();
  List<FilterItem> _dynamicFilterList = [];

  @override
  void initState() {
    super.initState();
    _filterFuture = _apiService.fetchGenericFilter(
      categoryId: widget.categoryId,
      filterType: widget.filterType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<FilterItem>>(
              future: _filterFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No ${widget.filterType} found.'));
                }

                if (_dynamicFilterList.isEmpty) {
                  _dynamicFilterList = snapshot.data!;
                }

                return ListView.builder(
                  itemCount: _dynamicFilterList.length,
                  itemBuilder: (context, index) {
                    final item = _dynamicFilterList[index];
                    return _buildFilterTile(item);
                  },
                );
              },
            ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }
  Widget _buildFilterTile(FilterItem item) {
    // A common container style for both tile types
    final containerDecoration = BoxDecoration(
      color: const Color(0xFFD3D4D3),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 4,
          offset: const Offset(0, 3),
        ),
      ],
    );

    // CASE 1: The item has children, so we build an expandable tile.
    if (item.children.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: containerDecoration,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.only(bottom: 12, left: 20),
            title: Row(
              children: [
                Checkbox(
                  value: item.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      item.isSelected = value!;
                      // If the parent is selected, deselect all its children
                      if (value) {
                        for (var child in item.children) {
                          child.isSelected = false;
                        }
                      }
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
            initiallyExpanded: item.isExpanded,
            onExpansionChanged: (bool expanded) {
              setState(() {
                item.isExpanded = expanded;
              });
            },
            children: item.children.map<Widget>((child) {
              return Row(
                children: [
                  Checkbox(
                    value: child.isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        child.isSelected = value!;
                        // If a child is selected, deselect the parent
                        if (value) {
                          item.isSelected = false;
                        }
                      });
                    },
                  ),
                  Expanded(child: Text(child.name)),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }
    // CASE 2: The item has NO children, so we build a simple, non-expandable tile.
    else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: containerDecoration,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            children: [
              Checkbox(
                value: item.isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    item.isSelected = value!;
                  });
                },
              ),
              Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  )
              ),
            ],
          ),
          onTap: () {
            // Allow tapping the whole row to toggle the checkbox
            setState(() {
              item.isSelected = !item.isSelected;
            });
          },
        ),
      );
    }
  }

  Widget _buildApplyButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          onPressed: () {
            List<Map<String, dynamic>> selectedItems = [];
            for (var item in _dynamicFilterList) {
              if (item.isSelected) {
                selectedItems.add({"id": item.id, "name": item.name, "type": widget.filterType});
              }
              for (var child in item.children) {
                if (child.isSelected) {
                  selectedItems.add({"id": child.id, "name": child.name, "type": widget.filterType});
                }
              }
            }

            if (selectedItems.isNotEmpty) {
              print('Applying Filters: $selectedItems');

              // ✅ NAVIGATE TO THE NEW DEDICATED RESULTS SCREEN
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FilteredProductsScreen(
                    categoryId: widget.categoryId,
                    selectedFilters: selectedItems,
                  ),
                ),
              );

            } else {
              Navigator.pop(context); // Just close the filter screen if nothing was selected
            }
          },
          child: const Text("Apply", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}