import 'package:aashni_app/features/designer/model/designer_model.dart';
import 'package:aashni_app/features/designer_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'designers_bloc.dart';

class DesignersScreen extends StatefulWidget {
  @override
  _DesignersScreenState createState() => _DesignersScreenState();
}

class _DesignersScreenState extends State<DesignersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = true;
  double _lastScrollOffset = 0;
  List<Designer> filteredDesigners = [];
  Map<String, List<Designer>> groupedDesigners = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  // void _handleScroll() {
  //   double currentOffset = _scrollController.offset;
  //   if (currentOffset > _lastScrollOffset && _isSearchVisible) {
  //     setState(() => _isSearchVisible = false);
  //   } else if (currentOffset < _lastScrollOffset && !_isSearchVisible) {
  //     setState(() => _isSearchVisible = true);
  //   }
  //   _lastScrollOffset = currentOffset;
  // }

  void _handleScroll() {
    double currentOffset = _scrollController.offset;
    if (mounted) {
      setState(() {
        _isSearchVisible = currentOffset < _lastScrollOffset;
      });
    }
    _lastScrollOffset = currentOffset;
  }


  /// **Groups designers alphabetically**
  // void _groupDesigners(List<Designer> designers) {
  //   Map<String, List<Designer>> grouped = {};
  //   for (var designer in designers) {
  //     String firstLetter = designer.name[0].toUpperCase();
  //     if (RegExp(r'^[0-9]').hasMatch(firstLetter)) firstLetter = '#';
  //     grouped.putIfAbsent(firstLetter, () => []).add(designer);
  //   }
  //   setState(() {
  //     groupedDesigners = Map.fromEntries(grouped.entries.toList()
  //       ..sort((a, b) => a.key == '#' ? -1 : b.key == '#' ? 1 : a.key.compareTo(b.key)));
  //   });
  // }

  void _groupDesigners(List<Designer> designers) {
    Map<String, List<Designer>> grouped = {};
    for (var designer in designers) {
      String firstLetter = designer.name[0].toUpperCase();
      if (RegExp(r'^[0-9]').hasMatch(firstLetter)) firstLetter = '#';
      grouped.putIfAbsent(firstLetter, () => []).add(designer);
    }
    if (mounted) {
      setState(() {
        groupedDesigners = Map.fromEntries(grouped.entries.toList()
          ..sort((a, b) => a.key == '#' ? -1 : b.key == '#' ? 1 : a.key.compareTo(b.key)));
      });
    }
  }


  /// **Filters designers based on search query**
  // void _filterDesigners(String query, List<Designer> allDesigners) {
  //   List<Designer> tempFilteredDesigners;
  //
  //   if (query.isEmpty) {
  //     tempFilteredDesigners = List.from(allDesigners);
  //   } else {
  //     tempFilteredDesigners = allDesigners
  //         .where((designer) => designer.name.toLowerCase().contains(query.toLowerCase()))
  //         .toList();
  //   }
  //
  //   setState(() {
  //     filteredDesigners = tempFilteredDesigners;
  //     _groupDesigners(filteredDesigners);  // Ensure it updates groupedDesigners
  //   });
  // }


  void _filterDesigners(String query, List<Designer> allDesigners) {
    List<Designer> tempFilteredDesigners = query.isEmpty
        ? List.from(allDesigners)
        : allDesigners.where((designer) => designer.name.toLowerCase().contains(query.toLowerCase())).toList();

    if (mounted) {
      setState(() {
        filteredDesigners = tempFilteredDesigners;
        _groupDesigners(filteredDesigners);
      });
    }
  }

  @override
  void dispose() {
    context.read<DesignersBloc>().close();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DesignersBloc()..add(FetchDesigners()),
      child: Scaffold(
        body: Stack(
          children: [
            // **📌 BlocListener to handle state changes**
            BlocListener<DesignersBloc, DesignersState>(
            listener: (context, state) {
        if (!mounted) return; // ✅ Prevent setState if widget is disposed
        if (state is DesignersLoaded) {
        setState(() {
        filteredDesigners = List.from(state.designers);
        _groupDesigners(filteredDesigners);
        });
        }
        },

              child: BlocBuilder<DesignersBloc, DesignersState>(
                builder: (context, state) {
                  if (state is DesignersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DesignersLoaded) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(top: _isSearchVisible ? 80 : 0),
                      itemCount: groupedDesigners.length,
                      itemBuilder: (context, index) {
                        String firstLetter = groupedDesigners.keys.elementAt(index);
                        List<Designer> designerList = groupedDesigners[firstLetter]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              color: Colors.grey[300],
                              width: double.infinity,
                              child: Text(
                                firstLetter,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...designerList.map((designer) {
                              return ListTile(
                                title: Text(designer.name),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DesignerDetailScreen(designerName: designer.name),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    );
                  } else if (state is DesignersError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),

            // **🔎 Search Bar (Positioned)**
            if (_isSearchVisible)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (query) {
                              final state = context.read<DesignersBloc>().state;
                              if (state is DesignersLoaded) {
                                _filterDesigners(query, state.designers);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Search designers...",
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          final state = context.read<DesignersBloc>().state;
                          if (state is DesignersLoaded) {
                            _filterDesigners('', state.designers);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
