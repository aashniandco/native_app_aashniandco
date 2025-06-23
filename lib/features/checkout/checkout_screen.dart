import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:aashni_app/features/shoppingbag/shopping_bag.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/io_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Payment/view/payment_screen.dart';
import '../shoppingbag/ shipping_bloc/shipping_bloc.dart';
import '../shoppingbag/ shipping_bloc/shipping_event.dart';
import '../shoppingbag/ shipping_bloc/shipping_state.dart';
import '../shoppingbag/cart_bloc/cart_bloc.dart';
import '../shoppingbag/cart_bloc/cart_event.dart';
import '../shoppingbag/model/countries.dart';
import '../shoppingbag/repository/cart_repository.dart';



class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late ShippingBloc _shippingBloc;

  Country? _selectedApiCountryObject;
  String? _selectedCountry;
  List<Country> _apiCountries = [];
  bool _areCountriesLoading = true;
  bool _initialCountryLoadAttempted = false;
  String? _countriesError;
  int customerId=0;
  String selectedRegionCode= '';
  bool _isSubmitting = false;
  String? _selectedShippingMethodId;

  double _subTotal = 0.0;

  String? _selectedState;
  List<String> _currentStates = [];

  String selectedCountryName = '';
  String selectedCountryId = '';
  String selectedRegionName = '';
  String selectedRegionId = '';
  double _cartTotalWeight = 0.0;

  bool isUserLoggedIn = false;
  double _grandTotal = 0.0;
  int _itemsQty = 0;

  String selectedShippingMethodName = '';
  double currentShippingCost = 0.0;
  String carrierCode = '';
  String methodCode = '';
  bool _isFetchingShippingMethods = false;


  // This will be our live list for UI and updates
  List<Map<String, dynamic>> _displayableShippingMethods = [];

  final CartRepository _cartRepository = CartRepository();
  List<Map<String, dynamic>> _fetchedCartItems = [];
  List<Map<String, dynamic>> _fetchTotals = [];
  bool _isCartLoading = false;
  String? _cartError;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoadingShippingPrefs = true;

  bool get _isPageLoading => _isLoadingShippingPrefs || (_areCountriesLoading && !_initialCountryLoadAttempted);


  // The new shipping method fetcher.
  Future<List<ShippingMethod>> fetchAvailableShippingMethods({
    required String countryId,
    required String regionId,
    required String postcode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }

    final url = Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods');

    final payload = {
      "address": {
        "country_id": countryId,
        "region_id": int.tryParse(regionId) ?? 0, // Handles empty regionId
        "postcode": postcode.isNotEmpty ? postcode : "00000", // Use a placeholder if empty
        "city": _cityController.text.isNotEmpty ? _cityController.text : "Placeholder",
        "street": [_streetAddressController.text.isNotEmpty ? _streetAddressController.text : "Placeholder"],
        "firstname": _firstNameController.text.isNotEmpty ? _firstNameController.text : "Guest",
        "lastname": _lastNameController.text.isNotEmpty ? _lastNameController.text : "User",
        "telephone": _phoneController.text.isNotEmpty ? _phoneController.text : "9999999999",
      }
    };

    HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
      body: json.encode(payload),
    );

    if (kDebugMode) {
      print("Shipping Estimation Payload: ${json.encode(payload)}");
      print("Standard Shipping API Response: ${response.body}");
    }


    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => ShippingMethod.fromJson(data)).toList();
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
    }
  }


  // ✅ MODIFIED: Central function to trigger shipping updates. Now only requires a country.
  Future<void> _triggerShippingMethodUpdate() async {
    // 1. Validate that we have at least a country.
    if (selectedCountryId.isEmpty) {
      if (kDebugMode) {
        print("Skipping shipping fetch: Country is missing.");
      }
      return;
    }

    // 2. Show a loading indicator in the UI.
    if(!mounted) return;
    setState(() {
      _isFetchingShippingMethods = true;
    });

    try {
      // 3. Call the API fetcher function with available data. It will use placeholders for missing info.
      final List<ShippingMethod> fetchedMethods = await fetchAvailableShippingMethods(
        countryId: selectedCountryId,
        regionId: selectedRegionId,
        postcode: _zipController.text,
      );

      if(!mounted) return;

      if (fetchedMethods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No shipping methods available for this address.")),
        );
        setState(() {
          _displayableShippingMethods = [];
          _selectedShippingMethodId = null;
          _isFetchingShippingMethods = false;
        });
        return;
      }

      // 4. Transform the API response into the format your UI table expects.
      final newUiMethods = fetchedMethods.map((method) {
        return {
          'id': '${method.carrierCode}_${method.methodCode}', // A unique ID
          'price_str': '₹${method.amount.toStringAsFixed(2)}',
          'price_val': method.amount,
          'title': method.methodTitle,
          'carrier': method.carrierTitle,
          'carrier_code': method.carrierCode,
          'method_code': method.methodCode,
        };
      }).toList();

      // 5. Update the state to display the new methods.
      setState(() {
        _displayableShippingMethods = newUiMethods;

        if (_displayableShippingMethods.isNotEmpty) {
          final firstMethod = _displayableShippingMethods.first;
          _selectedShippingMethodId = firstMethod['id'] as String;
          currentShippingCost = firstMethod['price_val'] as double;
          selectedShippingMethodName = firstMethod['title'] as String;
          carrierCode = firstMethod['carrier_code'] as String;
          methodCode = firstMethod['method_code'] as String;
        } else {
          _selectedShippingMethodId = null;
        }
        _isFetchingShippingMethods = false;
      });

    } catch (e) {
      if(!mounted) return;
      if (kDebugMode) print("Error fetching shipping methods: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
      // 6. Handle errors by clearing the list and hiding the loader.
      setState(() {
        _displayableShippingMethods = [];
        _selectedShippingMethodId = null;
        _isFetchingShippingMethods = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _shippingBloc = ShippingBloc();
    _shippingBloc.add(FetchCountries());

    _loadLoginStatus();
    _fetchAndPrintCartItemsDirectly();
    _callAndProcessFetchTotal();
  }


  Future<void> _loadShippingPreferencesForCheckout() async {
    if (!mounted) return;
    setState(() {
      _isLoadingShippingPrefs = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? countryNameFromPrefs = prefs.getString('selected_country_name');
    final String? countryIdFromPrefs = prefs.getString('selected_country_id');
    final String? regionNameFromPrefs = prefs.getString('selected_region_name');
    final String? regionIdFromPrefs = prefs.getString('selected_region_id');
    final double? shippingPriceFromPrefs = prefs.getDouble('shipping_price');
    final String? shippingMethodNameFromPrefs = prefs.getString('method_name');
    final String? carrierCodeFromPrefs = prefs.getString('carrier_code');
    final String? methodCodeFromPrefs = prefs.getString('method_code');

    if (kDebugMode) {
      print("--- Loading Shipping Preferences (CheckoutScreen) ---");
      print("API Countries available: ${_apiCountries.length}, Prefs Country: $countryNameFromPrefs (ID: $countryIdFromPrefs), Prefs Region: $regionNameFromPrefs (ID: $regionIdFromPrefs)");
      print("Prefs Shipping: Method='$shippingMethodNameFromPrefs', Price='$shippingPriceFromPrefs'");
    }

    Country? resolvedApiCountry;

    if (countryNameFromPrefs != null && _apiCountries.isNotEmpty) {
      try {
        resolvedApiCountry = _apiCountries.firstWhere(
                (c) => c.fullNameEnglish == countryNameFromPrefs || (countryIdFromPrefs != null && c.id == countryIdFromPrefs)
        );
        if (kDebugMode) print("Found country from prefs in API list: ${resolvedApiCountry.fullNameEnglish}");
      } catch (e) {
        if (kDebugMode) print("Country from prefs ('$countryNameFromPrefs') not found in API list.");
        resolvedApiCountry = null;
      }
    }

    if (resolvedApiCountry == null && _selectedApiCountryObject != null && _apiCountries.isNotEmpty) {
      try {
        resolvedApiCountry = _apiCountries.firstWhere((c) => c.id == _selectedApiCountryObject!.id);
        if (kDebugMode) print("Validated current _selectedApiCountryObject ('${_selectedApiCountryObject!.fullNameEnglish}') with API list.");
      } catch (e) {
        if (kDebugMode) print("Current _selectedApiCountryObject ('${_selectedApiCountryObject!.fullNameEnglish}') no longer valid in API list.");
        resolvedApiCountry = null;
      }
    }

    if (resolvedApiCountry == null && _apiCountries.isNotEmpty) {
      resolvedApiCountry = _apiCountries.first;
      if (kDebugMode) print("Defaulting to first API country: ${resolvedApiCountry.fullNameEnglish}");
    }

    List<String> newCurrentStatesList = [];
    List<Region> regionsForResolvedCountry = [];
    String finalSelectedCountryDropDownName = _selectedCountry ?? '';
    String finalSelectedCountryId = selectedCountryId;
    String finalSelectedCountryFullName = selectedCountryName;


    if (resolvedApiCountry != null) {
      _selectedApiCountryObject = resolvedApiCountry;
      finalSelectedCountryDropDownName = resolvedApiCountry.fullNameEnglish;
      finalSelectedCountryId = resolvedApiCountry.id;
      finalSelectedCountryFullName = resolvedApiCountry.fullNameEnglish;
      regionsForResolvedCountry = resolvedApiCountry.regions;
      newCurrentStatesList = regionsForResolvedCountry.map((r) => r.name).toList();
    } else if (_apiCountries.isEmpty && countryNameFromPrefs != null) {
      finalSelectedCountryDropDownName = countryNameFromPrefs;
      finalSelectedCountryId = countryIdFromPrefs ?? '';
      finalSelectedCountryFullName = countryNameFromPrefs;
      _selectedApiCountryObject = null;
      if (kDebugMode) print("API countries empty. Using country from prefs: $finalSelectedCountryFullName. Regions will be empty.");
    } else {
      if (_selectedApiCountryObject != null && _selectedApiCountryObject!.fullNameEnglish == _selectedCountry) {
        regionsForResolvedCountry = _selectedApiCountryObject!.regions;
        newCurrentStatesList = regionsForResolvedCountry.map((r) => r.name).toList();
      } else {
        _selectedApiCountryObject = null;
      }
      if (kDebugMode) print("Could not fully resolve a country with API list. Current dropdown: $_selectedCountry. Regions may be empty or based on previous valid state.");
    }

    String? finalSelectedStateDropDownName = _selectedState;
    String finalSelectedRegionStoredId = selectedRegionId;
    String finalSelectedRegionStoredName = selectedRegionName;


    if (regionNameFromPrefs != null && regionsForResolvedCountry.isNotEmpty) {
      Region? matchedRegionFromPrefs;
      try {
        matchedRegionFromPrefs = regionsForResolvedCountry.firstWhere(
                (r) => r.name == regionNameFromPrefs || (regionIdFromPrefs != null && r.id == regionIdFromPrefs)
        );
      } catch (e) { matchedRegionFromPrefs = null; }

      if (matchedRegionFromPrefs != null) {
        finalSelectedStateDropDownName = matchedRegionFromPrefs.name;
        finalSelectedRegionStoredId = matchedRegionFromPrefs.id;
        finalSelectedRegionStoredName = matchedRegionFromPrefs.name;
        if (kDebugMode) print("Region from prefs ('$regionNameFromPrefs') matched: ${matchedRegionFromPrefs.name} (ID: ${matchedRegionFromPrefs.id})");
      } else {
        if (kDebugMode) print("Region from prefs ('$regionNameFromPrefs') not found in available regions for $finalSelectedCountryFullName.");
        if (finalSelectedStateDropDownName != null && !newCurrentStatesList.contains(finalSelectedStateDropDownName)) {
          finalSelectedStateDropDownName = null;
          finalSelectedRegionStoredId = '';
          finalSelectedRegionStoredName = '';
          if (kDebugMode) print("Resetting selected state as it's not in the new list of states.");
        }
      }
    } else if (finalSelectedStateDropDownName != null && !newCurrentStatesList.contains(finalSelectedStateDropDownName)) {
      finalSelectedStateDropDownName = null;
      finalSelectedRegionStoredId = '';
      finalSelectedRegionStoredName = '';
      if (kDebugMode) print("Current _selectedState ('$_selectedState') is invalid for the determined country's regions. Resetting.");
    }

    double loadedShippingCost = 0.0;
    String loadedShippingMethodName = '';
    String? loadedSelectedShippingId;
    String loadedCarrierCode = '';
    String loadedMethodCode = '';

    if (shippingMethodNameFromPrefs != null && shippingPriceFromPrefs != null && carrierCodeFromPrefs != null && methodCodeFromPrefs != null) {
      loadedShippingCost = shippingPriceFromPrefs;
      loadedShippingMethodName = shippingMethodNameFromPrefs;
      loadedSelectedShippingId = '${carrierCodeFromPrefs}_${methodCodeFromPrefs}';
      loadedCarrierCode = carrierCodeFromPrefs;
      loadedMethodCode = methodCodeFromPrefs;
    }

    if (!mounted) return;
    setState(() {
      _selectedCountry = finalSelectedCountryDropDownName.isNotEmpty ? finalSelectedCountryDropDownName : null;
      this.selectedCountryId = finalSelectedCountryId;
      this.selectedCountryName = finalSelectedCountryFullName;

      _currentStates = newCurrentStatesList;
      _selectedState = finalSelectedStateDropDownName;

      this.selectedRegionName = finalSelectedRegionStoredName;
      this.selectedRegionId = finalSelectedRegionStoredId;

      currentShippingCost = loadedShippingCost;
      selectedShippingMethodName = loadedShippingMethodName;
      _selectedShippingMethodId = loadedSelectedShippingId;
      carrierCode = loadedCarrierCode;
      methodCode = loadedMethodCode;

      _isLoadingShippingPrefs = false;

      if (kDebugMode) {
        print("--- setState COMPLETE (Prefs Loading) ---");
        print("Final _selectedShippingMethodId: $_selectedShippingMethodId");
      }
    });

    // ✅ ADDED: Trigger shipping fetch after preferences are loaded.
    _triggerShippingMethodUpdate();
  }


  Future<void> _callAndProcessFetchTotal() async {
    if (!mounted) return;
    setState(() { _isCartLoading = true; _cartError = null; });
    try {
      final Map<String, dynamic>? totalsObject = await _performFetchTotalApiCallModified();
      if (!mounted) return;
      if (totalsObject != null) {
        // Find the subtotal from the total_segments array
        double foundSubtotal = 0.0;
        if (totalsObject['total_segments'] is List) {
          try {
            final subtotalSegment = (totalsObject['total_segments'] as List)
                .firstWhere((segment) => segment['code'] == 'subtotal');
            foundSubtotal = (subtotalSegment['value'] as num?)?.toDouble() ?? 0.0;
          } catch (e) {
            if (kDebugMode) print("Subtotal segment not found. Defaulting to 0.");
            // If subtotal is not found, you might want to use grand_total as a fallback
            foundSubtotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
          }
        }

        setState(() {
          _grandTotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
          _subTotal = foundSubtotal; // ✅ SET THE NEW SUBTOTAL VARIABLE
          _itemsQty = totalsObject['items_qty'] as int? ?? 0;

          double calculatedWeight = 0.0;
          if (totalsObject.containsKey('items_weight') && totalsObject['items_weight'] != null) {
            calculatedWeight = (totalsObject['items_weight'] as num).toDouble();
          } else if (totalsObject.containsKey('weight') && totalsObject['weight'] != null) {
            calculatedWeight = (totalsObject['weight'] as num).toDouble();
          } else if (totalsObject['items'] is List) {
            for (var item_data in (totalsObject['items'] as List)) {
              if (item_data is Map<String, dynamic>) {
                final itemWeight = (item_data['weight'] as num?)?.toDouble() ?? 0.0;
                final itemQty = (item_data['qty'] as num?)?.toInt() ?? 1;
                calculatedWeight += (itemWeight * itemQty);
              }
            }
          }
          _cartTotalWeight = calculatedWeight;

          if (kDebugMode) {
            print("Cart total weight updated: $_cartTotalWeight");
            print("Subtotal set to: $_subTotal"); // For debugging
          }

          if (totalsObject['total_segments'] is List) {
            _fetchTotals = (totalsObject['total_segments'] as List)
                .map((segment) => segment as Map<String, dynamic>)
                .toList();
          } else { _fetchTotals = []; }
          _isCartLoading = false;
        });
      } else { throw Exception("Totals data received in unexpected format or user not logged in."); }
    } catch (e) {
      if (!mounted) return;
      if (kDebugMode) print("Error fetching totals: $e");
      setState(() {
        _cartError = e.toString(); _isCartLoading = false;
        _grandTotal = 0.0;
        _subTotal = 0.0; // Reset on error
        _itemsQty = 0;
        _fetchTotals = [];
        _cartTotalWeight = 0.0;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading totals: ${e.toString()}")));
      }
    }
  }

  Future<Map<String, dynamic>?> _performFetchTotalApiCallModified() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      if (kDebugMode) print("User not logged in, cannot fetch totals.");
      return Future.value({'grand_total': 0.0, 'items_qty': 0, 'total_segments': []});
    }

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(
        Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/totals'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $customerToken'},
      );
      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        if (decodedBody is Map<String, dynamic>) { return decodedBody; }
        else { throw Exception("Unexpected format for totals response. Expected Map, got: ${decodedBody.runtimeType}"); }
      } else { throw Exception("Failed to fetch totals: Status ${response.statusCode}, Body: ${response.body}"); }
    } finally { ioClient.close(); }
  }

  Future<void> _fetchAndPrintCartItemsDirectly() async {
    if (!mounted) return;
    try {
      final items = await _cartRepository.getCartItems();
      if (!mounted) return;
      setState(() { _fetchedCartItems = items; });
    } catch (e) {
      if (!mounted) return;
      if (kDebugMode) print("Error fetching cart items directly: $e");
      setState(() { _cartError = (_cartError ?? "") + " Cart items error: " + e.toString(); _fetchedCartItems = []; });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading cart: ${e.toString()}")));
      }
    }
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false; });
  }


  // ✅ MODIFIED: Now triggers a shipping fetch immediately.
  void _onCountryChanged(String? newCountryName) {
    if (newCountryName == null || newCountryName == _selectedCountry) return;

    Country? newSelectedApiCountry;
    try {
      newSelectedApiCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == newCountryName);
    } catch (e) {
      if (kDebugMode) print("Error: Selected country '$newCountryName' not found in API list.");
      return;
    }

    setState(() {
      _selectedApiCountryObject = newSelectedApiCountry;
      _selectedCountry = newSelectedApiCountry!.fullNameEnglish;
      selectedCountryName = newSelectedApiCountry.fullNameEnglish;
      selectedCountryId = newSelectedApiCountry.id;
      _currentStates = newSelectedApiCountry.regions.map((r) => r.name).toList();

      _selectedState = null;
      selectedRegionName = '';
      selectedRegionId = '';
      _displayableShippingMethods = [];
      _selectedShippingMethodId = null;
      _isFetchingShippingMethods = false;
    });

    // Trigger the fetch with the new country information.
    _triggerShippingMethodUpdate();
  }


  Future<void> _saveCurrentSelectionsToPrefs() async {
    if (selectedCountryName.isEmpty) {
      if (kDebugMode) print("Cannot save prefs: Country Name is empty.");
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_country_name', selectedCountryName);
    await prefs.setString('selected_country_id', selectedCountryId);

    if (selectedRegionName.isNotEmpty) {
      await prefs.setString('selected_region_name', selectedRegionName);
      await prefs.setString('selected_region_id', selectedRegionId);
    } else {
      await prefs.remove('selected_region_name');
      await prefs.remove('selected_region_id');
    }
    await prefs.setDouble('shipping_price', currentShippingCost);
    await prefs.setString('shipping_method_name', selectedShippingMethodName);
    await prefs.setString('shipping_carrier_code', carrierCode);
    await prefs.setString('shipping_method_code', methodCode);


    if (kDebugMode) {
      print("--- Preferences Saved (from CheckoutScreen) ---");
      print("Saved: Country: $selectedCountryName ($selectedCountryId), Region: $selectedRegionName ($selectedRegionId)");
      print("Saved Shipping: Method: $selectedShippingMethodName ($carrierCode/$methodCode), Cost: $currentShippingCost");
    }
  }

  @override
  void dispose() {
    _shippingBloc.close();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _shippingBloc,
      child: BlocListener<ShippingBloc, ShippingState>(
        listener: (context, state) {
          if (!mounted) return;

          if (state is CountriesLoading) {
            setState(() {
              _areCountriesLoading = true;
              _countriesError = null;
            });
          } else if (state is CountriesLoaded) {
            _apiCountries = state.countries;
            _areCountriesLoading = false;
            _initialCountryLoadAttempted = true;
            _countriesError = null;
            _loadShippingPreferencesForCheckout();
          }
          else if (state is ShippingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          else if (state is ShippingInfoSubmittedSuccessfully) {
            if (kDebugMode) {
              print("Shipping Info submitted successfully. Navigating to PaymentScreen...");
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: _shippingBloc,
                  child: PaymentScreen(
                    paymentMethods: state.paymentMethods,
                    totals: state.totals,
                    billingAddress: state.billingAddress,
                  ),
                ),
              ),
            );
          }

        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
            leading: IconButton(
              icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _isPageLoading
                  ? const Center(child: CircularProgressIndicator(key: ValueKey("main_page_loader")))
                  : _buildCheckoutForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutForm() {
    final bool isStateDropdownEnabled = _selectedApiCountryObject != null && _currentStates.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildEstimatedTotal(),
        const SizedBox(height: 24.0),
        const Text('Shipping Address', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 20.0),

        if (!isUserLoggedIn) ...[
          _buildTextFieldWithLabel('Email Address', controller: _emailController, isRequired: true, keyboardType: TextInputType.emailAddress),
          Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 16.0),
            child: Text('You can create an account after checkout.', style: TextStyle(fontSize: 12.0, color: Colors.grey[600])),
          ),
          Divider(height: 1, thickness: 0.8, color: Colors.grey[300]),
          const SizedBox(height: 16.0),
        ],

        _buildTextFieldWithLabel('First Name', controller: _firstNameController, isRequired: true),
        const SizedBox(height: 16.0),
        _buildTextFieldWithLabel('Last Name', controller: _lastNameController, isRequired: true),
        const SizedBox(height: 16.0),

        _buildLabel('Country', isRequired: true),
        if (_areCountriesLoading && !_initialCountryLoadAttempted)
          const Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Center(child: CircularProgressIndicator(key: ValueKey("country_dropdown_loader"))))
        else if (_countriesError != null && _apiCountries.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text("Error: $_countriesError", style: const TextStyle(color: Colors.red)))
        else if (_apiCountries.isEmpty && _initialCountryLoadAttempted)
            Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text("No countries available.", style: TextStyle(color: Colors.grey[700])))
          else
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              ),
              value: _selectedCountry,
              isExpanded: true,
              hint: const Text("Select Country"),
              items: _apiCountries.map((Country country) {
                return DropdownMenuItem<String>(
                  value: country.fullNameEnglish,
                  child: Text(country.fullNameEnglish),
                );
              }).toList(),
              onChanged: _apiCountries.isEmpty ? null : _onCountryChanged,
            ),
        const SizedBox(height: 16.0),

        _buildLabel('State/Province', isRequired: true),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          ),
          value: _selectedState,
          hint: Text(
              _selectedCountry == null || _selectedCountry!.isEmpty
                  ? 'Please select a country first'
                  : (isStateDropdownEnabled ? 'Please select a region...' : 'No regions for selected country'),
              style: TextStyle(color: Colors.grey[600])
          ),
          isExpanded: true,
          items: _currentStates.map((String regionName) {
            return DropdownMenuItem<String>(value: regionName, child: Text(regionName));
          }).toList(),
          onChanged: isStateDropdownEnabled ? (newRegionName) {
            if (newRegionName == null) return;
            setState(() {
              Region? selectedRegionObject;
              if (_selectedApiCountryObject != null) {
                try {
                  selectedRegionObject = _selectedApiCountryObject!.regions.firstWhere((r) => r.name == newRegionName);
                } catch (e) {
                  if (kDebugMode) print("Error: Selected region name '$newRegionName' not found.");
                  selectedRegionObject = null;
                }
              }

              _selectedState = newRegionName;

              if (selectedRegionObject != null) {
                selectedRegionName = selectedRegionObject.name;
                selectedRegionId = selectedRegionObject.id;
                selectedRegionCode = selectedRegionObject.code;
              } else {
                selectedRegionName = '';
                selectedRegionId = '';
                selectedRegionCode = '';
              }
              if (kDebugMode) {
                print("Region selected: $selectedRegionName (ID: $selectedRegionId, Code: $selectedRegionCode)");
              }
            });
            _triggerShippingMethodUpdate();
          } : null,
          disabledHint: Text(
              _selectedCountry == null || _selectedCountry!.isEmpty
                  ? 'Please select a country first'
                  : 'No regions available',
              style: TextStyle(color: Colors.grey[500])
          ),
        ),
        const SizedBox(height: 16.0),

        _buildTextFieldWithLabel('Street Address', controller: _streetAddressController, isRequired: true, maxLines: 2),
        const SizedBox(height: 16.0),
        _buildTextFieldWithLabel('City', controller: _cityController, isRequired: true),
        const SizedBox(height: 16.0),

        _buildTextFieldWithLabel(
          'Zip/Postal Code',
          controller: _zipController,
          isRequired: true,
          keyboardType: TextInputType.number,
          onEditingComplete: _triggerShippingMethodUpdate,
        ),
        const SizedBox(height: 16.0),
        _buildTextFieldWithLabel('Phone Number', controller: _phoneController, isRequired: true, keyboardType: TextInputType.phone),
        const SizedBox(height: 24.0),

        BlocBuilder<ShippingBloc, ShippingState>(
            builder: (context, blocState) {
              return _buildShippingMethodsSection(blocState);
            }
        ),
        const SizedBox(height: 24.0),
        _buildHelpButton(),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildEstimatedTotal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ✅ MODIFIED: Changed text from "Estimated Total" to "Order Subtotal"
              const Text('Order Subtotal', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Colors.black87)),
              const SizedBox(height: 4.0),
              _isCartLoading
                  ? const Text('Loading...', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black54))
              // ✅ MODIFIED: Display _subTotal instead of _grandTotal
                  : Text('₹${_subTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          Row(
            children: <Widget>[
              const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4.0)),
                child: _isCartLoading
                    ? const Text('...', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13))
                    : Text(_itemsQty.toString(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 14.0, color: Colors.black87, fontWeight: FontWeight.w500),
          children: isRequired ? [TextSpan(text: ' *', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold))] : [],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithLabel(String label, {
    bool isRequired = false,
    int maxLines = 1,
    String? hintText,
    TextEditingController? controller,
    TextInputType? keyboardType,
    void Function()? onEditingComplete
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildLabel(label, isRequired: isRequired),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          ),
          style: const TextStyle(fontSize: 15.0),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, TextAlign textAlign = TextAlign.left}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 13.0,
              fontWeight: isHeader ? FontWeight.w500 : FontWeight.normal,
              color: Colors.black87),
          textAlign: textAlign,
        ),
      ),
    );
  }

  Future<void> _showShippingMethodSelectionDialog(BuildContext context) async {
    String? tempSelectedShippingId = _selectedShippingMethodId;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              title: const Text('Select Shipping Method'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: _displayableShippingMethods.map((method) {
                    return RadioListTile<String>(
                      title: Text("${method['title']} (${method['carrier']})"),
                      subtitle: Text(method['price_str'] as String),
                      value: method['id'] as String,
                      groupValue: tempSelectedShippingId,
                      onChanged: (String? value) {
                        if (value != null) {
                          stfSetState(() {
                            tempSelectedShippingId = value;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  child: const Text('Select'),
                  onPressed: () {
                    if (tempSelectedShippingId != null) {
                      setState(() {
                        _selectedShippingMethodId = tempSelectedShippingId!;
                        final newSelectedMethodData = _displayableShippingMethods.firstWhere(
                                (m) => m['id'] == _selectedShippingMethodId
                        );
                        currentShippingCost = newSelectedMethodData['price_val'] as double;
                        selectedShippingMethodName = newSelectedMethodData['title'] as String;
                        carrierCode = newSelectedMethodData['carrier_code'] as String;
                        methodCode = newSelectedMethodData['method_code'] as String;
                      });
                    }
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildShippingMethodsSection(ShippingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Methods',
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8.0),
        Divider(height: 1, thickness: 0.8, color: Colors.grey[300]),
        const SizedBox(height: 16.0),

        if (_isFetchingShippingMethods)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text("Estimating shipping costs...")),
          )
        else if (_displayableShippingMethods.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text("Please select a country to estimate shipping.")),
          )
        else ...[
                () {
              Map<String, dynamic>? determinedShippingMethod;
              if (_selectedShippingMethodId != null) {
                try {
                  determinedShippingMethod = _displayableShippingMethods.firstWhere(
                        (m) => m['id'] == _selectedShippingMethodId,
                  );
                } catch (e) {
                  if (kDebugMode) print("Error finding selected shipping method ID '$_selectedShippingMethodId'. $e");
                  determinedShippingMethod = null;
                }
              }

              if (determinedShippingMethod == null) {
                // This can happen if the selected ID is no longer in the list after a refresh
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: Text("Please re-select a shipping method.")),
                );
              }

              return Table(
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                columnWidths: const {
                  0: IntrinsicColumnWidth(flex: 0.7),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[100]),
                    children: [
                      _buildTableCell('Select Method', isHeader: true, textAlign: TextAlign.center),
                      _buildTableCell('Price', isHeader: true, textAlign: TextAlign.center),
                      _buildTableCell('Method Title', isHeader: true, textAlign: TextAlign.center),
                      _buildTableCell('Carrier Title', isHeader: true, textAlign: TextAlign.center),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Center(
                          child: Radio<String>(
                            value: determinedShippingMethod['id'] as String,
                            groupValue: _selectedShippingMethodId,
                            onChanged: null,
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      _buildTableCell(
                        '₹${(determinedShippingMethod['price_val'] as double).toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                      ),
                      _buildTableCell(
                        determinedShippingMethod['title'] as String,
                        textAlign: TextAlign.center,
                      ),
                      _buildTableCell(
                        determinedShippingMethod['carrier'] as String,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              );
            }(),

            const SizedBox(height: 24.0),

            Align(
              alignment: Alignment.centerRight,
              child: BlocBuilder<ShippingBloc, ShippingState>(
                builder: (context, state) {
                  final isSubmitting = state is ShippingInfoSubmitting;

                  // ✅ FIXED: Changed orElse to return Map<String, Object> to match inferred type.
                  final determinedShippingMethod = _displayableShippingMethods.firstWhere(
                        (m) => m['id'] == _selectedShippingMethodId,
                    orElse: () => <String, Object>{}, // The fix is on this line
                  );

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      disabledBackgroundColor: Colors.grey[700],
                    ),
                    onPressed: isSubmitting ? null : () async {
                      if (_firstNameController.text.isEmpty ||
                          _lastNameController.text.isEmpty ||
                          _streetAddressController.text.isEmpty ||
                          _cityController.text.isEmpty ||
                          _zipController.text.isEmpty ||
                          _phoneController.text.isEmpty ||
                          selectedCountryId.isEmpty
                      ) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all required fields.')),
                        );
                        return;
                      }
                      if (determinedShippingMethod.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a shipping method first.')),
                        );
                        return;
                      }

                      _saveCurrentSelectionsToPrefs();

                      final prefs = await SharedPreferences.getInstance();
                      final finalCarrierCode = prefs.getString('carrier_code') ?? carrierCode;
                      final finalMethodCode = prefs.getString('method_code') ?? methodCode;

                      context.read<ShippingBloc>().add(
                        SubmitShippingInfo(
                          firstName: _firstNameController.text,
                          lastName: _lastNameController.text,
                          streetAddress: _streetAddressController.text,
                          city: _cityController.text,
                          zipCode: _zipController.text,
                          phone: _phoneController.text,
                          email: _emailController.text.isNotEmpty ? _emailController.text : 'mitesh@gmail.com',
                          countryId: selectedCountryId,
                          regionName: selectedRegionName,
                          regionId: selectedRegionId,
                          regionCode: selectedRegionCode,
                          carrierCode: finalCarrierCode,
                          methodCode: finalMethodCode,
                        ),
                      );
                    },
                    child: isSubmitting
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text('NEXT'),
                  );
                },
              ),
            ),
          ],
      ],
    );
  }

  Widget _buildHelpButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help button pressed!'))),
        icon: const Icon(Icons.help_outline, color: Colors.white, size: 20),
        label: const Text('Help', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), elevation: 2.0),
      ),
    );
  }
}