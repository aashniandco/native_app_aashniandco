import 'package:aashni_app/features/auth/view/auth_screen.dart';
import 'package:aashni_app/features/auth/view/login_screen.dart'; // Correct, single import for LoginScreen
import 'package:aashni_app/features/checkout/checkout_screen.dart';
import 'package:aashni_app/features/login/view/login_screen.dart';
import 'package:aashni_app/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter/material.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import ' shipping_bloc/shipping_bloc.dart';
import ' shipping_bloc/shipping_event.dart';
import ' shipping_bloc/shipping_state.dart';
import '../../constants/user_preferences_helper.dart';
// import '../login/view/login_screen.dart'; // Removed duplicate/conflicting import
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
  // State variables
  bool isLoading = true;
  bool isLoggedIn = false; // The most important state for this feature

  final ScrollController _scrollController = ScrollController();
  late ShippingBloc _shippingBloc;

  // Cart & Weight
  List<dynamic> cartItems = [];
  double _cartTotalWeight = 0.0;
  int customer_id = 0;

  // Shipping & Location
  String selectedCountryName = '';
  String selectedCountryId = '';
  String selectedRegionName = '';
  String selectedRegionId = '';
  String selectedRegionCode = '';

  List<Country> countries = [];
  List<String> countryNames = [];

  // Shipping Methods & Cost
  bool isShippingLoading = false;
  double currentShippingCost = 0.0;
  List<ShippingMethod> availableShippingMethods = [];
  ShippingMethod? selectedShippingMethod;
  String selectedShippingMethodName = '';

  // Dio & Cookies
  late Dio dio;
  late PersistCookieJar persistentCookieJar;
  bool _isDioInitialized = false;

  @override
  void initState() {
    super.initState();
    // This is the main entry point to set up the screen.
    _initializeScreen();
  }

  /// This is the new orchestrating function.
  /// It checks login status first, then conditionally loads data.
  Future<void> _initializeScreen() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    await _checkLoginStatus();

    // If the user is not logged in, we stop here. The build() method will show the login prompt.
    if (!isLoggedIn) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // --- Proceed with data fetching ONLY IF LOGGED IN ---
    _shippingBloc = context.read<ShippingBloc>();
    context.read<CartBloc>().add(FetchCartItems());
    _shippingBloc.add(FetchCountries());

    await _loadShippingPreferences();
    await _loadCustomerIdAndFetchWeight();
    await _initializeAsyncDependencies();

    setState(() {
      isLoading = false;
    });
  }

  /// Checks SharedPreferences to set the initial `isLoggedIn` state.
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
    });
  }

  // All your other existing methods remain here, unchanged.
  // ... (dispose, _getShippingOptions, _loadCustomerIdAndFetchWeight, etc.) ...
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  void _getShippingOptions() {
    if (!isLoggedIn || selectedCountryId.isEmpty) {
      setState(() {
        isShippingLoading = false;
        availableShippingMethods = [];
        selectedShippingMethod = null;
        currentShippingCost = 0.0;
      });
      return;
    }

    setState(() {
      isShippingLoading = true;
      availableShippingMethods = [];
      selectedShippingMethod = null;
      currentShippingCost = 0.0;
    });

    context.read<ShippingBloc>().add(
      FetchShippingMethods(
        countryId: selectedCountryId,
        regionId: selectedRegionId,
      ),
    );
  }


  Future<void> _loadCustomerIdAndFetchWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final cust_id = prefs.getInt('user_customer_id');
    print("Stored customer_id>>>: $cust_id");

    if (cust_id != null) {
      double weight = await fetchCartTotalWeight(cust_id);
      print("Cart total weight: $weight");

      if (!mounted) return;
      setState(() {
        _cartTotalWeight = weight;
      });
      _getShippingOptions();

    } else {
      print("Customer ID not found in SharedPreferences");
      if (!mounted) return;
      setState(() {
        _cartTotalWeight = 0.0;
      });
      _getShippingOptions();
    }
  }

  Future<double> fetchCartTotalWeight(int customerId) async {
    print("shop >> fetchCartTotalWeightcalled>>");

    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.get(
      Uri.parse('https://stage.aashniandco.com/rest/V1/cart/details/$customerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      if (data.isEmpty) {
        return 0.0;
      }
      final firstItem = data[0] as Map<String, dynamic>;
      final weightStr = firstItem['total_cart_weight'];
      final totalWeight = double.tryParse(weightStr.toString()) ?? 0.0;
      print("init fetchCartTotalWeightcalled>>$totalWeight");
      return totalWeight;
    } else {
      // It's possible the empty cart error comes from here too.
      // We will handle the interpretation of this error in the UI layer.
      throw Exception("Failed to fetch cart total weight: ${response.body}");
    }
  }

  void _saveShippingPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_country_name', selectedCountryName);
    await prefs.setString('selected_country_id', selectedCountryId);
    await prefs.setString('selected_region_name', selectedRegionName);
    await prefs.setString('selected_region_id', selectedRegionId);

    if (selectedShippingMethod != null) {
      await prefs.setDouble('shipping_price', selectedShippingMethod!.amount);
      await prefs.setString('shipping_method_name', selectedShippingMethod!.displayName);
      await prefs.setString('carrier_code', selectedShippingMethod!.carrierCode);
      await prefs.setString('method_code', selectedShippingMethod!.methodCode);
    } else {
      await prefs.remove('shipping_price');
      await prefs.remove('shipping_method_name');
      await prefs.remove('carrier_code');
      await prefs.remove('method_code');
    }
    print("✅ Preferences Saved: Country='${selectedCountryName}', Region='${selectedRegionName}'");
  }


  Future<void> _initializeAsyncDependencies() async {
    if (_isDioInitialized) return;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    persistentCookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(
          appDocPath + "/.cookies/"),
    );


    dio = Dio(BaseOptions(baseUrl: 'https://stage.aashniandco.com/rest'));
    dio.interceptors.add(
        CookieManager(persistentCookieJar));

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };


    _isDioInitialized = true;
  }

  Future<void> _loadShippingPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCountryName = prefs.getString('selected_country_name');
    final savedCountryId = prefs.getString('selected_country_id');
    final savedRegionName = prefs.getString('selected_region_name');
    final savedRegionId = prefs.getString('selected_region_id');

    if (savedCountryName != null && savedCountryId != null) {
      print("✅ Preferences Loaded: Country='${savedCountryName}', Region='${savedRegionName ?? ''}'");

      setState(() {
        selectedCountryName = savedCountryName;
        selectedCountryId = savedCountryId;
        selectedRegionName = savedRegionName ?? '';
        selectedRegionId = savedRegionId ?? '';
      });

      _getShippingOptions();
    }
  }

  /// This is the new widget to display when the user is not logged in.
  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Bag'),
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                "Please Login to your Account",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Sign in to view your items, get shipping estimates, and proceed to checkout.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the login screen. When the user returns,
                  // we re-run the initialization logic to check their status.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen1()),
                  ).then((_) {
                    _initializeScreen();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Sign In / Create Account",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If the screen is still performing the initial login check, show a loader.
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shopping Bag')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If NOT logged in, show the login prompt.
    if (!isLoggedIn) {
      return _buildLoginPrompt(context);
    }

    // --- If we reach here, the user IS logged in. Build the full shopping bag UI. ---
    return BlocListener<ShippingBloc, ShippingState>(
      listener: (context, state) {
        if (state is ShippingMethodsLoaded) {
          setState(() {
            isShippingLoading = false;
            availableShippingMethods = state.methods;
            if (state.methods.isNotEmpty) {
              selectedShippingMethod = state.methods.first;
              currentShippingCost = selectedShippingMethod!.amount;
            } else {
              selectedShippingMethod = null;
              currentShippingCost = 0.0;
            }
          });
          _saveShippingPreferences();
        } else if (state is ShippingError) {
          setState(() {
            isShippingLoading = false;
            availableShippingMethods = [];
            selectedShippingMethod = null;
            currentShippingCost = 0.0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shopping Bag'),
          leading: IconButton(
            icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AuthScreen()), (r) => false),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state is CartLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  else if (state is CartLoaded) {
                    // This case handles a successful fetch, even if the list is empty.
                    if (state.items.isEmpty) {
                      return const Center(
                        child: Text(
                          "No Items in the cart",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _cartTotalWeight != state.totalCartWeight) {
                        setState(() => _cartTotalWeight = state.totalCartWeight);
                        _getShippingOptions();
                      }
                    });

                    return ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return CartItemWidget(
                          key: ValueKey(item['item_id']),
                          item: item,
                          onAdd: () => context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) + 1)),
                          onRemove: () {
                            if ((item['qty'] ?? 1) > 1) {
                              context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) - 1));
                            }
                          },
                          onDelete: () => context.read<CartBloc>().add(RemoveCartItem(item['item_id'])),
                        );
                      },
                    );
                  }
                  // ✅ ---- THIS IS THE KEY CHANGE ---- ✅
                  else if (state is CartError) {
                    // Check if the error message from the API indicates an empty cart.
                    // This is a common scenario for some backend implementations.
                    final errorMessage = state.message.toLowerCase();
                    if (errorMessage.contains("no such entity with cartid")) {
                      return const Center(
                        child: Text(
                          "No Items in the cart",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }
                    // If it's a different, genuine error, display it to the user.
                    // return Center(child: Text("Error: ${state.message}"));
                    return Center(child: Text(
                      "No Items in the cart",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ));
                  }
                  // Default State: A fallback view while the BLoC is initializing.
                  return const Center(child: Text("Welcome! Your cart is loading."));
                },
              ),
            ),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                // We only show the bottom container if the cart is successfully loaded AND has items.
                if (cartState is CartLoaded && cartState.items.isNotEmpty) {
                  return Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade100, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildShippingContainer(),
                            const SizedBox(height: 20),
                            _buildOrderSummary(cartState),
                            const SizedBox(height: 20),
                            _buildCouponSection(),
                            const SizedBox(height: 20),
                            _buildCheckoutButton(),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                // If cart is empty or in an error state, don't show the summary.
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingMethodsList() {
    if (isShippingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isLoggedIn) {
      return const Text("Please log in to see shipping options.");
    }

    if (availableShippingMethods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text("No shipping methods available for this address."),
      );
    }

    return Column(
      children: availableShippingMethods.map((method) {
        return RadioListTile<ShippingMethod>(
          title: Text(method.displayName),
          subtitle: Text('₹${method.amount.toStringAsFixed(2)}'),
          value: method,
          groupValue: selectedShippingMethod,
          onChanged: (ShippingMethod? value) {
            setState(() {
              selectedShippingMethod = value;
              currentShippingCost = value?.amount ?? 0.0;
            });
            _saveShippingPreferences();
          },
        );
      }).toList(),
    );
  }

  Widget _buildShippingContainer() {
    return BlocBuilder<ShippingBloc, ShippingState>(
      buildWhen: (previous, current) => current is CountriesLoaded || current is ShippingInitial,
      builder: (context, shippingState) {

        final List<Country> countries = (shippingState is CountriesLoaded) ? shippingState.countries : [];
        final List<String> countryNames = countries.map((c) => c.fullNameEnglish).toList();

        Country? selectedCountryData;
        if (selectedCountryName.isNotEmpty) {
          try {
            selectedCountryData = countries.firstWhere((c) => c.fullNameEnglish == selectedCountryName);
          } catch (e) {
            selectedCountryData = null;
          }
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                child: const Text('Estimate Shipping', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildDropdown(
                      label: 'Select Country',
                      value: selectedCountryName.isEmpty ? null : selectedCountryName,
                      items: countryNames,
                      onChanged: (value) {
                        if (value != null) {
                          final Country country = countries.firstWhere((c) => c.fullNameEnglish == value);
                          setState(() {
                            selectedCountryName = country.fullNameEnglish;
                            selectedCountryId = country.id;
                            selectedRegionName = '';
                            selectedRegionId = '';
                            selectedShippingMethod = null;
                            availableShippingMethods = [];
                            currentShippingCost = 0.0;
                          });
                          _getShippingOptions();
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    if (selectedCountryData != null && selectedCountryData.regions.isNotEmpty)
                      buildDropdown(
                        label: 'Select State / Province',
                        value: selectedRegionName.isEmpty ? null : selectedRegionName,
                        items: selectedCountryData.regions.map((r) => r.name).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final Region region = selectedCountryData!.regions.firstWhere((r) => r.name == value);
                            setState(() {
                              selectedRegionName = region.name;
                              selectedRegionId = region.id;
                              selectedShippingMethod = null;
                              availableShippingMethods = [];
                              currentShippingCost = 0.0;
                            });
                            _getShippingOptions();
                          }
                        },
                      ),
                    const SizedBox(height: 20),
                    _buildShippingMethodsList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(CartLoaded cartState) {
    double subtotal = 0.0;
    for (var item in cartState.items) {
      subtotal += (item['qty'] ?? 1) * (double.tryParse(item['price'].toString()) ?? 0.0);
    }
    final total = subtotal + currentShippingCost;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Subtotal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Shipping (${selectedShippingMethod?.displayName ?? "Not Selected"})', style: const TextStyle(fontSize: 16)),
            Text("₹${currentShippingCost.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
          ]),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(hintText: 'Enter coupon code', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(onPressed: () {}, child: const Text("Apply")),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _saveShippingPreferences();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ShippingBloc>(),
                child: CheckoutScreen(),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        child: const Text("PROCEED TO CHECKOUT", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
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
            value: value,
            hint: const Text('Please select an option'),
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
            isExpanded: true,
          ),
        ),
      ],
    );
  }
}