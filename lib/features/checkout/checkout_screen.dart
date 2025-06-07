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

  // Keep your original template
  static const List<Map<String, dynamic>> _initialShippingMethodsTemplate = [
    {
      'id': 0,
      'price_str': '₹1,500.00', // Default/initial price string
      'price_val': 1500.0,    // Default/initial price value
      'title': 'DHL',
      'carrier': 'Express',
      'carrier_code': 'dhl',
      'method_code': 'express',
      'is_api_updatable': true // Flag to identify which method's price is updated by API
    },
    {
      'id': 1,
      'price_str': '₹0.00',
      'price_val': 0.0,
      'title': 'Standard',
      'carrier': 'Free',
      'carrier_code': 'freeshipping',
      'method_code': 'freeshipping',
      'is_api_updatable': false
    },
  ];

  // This will be our live list for UI and updates
  List<Map<String, dynamic>> _displayableShippingMethods = [];

  final CartRepository _cartRepository = CartRepository();
  List<Map<String, dynamic>> _fetchedCartItems = [];
  List<Map<String, dynamic>> _fetchTotals = [];
  bool _isCartLoading = false;
  String? _cartError;

  int _selectedShippingMethodIndex = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoadingShippingPrefs = true;

  bool get _isPageLoading => _isLoadingShippingPrefs || (_areCountriesLoading && !_initialCountryLoadAttempted);

  // Define hardcoded shipping methods here to be accessible by _onCountryChanged and _buildShippingMethodsSection
  final List<Map<String, dynamic>> _hardcodedShippingMethods = [
    {'id': 0, 'price_str': '₹1,500.00', 'price_val': 1500.0, 'title': 'DHL', 'carrier': 'Express', 'carrier_code': 'dhl', 'method_code': 'express'},
    {'id': 1, 'price_str': '₹0.00', 'price_val': 0.0, 'title': 'Standard', 'carrier': 'Free', 'carrier_code': 'freeshipping', 'method_code': 'freeshipping'},
  ];



  // ✅ Async method to use await
  Future<void> _loadCustomerIdAndFetchWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final cust_id = prefs.getInt('user_customer_id');
    print("Stored customer_id>>>>>: $cust_id");

    if (cust_id != null) {
      double weight = await fetchCartTotalWeight(cust_id);
      print("Cart total weight: $weight");

      // You can update state if needed:
      if (!mounted) return;
      setState(() {
        _cartTotalWeight = weight;
      });
    } else {
      print("Customer ID not found in SharedPreferences");
    }
  }

  Future<double> fetchCartTotalWeight(int customerId) async {
    print("checkout >> fetchCartTotalWeightcalled>>");

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
      throw Exception("Failed to fetch cart total weight: ${response.body}");
    }
  }

  // Add this method to your _CheckoutScreenState class
  void _selectStandardShippingMethod() {
    if (!mounted) return;

    final standardMethodIndexInDisplayable = _displayableShippingMethods.indexWhere(
            (m) => m['carrier_code'] == 'freeshipping' && m['method_code'] == 'freeshipping');

    if (standardMethodIndexInDisplayable != -1) {
      final standardMethodData = _displayableShippingMethods[standardMethodIndexInDisplayable];
      setState(() {
        _selectedShippingMethodIndex = standardMethodData['id'] as int;
        currentShippingCost = standardMethodData['price_val'] as double;
        selectedShippingMethodName = standardMethodData['title'] as String;
        carrierCode = standardMethodData['carrier_code'] as String;
        methodCode = standardMethodData['method_code'] as String;
        if (kDebugMode) {
          print("Defaulted to Standard Shipping method due to API price or error.");
        }
      });
    } else {
      if (kDebugMode) {
        print("Standard shipping method (freeshipping/freeshipping) not found in _displayableShippingMethods. Cannot default.");
      }
      // Optional: Fallback to the first available method if Standard is not found
      if (_displayableShippingMethods.isNotEmpty) {
        final firstMethodData = _displayableShippingMethods.first;
        setState(() {
          _selectedShippingMethodIndex = firstMethodData['id'] as int;
          currentShippingCost = firstMethodData['price_val'] as double;
          selectedShippingMethodName = firstMethodData['title'] as String;
          carrierCode = firstMethodData['carrier_code'] as String;
          methodCode = firstMethodData['method_code'] as String;
          if (kDebugMode) {
            print("Standard shipping not found. Defaulting to first available method: ${firstMethodData['title']}.");
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _shippingBloc = ShippingBloc();
    _shippingBloc.add(FetchCountries());
    _displayableShippingMethods = _initialShippingMethodsTemplate
        .map((method) => Map<String, dynamic>.from(method))
        .toList();

    _loadLoginStatus();
    _fetchAndPrintCartItemsDirectly();
    _callAndProcessFetchTotal();
    _loadCustomerIdAndFetchWeight();



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
    final String? shippingMethodNameFromPrefs = prefs.getString('shipping_method_name'); // Renamed for clarity
    final String? carrierCodeFromPrefs = prefs.getString('shipping_carrier_code'); // Assuming you might save these
    final String? methodCodeFromPrefs = prefs.getString('shipping_method_code');   // Assuming you might save these

    print("method code $methodCodeFromPrefs");
    print("method code $carrierCodeFromPrefs");
    print("method code $carrierCodeFromPrefs");
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

    // Shipping method preference loading
    double loadedShippingCost = 0.0;
    String loadedShippingMethodName = '';
    int loadedSelectedShippingIndex = 0; // Default to first if not found
    String loadedCarrierCode = '';
    String loadedMethodCode = '';

    // IMPORTANT CHANGE: Use _displayableShippingMethods
    if (shippingMethodNameFromPrefs != null && shippingPriceFromPrefs != null && _displayableShippingMethods.isNotEmpty) {
      int foundIndex = -1;
      if (carrierCodeFromPrefs != null && methodCodeFromPrefs != null) {
        foundIndex = _displayableShippingMethods.indexWhere((m) => // Use _displayableShippingMethods
        m['carrier_code'] == carrierCodeFromPrefs && m['method_code'] == methodCodeFromPrefs);
      }
      if (foundIndex == -1) {
        foundIndex = _displayableShippingMethods.indexWhere((m) => m['title'] == shippingMethodNameFromPrefs); // Use _displayableShippingMethods
      }

      if (foundIndex != -1) {
        final matchedMethod = _displayableShippingMethods[foundIndex]; // Use _displayableShippingMethods
        loadedShippingCost = shippingPriceFromPrefs;
        loadedShippingMethodName = matchedMethod['title'] as String;
        loadedSelectedShippingIndex = matchedMethod['id'] as int;
        loadedCarrierCode = matchedMethod['carrier_code'] as String;
        loadedMethodCode = matchedMethod['method_code'] as String;
        if (kDebugMode) print("Shipping method from prefs matched: $loadedShippingMethodName, Price: $loadedShippingCost");
      } else {
        if (kDebugMode) print("Shipping method from prefs ('$shippingMethodNameFromPrefs') not found. Defaulting.");
        final defaultMethod = _displayableShippingMethods.first; // Use _displayableShippingMethods
        loadedShippingCost = defaultMethod['price_val'] as double;
        // ... (set other default values as before)
        loadedShippingMethodName = defaultMethod['title'] as String;
        loadedSelectedShippingIndex = defaultMethod['id'] as int;
        loadedCarrierCode = defaultMethod['carrier_code'] as String;
        loadedMethodCode = defaultMethod['method_code'] as String;
      }
    } else if (_displayableShippingMethods.isNotEmpty) { // Use _displayableShippingMethods
      final defaultMethod = _displayableShippingMethods.first; // Use _displayableShippingMethods
      loadedShippingCost = defaultMethod['price_val'] as double;
      // ... (set other default values as before)
      loadedShippingMethodName = defaultMethod['title'] as String;
      loadedSelectedShippingIndex = defaultMethod['id'] as int;
      loadedCarrierCode = defaultMethod['carrier_code'] as String;
      loadedMethodCode = defaultMethod['method_code'] as String;
      if (kDebugMode) print("No/incomplete shipping prefs. Defaulting to: $loadedShippingMethodName");
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
      _selectedShippingMethodIndex = loadedSelectedShippingIndex;
      carrierCode = loadedCarrierCode;
      methodCode = loadedMethodCode;


      _isLoadingShippingPrefs = false;

      if (kDebugMode) {
        print("--- setState COMPLETE (Prefs Loading) ---");
        print("Final _selectedCountry for Dropdown: $_selectedCountry");
        print("Final selectedCountryId: $selectedCountryId, Final selectedCountryName: $selectedCountryName");
        print("Final _currentStates (${_currentStates.length}): ${_currentStates.take(5).join(', ')}...");
        print("Final _selectedState for Dropdown: $_selectedState");
        print("Final selectedRegionName: $selectedRegionName, Final selectedRegionId: $selectedRegionId");
        print("Final Shipping: Method='$selectedShippingMethodName', Cost='$currentShippingCost', Index='$_selectedShippingMethodIndex'");
      }

      if (selectedCountryId.isNotEmpty) {

        _shippingBloc.add(EstimateShipping(selectedCountryId, _cartTotalWeight));
      }
    });
  }









  Future<void> _callAndProcessFetchTotal() async {
    if (!mounted) return;
    setState(() { _isCartLoading = true; _cartError = null; });
    try {
      final Map<String, dynamic>? totalsObject = await _performFetchTotalApiCallModified();
      if (!mounted) return;
      if (totalsObject != null) {
        setState(() {
          _grandTotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
          _itemsQty = totalsObject['items_qty'] as int? ?? 0;

          // Attempt to extract total weight from the totalsObject
          // Common keys in Magento for total weight are 'items_weight', 'weight', or 'base_total_weight'
          // Or it might need to be summed from the 'items' array if present.
          double calculatedWeight = 0.0;
          if (totalsObject.containsKey('items_weight') && totalsObject['items_weight'] != null) {
            calculatedWeight = (totalsObject['items_weight'] as num).toDouble();
          } else if (totalsObject.containsKey('weight') && totalsObject['weight'] != null) {
            calculatedWeight = (totalsObject['weight'] as num).toDouble();
          } else if (totalsObject['items'] is List) {
            // Fallback: Sum weights from individual items if 'items' array is present
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
        _grandTotal = 0.0; _itemsQty = 0; _fetchTotals = [];
        _cartTotalWeight = 0.0; // Reset weight on error
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

  // MODIFIED: This method now handles the UI updates synchronously
  // and then calls an async helper to fetch data.
  void _onCountryChanged(String? newCountryName) {
    if (newCountryName == null || newCountryName == _selectedCountry) return;

    Country? newSelectedApiCountry;
    try {
      newSelectedApiCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == newCountryName);
    } catch (e) {
      if (kDebugMode) print("Error: Selected country '$newCountryName' not found in API list.");
      return;
    }

    // --- Start of synchronous state updates ---
    // This updates the UI immediately for a responsive feel.
    setState(() {
      _selectedApiCountryObject = newSelectedApiCountry;
      _selectedCountry = newSelectedApiCountry!.fullNameEnglish;
      selectedCountryName = newSelectedApiCountry.fullNameEnglish;
      selectedCountryId = newSelectedApiCountry.id;

      _currentStates = newSelectedApiCountry.regions.map((r) => r.name).toList();
      _selectedState = null;
      selectedRegionName = '';
      selectedRegionId = '';

      // Reset _displayableShippingMethods to initial template values
      _displayableShippingMethods = _initialShippingMethodsTemplate
          .map((method) => Map<String, dynamic>.from(method))
          .toList();

      // Reset shipping method selection to default from the (now reset) _displayableShippingMethods
      if (_displayableShippingMethods.isNotEmpty) {
        final defaultMethod = _displayableShippingMethods.first; // Or your preferred default
        _selectedShippingMethodIndex = defaultMethod['id'] as int;
        currentShippingCost = defaultMethod['price_val'] as double;
        carrierCode = defaultMethod['carrier_code'] as String;
        methodCode = defaultMethod['method_code'] as String;
        selectedShippingMethodName = defaultMethod['title'] as String;
      } else {
        _selectedShippingMethodIndex = 0; // Or -1
        currentShippingCost = 0.0;
        carrierCode = '';
        methodCode = '';
        selectedShippingMethodName = '';
      }

      if (kDebugMode) {
        print("Country changed to: $selectedCountryName (ID: $selectedCountryId)");
        print("Shipping methods reset to template. Default selection: $selectedShippingMethodName, Cost: $currentShippingCost");
      }
    });
    // --- End of synchronous state updates ---

    // --- Start of asynchronous logic ---
    // Call the helper function to perform async operations without blocking the UI.
    _fetchWeightAndEstimateShipping(selectedCountryId);
  }

  // NEW: Helper method to fetch weight and trigger shipping estimation.
  Future<void> _fetchWeightAndEstimateShipping(String countryId) async {
    if (countryId.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cust_id = prefs.getInt('user_customer_id');

      if (cust_id != null) {
        // As requested, fetch the weight again to ensure it's up-to-date.
        final double newWeight = await fetchCartTotalWeight(cust_id);
        if (!mounted) return;

        // Update the state with the new weight.
        setState(() {
          _cartTotalWeight = newWeight;
        });

        // Dispatch the BLoC event with the fresh data.
        _shippingBloc.add(EstimateShipping(countryId, newWeight));
      } else {
        if (kDebugMode) print("No customer ID found. Estimating shipping with current weight: $_cartTotalWeight");
        _shippingBloc.add(EstimateShipping(countryId, _cartTotalWeight));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching weight and estimating shipping: $e");
      }
      // Fallback: Dispatch with the current weight to at least try.
      _shippingBloc.add(EstimateShipping(countryId, _cartTotalWeight));
    }
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
    await prefs.setString('shipping_carrier_code', carrierCode); // Save carrier code
    await prefs.setString('shipping_method_code', methodCode);   // Save method code


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
          } else if (state is ShippingError) {
            // Handle Shipping Estimation Errors
            if (state.message == "Failed to estimate shipping") {
              if (kDebugMode) print("Shipping estimation failed via BLoC. Defaulting to Standard Shipping.");
              _selectStandardShippingMethod();
              if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message + ". Defaulted to Standard Shipping.")));
            } else { // Handle other errors, e.g., country loading
              setState(() {
                _areCountriesLoading = false;
                _initialCountryLoadAttempted = true;
                if (_apiCountries.isEmpty) { // Likely a country loading error
                  _countriesError = state.message;
                }
              });
              if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          } else if (state is ShippingRateLoading) {
            if (kDebugMode) print("Shipping rate is loading (event from BLoC)...");
          } else if (state is ShippingRateLoaded) {
            if (kDebugMode) print("Shipping rate loaded event received (from BLoC). Price: ${state.shippingPrice}");
            setState(() {
              int updatableMethodIndex = _displayableShippingMethods.indexWhere(
                      (m) => m['is_api_updatable'] == true);

              // Always update the display price of the API-updatable method in the list
              if (updatableMethodIndex != -1) {
                _displayableShippingMethods[updatableMethodIndex]['price_val'] = state.shippingPrice;
                _displayableShippingMethods[updatableMethodIndex]['price_str'] = '₹${state.shippingPrice.toStringAsFixed(2)}';
                if (kDebugMode) {
                  print("Updated API-driven shipping method's display price to: ${state.shippingPrice}");
                }
              } else {
                if (kDebugMode) print("No method flagged as 'is_api_updatable' found. Cannot update display price from API.");
              }

              // Now, decide on the *selected* shipping method
              if (state.shippingPrice <= 0) {
                if (kDebugMode) print("API returned shipping price <= 0 (${state.shippingPrice}). Defaulting selection to Standard Shipping.");
                _selectStandardShippingMethod(); // This updates _selectedShippingMethodIndex, currentShippingCost etc.
              } else {
                // API price is > 0.
                // If the API-updatable method was already selected by the user, update its currentShippingCost.
                // Otherwise, the user's current selection (e.g., Standard if they picked it) remains.
                if (updatableMethodIndex != -1 && _selectedShippingMethodIndex == _displayableShippingMethods[updatableMethodIndex]['id']) {
                  currentShippingCost = state.shippingPrice;
                  if (kDebugMode) {
                    print("API-driven method is selected and price > 0. Updated currentShippingCost to: ${state.shippingPrice}");
                  }
                } else {
                  if (kDebugMode && updatableMethodIndex != -1) { // Check if updatableMethodIndex is valid
                    print("API price > 0. Current selection (${selectedShippingMethodName}) is not the API-updatable method ('${_displayableShippingMethods[updatableMethodIndex]['title']}'). Selection and cost remain based on user's choice.");
                  } else if (kDebugMode) {
                    print("API price > 0. No API-updatable method or current selection is not it. Selection and cost remain based on user's choice.");
                  }
                }
              }
            });
          }
        },

        child: Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
            leading: IconButton(
              icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>   ShoppingBagScreen()));
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
              _selectedState = newRegionName;
              selectedRegionName = newRegionName;
              Region? selectedRegionObject;
              if (_selectedApiCountryObject != null) {
                try {
                  selectedRegionObject = _selectedApiCountryObject!.regions.firstWhere((r) => r.name == newRegionName);
                  selectedRegionId = selectedRegionObject.id;
                } catch (e) {
                  selectedRegionId = '';
                  if (kDebugMode) print("Error: Selected region name '$newRegionName' not found in regions of '${_selectedApiCountryObject!.fullNameEnglish}'.");
                }
              } else {
                selectedRegionId = '';
                if (kDebugMode) print("Error: _selectedApiCountryObject is null. Cannot set region ID.");
              }
              if (kDebugMode) print("Region selected: $selectedRegionName (ID: $selectedRegionId)");
            });
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
        _buildTextFieldWithLabel('Zip/Postal Code', controller: _zipController, isRequired: true, keyboardType: TextInputType.number),
        const SizedBox(height: 16.0),
        _buildTextFieldWithLabel('Phone Number', controller: _phoneController, isRequired: true, keyboardType: TextInputType.phone),
        const SizedBox(height: 24.0),

        BlocBuilder<ShippingBloc, ShippingState>(
            builder: (context, blocState) { // Renamed to blocState to avoid conflict if 'state' is used elsewhere
              return _buildShippingMethodsSection(blocState); // Pass the BLoC's state
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
              const Text('Estimated Total', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Colors.black87)),
              const SizedBox(height: 4.0),
              _isCartLoading
                  ? const Text('Loading...', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black54))
                  : Text('₹${_grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black)),
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

  Widget _buildTextFieldWithLabel(String label, {bool isRequired = false, int maxLines = 1, String? hintText, TextEditingController? controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildLabel(label, isRequired: isRequired),
        TextField(
          controller: controller, maxLines: maxLines, keyboardType: keyboardType,
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
// Add this method to your _CheckoutScreenState class
  Future<void> _showShippingMethodSelectionDialog(BuildContext context) async {
    // Use a temporary variable to hold the selection within the dialog
    int? tempSelectedShippingMethodId = _selectedShippingMethodIndex;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( // Use StatefulBuilder to update dialog content
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              title: const Text('Select Shipping Method'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: _displayableShippingMethods.map((method) {
                    return RadioListTile<int>(
                      title: Text("${method['title']} (${method['carrier']})"),
                      subtitle: Text(method['price_str'] as String),
                      value: method['id'] as int,
                      groupValue: tempSelectedShippingMethodId,
                      onChanged: (int? value) {
                        if (value != null) {
                          stfSetState(() { // Update dialog's state
                            tempSelectedShippingMethodId = value;
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
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Select'),
                  onPressed: () {
                    if (tempSelectedShippingMethodId != null) {
                      // Update the main screen's state
                      setState(() {
                        _selectedShippingMethodIndex = tempSelectedShippingMethodId!;
                        final newSelectedMethodData = _displayableShippingMethods.firstWhere(
                                (m) => m['id'] == _selectedShippingMethodIndex
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


  Widget _buildShippingMethodsSection(ShippingState state) { // Accepts BLoC state
    Map<String, dynamic>? determinedShippingMethod;

    // Determine which single shipping method to display.
    // This logic should align with how _selectedShippingMethodIndex, currentShippingCost, etc., are set.
    if (_displayableShippingMethods.isNotEmpty && _selectedShippingMethodIndex >= 0) {
      try {
        determinedShippingMethod = _displayableShippingMethods.firstWhere(
                (m) => m['id'] == _selectedShippingMethodIndex
        );
      } catch (e) {
        if (kDebugMode) print("Error finding the determined shipping method by ID: $_selectedShippingMethodIndex. $e");
        // Fallback if the selected index is somehow invalid
        if (_displayableShippingMethods.isNotEmpty) {
          _selectedShippingMethodIndex = _displayableShippingMethods.first['id'] as int;
          determinedShippingMethod = _displayableShippingMethods.first;
          // Ensure related state variables are also updated if we fallback
          currentShippingCost = determinedShippingMethod['price_val'] as double;
          selectedShippingMethodName = determinedShippingMethod['title'] as String;
          carrierCode = determinedShippingMethod['carrier_code'] as String;
          methodCode = determinedShippingMethod['method_code'] as String;
        }
      }
    }

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

        if (state is ShippingRateLoading && selectedCountryId.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text("Estimating shipping costs...")),
          )
        else if (determinedShippingMethod == null) // If no method could be determined
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text("Shipping method not determined.")),
          )
        else // Display the single determined shipping method in a table structure
          Table(
            border: TableBorder.all(color: Colors.grey.shade300, width: 1),
            columnWidths: const {
              0: IntrinsicColumnWidth(flex: 0.7), // "Select Method" column
              1: FlexColumnWidth(1),             // Price
              2: FlexColumnWidth(1.2),           // Method Title
              3: FlexColumnWidth(1.2),           // Carrier Title
            },
            children: [
              // Header Row (as per your image)
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: [
                  _buildTableCell('Select Method', isHeader: true, textAlign: TextAlign.center),
                  _buildTableCell('Price', isHeader: true, textAlign: TextAlign.center),
                  _buildTableCell('Method Title', isHeader: true, textAlign: TextAlign.center),
                  _buildTableCell('Carrier Title', isHeader: true, textAlign: TextAlign.center),
                ],
              ),
              // Single Data Row for the determined method
              TableRow(
                children: [
                  TableCell( // "Select Method" cell - shows a selected radio, but it's non-interactive here
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: Radio<int>(
                        value: determinedShippingMethod['id'] as int, // Value of the determined method
                        groupValue: determinedShippingMethod['id'] as int, // Group value is same as value to make it appear selected
                        onChanged: null, // NON-INTERACTIVE: User cannot change it here
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  _buildTableCell(
                    // Display the price of the determined method.
                    // currentShippingCost should reflect this method's price.
                      '₹${currentShippingCost.toStringAsFixed(2)}',
                      textAlign: TextAlign.center
                  ),
                  _buildTableCell(
                      determinedShippingMethod['title'] as String,
                      textAlign: TextAlign.center
                  ),
                  _buildTableCell(
                      determinedShippingMethod['carrier'] as String,
                      textAlign: TextAlign.center
                  ),
                ],
              ),
            ],
          ),

        const SizedBox(height: 24.0),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
            ),
            onPressed: () {
              if (determinedShippingMethod != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('NEXT: ${determinedShippingMethod['title']}')));
                _saveCurrentSelectionsToPrefs();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shipping method not determined.')));
              }
            },
            child: const Text('NEXT'),
          ),
        ),
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