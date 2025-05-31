import 'package:aashni_app/bloc/login/login_screen_bloc.dart';
import 'package:aashni_app/features/auth/view/auth_screen.dart';
import 'package:aashni_app/features/auth/view/login_screen.dart';
import 'package:aashni_app/features/checkout/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import ' shipping_bloc/shipping_bloc.dart';
import ' shipping_bloc/shipping_event.dart';
import ' shipping_bloc/shipping_state.dart';
import 'cart_bloc/cart_bloc.dart';
import 'cart_bloc/cart_event.dart';
import 'cart_bloc/cart_state.dart';
import 'cart_item_widget.dart';
import 'model/countries.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class ShoppingBagScreen extends StatefulWidget {
  @override
  _ShoppingBagScreenState createState() => _ShoppingBagScreenState();
}

  class _ShoppingBagScreenState extends State<ShoppingBagScreen> {
    final ScrollController _scrollController = ScrollController();
    late ShippingBloc _shippingBloc;
    List<dynamic> cartItems = [];
    String selectedStateName = '';
    String selectedStateCode = '';
    List<Region> states = [];
    List<String> stateNames = [];


    /////
    String selectedCountryName = '';
    String selectedCountryId = '';

    // Add these for states/regions
    String selectedRegionName = '';
    String selectedRegionId = '';
    String selectedRegionCode = '';

    double currentShippingCost = 0.0;
    // String selectedShippingMethodName = '';
    // bool isShippingLoading = false;
    // bool isLoggedIn = false;

    String carrierCode = '';
    String methodCode = '';






    /////

    bool isLoading = true;
    bool isShippingLoading = false; // For shipping estimation
    bool isLoggedIn = false; // Assuming you manage this elsewhere
    List<Country> countries = [];
    // String selectedCountryName = '';
    // String selectedCountryId = ''; // To store the ID like "IN", "US"
    // String selectedRegionName = ''; // Not used for now, but keep if needed
    List<String> countryNames = [];
    double shippingPrice = 0.0;
    Map<String, double> methodPriceMap = {};
    // late String carrierCode;
    // late String methodCode;
    String selectedShippingMethodName = '';

    // List<String> regionNames = []; // Not used for now

    List<ShippingMethod> availableShippingMethods = [];
    ShippingMethod? selectedShippingMethod;
    // double currentShippingCost = 0.0;
    bool _isDioInitialized = false;


    //
    // List<Map<String, dynamic>> cartItems = [];

    late Dio dio;
    late PersistCookieJar persistentCookieJar;

    // final CookieJar cookieJar = CookieJar();

    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

    void _saveShippingPreferences() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_country_name', selectedCountryName);
      await prefs.setString('selected_country_id', selectedCountryId);
      await prefs.setDouble('shipping_price', currentShippingCost);
      await prefs.setString('shipping_method_name', selectedShippingMethodName);
      await prefs.setString('selected_region_name', selectedRegionName);
      await prefs.setString('selected_region_id', selectedRegionId);
    }


    @override
    void initState() {
      super.initState();
      Future.microtask(() {
        context.read<CartBloc>().add(FetchCartItems());
      });
      context.read<ShippingBloc>().add(FetchCountries());

      // fetchCountries().then((list) {
      //   setState(() {
      //     countries = list;
      //     countryNames = countries.map((c) => c.fullNameLocale).toList();
      //
      //     if (countries.isNotEmpty) {
      //       selectedCountryName = countries[0].fullNameLocale;
      //       // Removed region update call here
      //     }
      //   });
      // });

      fetchInitialData();

      _initializeAsyncDependencies();
      _loadShippingPreferences();
      // dio = Dio();
      // dio.interceptors.add(CookieManager(cookieJar));
      // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      //   client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      //   return client;
      // };

      // fetchCartItems();
    }

    Future<void> _initializeAsyncDependencies() async {
      if (_isDioInitialized) return; // Prevent re-initialization

      // Initialize PersistentCookieJar
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      persistentCookieJar = PersistCookieJar(
        ignoreExpires: true,
        storage: FileStorage(
            appDocPath + "/.cookies/"), // Path for storing cookies
      );

      // Initialize Dio
      dio = Dio(BaseOptions(baseUrl: 'https://stage.aashniandco.com/rest'));
      dio.interceptors.add(
          CookieManager(persistentCookieJar)); // Use the persistent jar

      // Add Logging Interceptor (as shown in point 1)
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          /* ... */ return handler.next(options);
        },
        onResponse: (response, handler) {
          /* ... */ return handler.next(response);
        },
        onError: (DioError e, handler) {
          /* ... */ return handler.next(e);
        },
      ));

      // Add 401 Handling Interceptor (as shown in point 2)
      dio.interceptors.add(InterceptorsWrapper(
        onError: (DioError e, handler) {
          if (e.response?.statusCode == 401) {
            if (e.requestOptions.path.contains('/mine/')) {
              print("Unauthorized (401) from interceptor for ${e.requestOptions
                  .path}.");
              if (mounted) {
                setState(() {
                  isLoggedIn = false;
                });
                // Clear other session-specific data
              }
              // Persist the logged-out state
              SharedPreferences.getInstance().then((prefs) =>
                  prefs.setBool('isUserLoggedIn', false));
              // TODO: Navigate to login
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Session expired. Please log in again.")),
                );
              }
            }
          }
          return handler.next(e);
        },
      ));

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      _isDioInitialized = true; // Mark as initialized

      // Load login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool wasLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;

      if (mounted) {
        setState(() {
          isLoggedIn = wasLoggedIn;
        });
      }

      print("Initial isLoggedIn state: $isLoggedIn");

      // Now fetch data
      fetchInitialData();
    }


    Future<List<Country>> fetchCountries() async {
      final url = 'https://stage.aashniandco.com/rest/V1/directory/countries';

      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      try {
        final response = await ioClient.get(Uri.parse(url));

        print('Status Code: ${response.statusCode}');
        print('Headers: ${response.headers}');
        print('Raw response body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);

          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('countries')) {
            return (decoded['countries'] as List)
                .map((json) => Country.fromJson(json))
                .toList();
          } else {
            // If API returns just a List instead of Map, handle this
            return (decoded as List)
                .map((json) => Country.fromJson(json))
                .toList();
          }
        }
        return [];
      } catch (e) {
        print('Error fetching countries: $e');
        return [];
      }
    }

    Future<void> fetchInitialData() async {
      setState(() => isLoading = true);
      await fetchCountries().then((list) {
        if (mounted) {
          setState(() {
            countries = list;
            countryNames = countries.map((c) => c.fullNameLocale).toList();

            if (selectedCountryName.isEmpty && countries.isNotEmpty) {
              selectedCountryName = countries[0].fullNameLocale;
              selectedCountryId = countries[0].id;
            }
          });
          // setState(() {
          //   countries = list;
          //   countryNames = countries.map((c) => c.fullNameLocale)
          //       .toSet()
          //       .toList(); // Use toSet() to remove duplicates if any, then toList()
          //   if (countries.isNotEmpty) {
          //     // Try to find a default country, e.g., India, or fallback to the first one
          //     Country initialCountry = countries.firstWhere((c) => c.id == 'IN',
          //         orElse: () => countries.first);
          //     selectedCountryName = initialCountry.fullNameLocale;
          //     selectedCountryId = initialCountry.id;
          //     // Automatically fetch shipping for the default selected country if cart ID is available
          //     // if (_guestCartId != null && selectedCountryId.isNotEmpty) {
          //     //   _estimateShipping(); // Call this after cart items are loaded and _guestCartId is set
          //     // }
          //   }
          // });
        }
      });
      // await fetchCartItems(); // This should populate _guestCartId
      setState(() => isLoading = false);
    }

    Future<void> _estimateShipping() async {
      setState(() {
        isShippingLoading = true;
      });

      final countryId = selectedCountryId; // e.g., "IN", "US"
      final regionId = 0; // Always 0
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('user_token');

      if (customerToken == null || customerToken.isEmpty) {
        setState(() {
          isLoggedIn = false;
          isShippingLoading = false;
        });
        return;
      }

      isLoggedIn = true;

      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final shippingUrl =
          "https://stage.aashniandco.com/rest/V1/aashni/shipping-rate/$countryId/$regionId";
      print("shippingUrl$shippingUrl");
      try {
        final response = await ioClient.get(
          Uri.parse(shippingUrl),
          headers: {
            'Authorization': 'Bearer $customerToken',
            'Content-Type': 'application/json',
          },
        );

        final data = jsonDecode(response.body);

        print("data>>$data");
        if (response.statusCode == 200 && data is List && data.length >= 2 &&
            data[0] == true) {
          final price = data[1];
          if (price != null) {
            setState(() {
              shippingPrice = price.toDouble();
              currentShippingCost = shippingPrice;

              if (availableShippingMethods.isNotEmpty) {
                selectedShippingMethod = availableShippingMethods.first;
              } else {
                selectedShippingMethod = null;
              }
            });
          }
        } else {
          print('Failed to get shipping rate: ${response.body}');
        }
      } catch (e) {
        print('Error estimating shipping: $e');
      } finally {
        setState(() {
          isShippingLoading = false;
          _saveShippingPreferences();
        });
      }
    }

    Future<void> _loadShippingPreferences() async {
      final prefs = await SharedPreferences.getInstance();
      final savedCountryName = prefs.getString('selected_country_name') ?? '';
      final savedCountryId = prefs.getString('selected_country_id') ?? '';
      final savedShippingPrice = prefs.getDouble('shipping_price') ?? 0.0;
      final savedShippingMethod = prefs.getString('shipping_method_name') ?? '';
      final savedRegionName = prefs.getString('selected_region_name') ?? '';
      final savedRegionId = prefs.getString('selected_region_id') ?? '';

      if (savedCountryName.isNotEmpty && savedCountryId.isNotEmpty && savedRegionName.isNotEmpty && savedRegionName.isNotEmpty) {
        setState(() {
          selectedCountryName = savedCountryName;
          selectedCountryId = savedCountryId;
          currentShippingCost = savedShippingPrice;
          selectedShippingMethodName = savedShippingMethod;
          selectedRegionName = savedRegionName;
          selectedRegionId = savedRegionId;

        });
      }
    }

    // Future<void> fetchCartItems() async {
    //   final prefs = await SharedPreferences.getInstance();
    //   final customerToken = prefs.getString('user_token');
    //
    //   if (customerToken == null || customerToken.isEmpty) {
    //     setState(() {
    //       isLoggedIn = false;
    //       isLoading = false;
    //     });
    //     return;
    //   }
    //
    //   isLoggedIn = true;
    //
    //   HttpClient httpClient = HttpClient();
    //   httpClient.badCertificateCallback = (cert, host, port) => true;
    //   IOClient ioClient = IOClient(httpClient);
    //
    //   final response = await ioClient.get(
    //     Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/items'),
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'Authorization': 'Bearer $customerToken',
    //     },
    //   );
    //
    //   if (response.statusCode == 200) {
    //     final List<dynamic> items = json.decode(response.body);
    //     setState(() {
    //       cartItems = items;
    //       if (cartItems.isNotEmpty) {
    //         print(cartItems.runtimeType); // List<dynamic>
    //         print(cartItems[0].runtimeType); // Map<String, dynamic>
    //         print(cartItems[0]['item_id']);
    //       } else {
    //         print("Cart items list is empty.");
    //       }
    //       isLoading = false;
    //     });
    //   } else {
    //     print("Error fetching cart items: ${response.body}");
    //     setState(() {
    //       isLoading = false;
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Failed to load cart items')),
    //     );
    //   }
    // }


    // Future<bool> deleteCartItemFromMagento(BuildContext context, int itemId) async {
    //   final prefs = await SharedPreferences.getInstance();
    //   final customerToken = prefs.getString('user_token');
    //
    //   if (customerToken == null || customerToken.isEmpty) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('User not logged in.')),
    //     );
    //     return false;
    //   }
    //
    //   try {
    //     final response = await dio.post(
    //       'https://stage.aashniandco.com/rest/V1/solr/cart/item/delete',
    //       data: jsonEncode({'item_id': itemId}), // 👈 Force JSON encoding here
    //       options: Options(
    //         headers: {
    //           'Authorization': 'Bearer $customerToken',
    //           'Content-Type': 'application/json', // 👈 Must be JSON
    //         },
    //       ),
    //     );
    //
    //     print("Delete response: ${response.data}");
    //
    //     if (response.statusCode == 200 && response.data is Map && response.data['success'] == true) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text(response.data['message'] ?? 'Item removed')),
    //       );
    //       return true;
    //     } else {
    //       if (response.data is List) {
    //         final List res = response.data;
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text(res.length > 1 ? res[1].toString() : 'Deletion failed')),
    //         );
    //       } else {
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text('Unexpected response from server')),
    //         );
    //       }
    //       return false;
    //     }
    //   } catch (e) {
    //     print("Error deleting item: $e");
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Error: $e')),
    //     );
    //     return false;
    //   }
    // }

    // ✅ This is the missing method


    // Future<void> removeItem(BuildContext context, dynamic itemId) async {
    //   final prefs = await SharedPreferences.getInstance();
    //   final customerToken = prefs.getString('user_token');
    //
    //   if (itemId == null || itemId
    //       .toString()
    //       .isEmpty) {
    //     print('Error: itemId is null or empty');
    //     return;
    //   }
    //
    //   HttpClient httpClient = HttpClient();
    //   httpClient.badCertificateCallback = (cert, host, port) => true;
    //   IOClient ioClient = IOClient(httpClient);
    //
    //   // Build URL with query parameter
    //   final url = Uri.parse(
    //     'https://stage.aashniandco.com/rest/V1/solr/cart/item/delete?item_id=$itemId',
    //   );
    //
    //   try {
    //     final response = await ioClient.post(
    //       url,
    //       headers: {
    //         'Authorization': 'Bearer $customerToken',
    //         // No need to send Content-Type if no body
    //       },
    //     );
    //
    //     print('Response status: ${response.statusCode}');
    //     print('Response body: ${response.body}');
    //
    //     final resData = jsonDecode(response.body);
    //
    //     if (resData is List && resData.isNotEmpty && resData[0] == true) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Item deleted successfully')),
    //       );
    //       setState(() {
    //         cartItems.removeWhere((element) =>
    //         element is Map &&
    //             element['item_id'].toString() == itemId.toString());
    //       });
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('Failed to delete item: ${resData[1]}')),
    //       );
    //     }
    //   } catch (e) {
    //     print('Error deleting item: $e');
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Something went wrong')),
    //     );
    //   }
    // }


    // Future<void> deleteCartItemFromMagento(BuildContext context, int itemId) async {
    //   final prefs = await SharedPreferences.getInstance();
    //   final customerToken = prefs.getString('user_token');
    //
    //   print("token @delete >> $customerToken");
    //
    //   if (customerToken == null || customerToken.isEmpty) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('User not logged in.')),
    //     );
    //     return;
    //   }
    //
    //   try {
    //     final response = await dio.delete(
    //       'https://stage.aashniandco.com/rest/V1/carts/mine/items/$itemId',
    //       options: Options(
    //         headers: {
    //           'Authorization': 'Bearer $customerToken',
    //           'Content-Type': 'application/json',
    //         },
    //       ),
    //     );
    //
    //     if (response.statusCode == 200 || response.statusCode == 204) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Item removed successfully.')),
    //       );
    //     } else {
    //       print('Delete failed: ${response.statusCode} ${response.data}');
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('Failed to delete item: ${response.statusCode}')),
    //       );
    //     }
    //   } on DioError catch (e) {
    //     print('Dio error occurred: ${e.response?.statusCode} ${e.response?.data}');
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Error occurred: ${e.response?.statusCode ?? ''}')),
    //     );
    //   } catch (e) {
    //     print('Exception occurred: $e');
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Unexpected error: $e')),
    //     );
    //   }
    // }
    //
    // void removeItem(BuildContext context, Map<String, dynamic> item) async {
    //   final int? itemId = item['item_id'];
    //   if (itemId == null) return;
    //
    //   await deleteCartItemFromMagento(context, itemId);
    //
    //   setState(() {
    //     cartItems.removeWhere((element) => element['item_id'] == itemId);
    //   });
    // }


    Future<int?> updateCartItemQty(int itemId, int qty) async {
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('user_token');

      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      // Build URL with query parameters
      final uri = Uri.parse(
        "https://stage.aashniandco.com/rest/V1/solr/cart/item/updateQty?item_id=$itemId&qty=$qty",
      );

      final response = await ioClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer $customerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data is List && data.isNotEmpty && data[0] == true) {
            // Try to get updated qty from index 2
            if (data.length > 2 && data[2] is Map && data[2]['qty'] != null) {
              final updatedQty = data[2]['qty'];
              print("Updated qty: $updatedQty");
              return updatedQty is int ? updatedQty : int.tryParse(
                  updatedQty.toString());
            } else {
              print(
                  "Qty updated but not returned, fallback to requested qty: $qty");
              return qty;
            }
          } else {
            print("Failed to update qty: ${data[1]}");
            return null;
          }
        } catch (e) {
          print("Error parsing response: $e");
          return null;
        }
      } else {
        print("HTTP error: ${response.statusCode}");
        return null;
      }
    }


    void _onQtyChange(Map<String, dynamic> item, int delta) async {
      final int itemId = item['item_id'];
      int currentQty = 1;

      if (item['qty'] is int) {
        currentQty = item['qty'];
      } else if (item['qty'] is String) {
        currentQty = int.tryParse(item['qty']) ?? 1;
      }

      int newQty = currentQty + delta;
      if (newQty < 1) newQty = 1;

      int? updatedQty = await updateCartItemQty(itemId, newQty);

      if (updatedQty != null) {
        setState(() {
          final index = cartItems.indexWhere((e) =>
          e is Map<String, dynamic> && e['item_id'] == itemId);

          if (index != -1 && cartItems[index] is Map<String, dynamic>) {
            (cartItems[index] as Map<String, dynamic>)['qty'] = updatedQty;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quantity')),
        );
      }
    }


    // void updateQuantity(Map<String, dynamic> item, int delta) {
    //   final rawQty = item['qty'];
    //   int qty = 1;
    //   if (rawQty is int) {
    //     qty = rawQty;
    //   } else if (rawQty is String) {
    //     qty = int.tryParse(rawQty) ?? 1;
    //   }
    //   qty += delta;
    //   if (qty < 1) qty = 1;
    //
    //   setState(() {
    //     final index = cartItems.indexWhere((e) => e['item_id'] == item['item_id']);
    //     if (index != -1) {
    //       cartItems[index]['qty'] = qty;
    //     }
    //   });
    // }

    // void removeItem(Map item) {
    //   setState(() {
    //     cartItems.remove(item);
    //   });
    // }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Shopping Bag'),
            leading: IconButton(
              icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                      (Route<dynamic> route) => false,
                );

              },
            ),
          ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state is CartLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CartLoaded) {
                    final cartItems = state.items;
                    if (cartItems.isEmpty) {
                      return const Center(child: Text("Your cart is empty."));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return CartItemWidget(
                          key: ValueKey(item['item_id']),
                          item: item,
                          onAdd: () => context.read<CartBloc>().add(
                            UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) + 1),
                          ),
                          onRemove: () {
                            if ((item['qty'] ?? 1) > 1) {
                              context.read<CartBloc>().add(
                                UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) - 1),
                              );
                            }
                          },
                          onDelete: () => context.read<CartBloc>().add(RemoveCartItem(item['item_id'])),
                        );
                      },
                    );
                  } else if (state is CartError) {
                    return Center(child: Text("Error: ${state.message}"));
                  } else if (state is CartItemRemoved || state is CartItemUpdated) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            // Wrap bottom container inside BlocBuilder and Flexible to make height dynamic
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                if (cartState is CartLoaded && cartState.items.isNotEmpty) {
                  return Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Shipping estimate section
                            BlocBuilder<ShippingBloc, ShippingState>(
                              builder: (context, shippingState) {
                                List<Country> countries = [];
                                List<String> countryNames = [];

                                if (shippingState is CountriesLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (shippingState is ShippingError) {
                                  return Text('Error loading countries: ${shippingState.message}');
                                } else if (shippingState is CountriesLoaded) {
                                  countries = shippingState.countries;
                                  countryNames = countries.map((c) => c.fullNameEnglish).toList();

                                  if (selectedCountryName.isEmpty && countries.isNotEmpty) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      setState(() {
                                        selectedCountryName = countries.first.fullNameEnglish;
                                        selectedCountryId = countries.first.id;
                                      });
                                      _shippingBloc.add(EstimateShipping(selectedCountryId!));
                                    });
                                  }
                                }

                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Fixed header
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                        child: const Text(
                                          'Estimate Shipping',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      // Scrollable content below header
                                      SizedBox(
                                      height: 300, // increased to accommodate state dropdown
                                      child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                const Text(
                                'Enter your destination to get a shipping estimate.',
                                style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                                const SizedBox(height: 20),
                                buildDropdown(
                                label: 'Select Country',
                                value: selectedCountryName,
                                items: countryNames,
                                onChanged: (value) {
                                if (value != null && value != selectedCountryName) {
                                setState(() {
                                final selected = countries.firstWhere(
                                (c) => c.fullNameEnglish == value,
                                orElse: () => countries.first,
                                );
                                selectedCountryName = selected.fullNameEnglish;
                                selectedCountryId = selected.id;
                                selectedRegionName = '';
                                selectedRegionId = '';
                                currentShippingCost = 0.0;
                                selectedShippingMethodName = '';
                                });

                                if (isLoggedIn) {
                                _estimateShipping().then((_) {
                                if (currentShippingCost > 0) {
                                carrierCode = "tablerate"; // DHL
                                methodCode = "bestway";
                                selectedShippingMethodName = "DHL";
                                } else {
                                carrierCode = "freeshipping";
                                methodCode = "freeshipping";
                                selectedShippingMethodName = "Standard Shipping (Free)";
                                }
                                setState(() {});
                                });
                                } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                content: Text("Please log in to estimate shipping for this country."),
                                ),
                                );
                                }
                                }
                                },
                                ),

                                const SizedBox(height: 20),

                                // State Dropdown (only show if regions exist)
                                if (selectedCountryName.isNotEmpty &&
                                countries.firstWhere((c) => c.fullNameEnglish == selectedCountryName).regions.isNotEmpty)
                                buildDropdown(
                                label: 'Select State / Province',
                                value: selectedRegionName.isEmpty ? "" : selectedRegionName,
                                items: countries
                                    .firstWhere((c) => c.fullNameEnglish == selectedCountryName)
                                    .regions
                                    .map((r) => r.name)
                                    .toList(),
                                onChanged: (value) {
                                final region = countries
                                    .firstWhere((c) => c.fullNameEnglish == selectedCountryName)
                                    .regions
                                    .firstWhere((r) => r.name == value);

                                setState(() {
                                selectedRegionName = region.name;
                                selectedRegionId = region.id;
                                selectedRegionCode = region.code;
                                });

                                if (isLoggedIn) {
                                _estimateShipping().then((_) {
                                if (currentShippingCost > 0) {
                                carrierCode = "tablerate";
                                methodCode = "bestway";
                                selectedShippingMethodName = "DHL";
                                } else {
                                carrierCode = "freeshipping";
                                methodCode = "freeshipping";
                                selectedShippingMethodName = "Standard Shipping (Free)";
                                }
                                setState(() {});
                                });
                                }
                                },
                                ),

                                const SizedBox(height: 20),

                                // Loading / Result Display
                                if (isShippingLoading)
                                const Center(
                                child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: CircularProgressIndicator(),
                                ),
                                )
                                else if (!isShippingLoading && selectedShippingMethodName.isNotEmpty)
                                Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                currentShippingCost > 0
                                ? "$selectedShippingMethodName: ₹${currentShippingCost.toStringAsFixed(2)}"
                                    : selectedShippingMethodName,
                                style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                ),
                                ),
                                )
                                else if (!isShippingLoading && selectedCountryId.isNotEmpty)
                                Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                "No shipping methods available for $selectedCountryName.",
                                style: TextStyle(color: Colors.grey.shade700),
                                ),
                                )
                                else
                                Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                "Select a country to see shipping options.",
                                style: TextStyle(color: Colors.grey.shade700),
                                ),
                                ),
                                ],
                                ),
                                      ),
                                      )
                                      // SizedBox(
                                      //   height: 220, // Adjust height as needed
                                      //   child: SingleChildScrollView(
                                      //     padding: const EdgeInsets.all(16),
                                      //     child: Column(
                                      //       crossAxisAlignment: CrossAxisAlignment.start,
                                      //       children: [
                                      //         const Text(
                                      //           'Enter your destination to get a shipping estimate.',
                                      //           style: TextStyle(fontSize: 16, color: Colors.black87),
                                      //         ),
                                      //         const SizedBox(height: 20),
                                      //
                                      //         buildDropdown(
                                      //           label: 'Select Country',
                                      //           value: selectedCountryName,
                                      //           items: countryNames,
                                      //           onChanged: (value) {
                                      //             print("Dropdown changed: $value"); // Log when dropdown changes
                                      //
                                      //             if (value != null && value != selectedCountryName) {
                                      //               print("It's working!"); // Log when value is different
                                      //
                                      //               setState(() {
                                      //                 final selected = countries.firstWhere(
                                      //                       (c) => c.fullNameEnglish == value,
                                      //                   orElse: () => countries.first,
                                      //                 );
                                      //
                                      //                 selectedCountryName = selected.fullNameEnglish;
                                      //                 selectedCountryId = selected.id;
                                      //                 currentShippingCost = 0.0;
                                      //                 selectedShippingMethodName = "";
                                      //               });
                                      //
                                      //
                                      //               if (isLoggedIn) {
                                      //                 _estimateShipping().then((_) {
                                      //                   if (currentShippingCost > 0) {
                                      //                     carrierCode = "tablerate";  // DHL
                                      //                     methodCode = "bestway";
                                      //                     selectedShippingMethodName = "DHL";
                                      //                     print("Shipping Method: $selectedShippingMethodName");
                                      //                   } else {
                                      //                     carrierCode = "freeshipping";
                                      //                     methodCode = "freeshipping";
                                      //                     selectedShippingMethodName = "Standard Shipping (Free)";
                                      //                     print("Shipping Method: $selectedShippingMethodName");
                                      //                   }
                                      //
                                      //                   setState(() {}); // Rebuild UI to reflect shipping method name
                                      //                 });
                                      //               } else {
                                      //                 ScaffoldMessenger.of(context).showSnackBar(
                                      //                   const SnackBar(
                                      //                     content: Text("Please log in to estimate shipping for this country."),
                                      //                   ),
                                      //                 );
                                      //               }
                                      //             }
                                      //           },
                                      //         ),
                                      //
                                      //         const SizedBox(height: 20),
                                      //
                                      //         if (isShippingLoading)
                                      //           const Center(
                                      //             child: Padding(
                                      //               padding: EdgeInsets.symmetric(vertical: 16.0),
                                      //               child: CircularProgressIndicator(),
                                      //             ),
                                      //           )
                                      //         else if (!isShippingLoading && selectedShippingMethodName.isNotEmpty)
                                      //           Padding(
                                      //             padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      //             child: Text(
                                      //               currentShippingCost > 0
                                      //                   ? "$selectedShippingMethodName: ₹${currentShippingCost.toStringAsFixed(2)}"
                                      //                   : selectedShippingMethodName,
                                      //               style: const TextStyle(
                                      //                 fontSize: 16,
                                      //                 fontWeight: FontWeight.w500,
                                      //                 color: Colors.black87,
                                      //               ),
                                      //             ),
                                      //           )
                                      //         else if (!isShippingLoading && selectedCountryId.isNotEmpty)
                                      //             Padding(
                                      //               padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      //               child: Text(
                                      //                 "No shipping methods available for $selectedCountryName.",
                                      //                 style: TextStyle(color: Colors.grey.shade700),
                                      //               ),
                                      //             )
                                      //           else if (!isShippingLoading && selectedCountryId.isEmpty)
                                      //               Padding(
                                      //                 padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      //                 child: Text(
                                      //                   "Select a country to see shipping options.",
                                      //                   style: TextStyle(color: Colors.grey.shade700),
                                      //                 ),
                                      //               ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // )
                                      ,
                                    ],
                                  ),
                                );

                              },
                            ),

                            const SizedBox(height: 20),

                            // Order Summary Section
                            BlocBuilder<CartBloc, CartState>(
                              builder: (context, cartState) {
                                if (cartState is CartLoaded) {
                                  final cartItems = cartState.items;

                                  double subtotal = 0.0;
                                  for (var item in cartItems) {
                                    final qty = item['qty'] ?? 1;
                                    final price = double.tryParse(item['price'].toString()) ?? 0.0;
                                    subtotal += price * qty;
                                  }
                                  final total = subtotal + currentShippingCost;

                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Subtotal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                            Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Duties and Taxes', style: TextStyle(fontSize: 16, color: Colors.black87)),
                                            Text('Incl.', style: TextStyle(fontSize: 16, color: Colors.black87)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Shipping (Shipping - DHL)', style: TextStyle(fontSize: 16)),
                                            Text("₹${currentShippingCost.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        const Divider(thickness: 1),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),

                            const SizedBox(height: 20),

                            // Coupon code section
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Enter coupon code',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    // handle coupon apply
                                  },
                                  child: const Text("Apply"),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Checkout button
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CheckoutScreen()),

                                  );

                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                ),
                                child: const Text(
                                  "PROCEED TO CHECKOUT",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      );
    }



    Widget buildDropdown({
      required String label,
      required String value,
      required List<String> items,
      required ValueChanged<String?> onChanged,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: value.isNotEmpty ? value : null,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      );
    }


// class ShoppingBagScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Shopping Bag"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "SIGN IN TO YOUR ACCOUNT TO ENABLE SYNC",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Add functionality for Sign In
//                 print("Sign In clicked");
//
//                 Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountScreen()));
//               },
//               child: Text("Sign In"),
//             ),
//             SizedBox(height: 10),
//             // TextButton(
//             //   onPressed: () {
//             //     // Add functionality for checking out new items
//             //     print("Check out New In clicked");
//             //   },
//             //   child: Text("Or check out New In"),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
  }
