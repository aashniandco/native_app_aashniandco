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

  // Keep your original template
// Update your initial template with String IDs

  static const List<Map<String, dynamic>> _initialShippingMethodsTemplate = [
    {
      // ✅ FIX: Use a unique string ID
      'id': 'dhl_express',
      'price_str': '₹1,500.00',
      'price_val': 1500.0,
      'title': 'DHL',
      'carrier': 'Express',
      'carrier_code': 'tablerate',
      'method_code': 'bestway',
      'is_api_updatable': true
    },
    {
      // ✅ FIX: Use a unique string ID
      'id': 'freeshipping_freeshipping',
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



  // ✅ ADD THIS NEW METHOD TO _CheckoutScreenState

  Future<void> fetchAndDisplayShippingMethods() async {
    // --- 1. Validation ---
    // Ensure we have enough information to make the call.
    if (selectedCountryId.isEmpty ||
        selectedRegionId.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _streetAddressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _zipController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      if (kDebugMode) {
        print("Shipping estimation skipped: Address form is incomplete.");
      }
      // Clear any previously fetched methods if the address is no longer valid
      setState(() {
        _displayableShippingMethods = [];
      });
      return;
    }

    // Show a loading indicator in the UI (optional but recommended)
    setState(() {
      // You could set a new bool `_isFetchingRates = true;` here if you want a dedicated loader
    });

    try {
      // --- 2. Get Auth Token ---
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('user_token');
      if (customerToken == null || customerToken.isEmpty) {
        throw Exception("User not logged in");
      }

      // --- 3. Build the Payload ---
      final payload = {
        "address": {
          "region": selectedRegionName,
          "region_id": int.tryParse(selectedRegionId) ?? 0,
          "region_code": selectedRegionCode,
          "country_id": selectedCountryId,
          "postcode": _zipController.text,
          "city": _cityController.text,
          "street": [_streetAddressController.text],
          "firstname": _firstNameController.text,
          "lastname": _lastNameController.text,
          "telephone": _phoneController.text,
        }
      };

      if (kDebugMode) {
        print("--- Fetching available shipping methods ---");
        print("Request Payload: ${json.encode(payload)}");
      }

      // --- 4. Make the API Call ---
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $customerToken',
        },
        body: json.encode(payload),
      );

      if (kDebugMode) {
        print("API Response Status: ${response.statusCode}");
        print("API Response Body: ${response.body}");
      }

      // --- 5. Process the Response and Update the UI ---
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // If no methods are returned, show a message
        if (responseData.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No shipping methods available for this address.")),
          );
          setState(() {
            _displayableShippingMethods = [];
          });
          return;
        }

        // Transform the API response into the format your UI table expects
        final newMethods = responseData.map((method) {
          return {
            'id': '${method['carrier_code']}_${method['method_code']}', // A unique ID
            'price_str': '₹${(method['amount'] as num).toStringAsFixed(2)}',
            'price_val': (method['amount'] as num).toDouble(),
            'title': method['method_title'], // Use method_title for the main title
            'carrier': method['carrier_title'], // Use carrier_title for the carrier
            'carrier_code': method['carrier_code'],
            'method_code': method['method_code'],
          };
        }).toList();

        // Update the state to display the new methods
        setState(() {
          _displayableShippingMethods = newMethods;

          // Automatically select the first method by default
          if (_displayableShippingMethods.isNotEmpty) {
            final firstMethod = _displayableShippingMethods.first;
            _selectedShippingMethodIndex = 0; // Assuming the first item corresponds to index 0
            currentShippingCost = firstMethod['price_val'];
            selectedShippingMethodName = firstMethod['title'];
            carrierCode = firstMethod['carrier_code'];
            methodCode = firstMethod['method_code'];
          }
        });

      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching shipping methods: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      // Hide loading indicator
      // setState(() { _isFetchingRates = false; });
    }
  }
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




  // ✅ REPLACE THIS ENTIRE METHOD

  Future<void> _loadShippingPreferencesForCheckout() async {
    if (!mounted) return;
    setState(() {
      _isLoadingShippingPrefs = true;
    });

    // ... (all the country and region loading logic remains the same) ...
    // ... (I'm skipping it here for brevity, no changes are needed in that part) ...

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
      print("finalSelectedCountryId$finalSelectedCountryId");
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


    // --- ✅ FIX: Shipping method preference loading logic ---
    double loadedShippingCost = 0.0;
    String loadedShippingMethodName = '';
    String? loadedSelectedShippingId; // Use a nullable String for the ID
    String loadedCarrierCode = '';
    String loadedMethodCode = '';

    if (shippingMethodNameFromPrefs != null && shippingPriceFromPrefs != null && _displayableShippingMethods.isNotEmpty) {
      int foundIndex = -1;
      if (carrierCodeFromPrefs != null && methodCodeFromPrefs != null) {
        final targetId = '${carrierCodeFromPrefs}_${methodCodeFromPrefs}';
        foundIndex = _displayableShippingMethods.indexWhere((m) => m['id'] == targetId);
      }
      // Fallback to name if ID match fails
      if (foundIndex == -1) {
        foundIndex = _displayableShippingMethods.indexWhere((m) => m['title'] == shippingMethodNameFromPrefs);
      }

      if (foundIndex != -1) {
        final matchedMethod = _displayableShippingMethods[foundIndex];
        loadedShippingCost = shippingPriceFromPrefs;
        loadedShippingMethodName = matchedMethod['title'] as String;
        loadedSelectedShippingId = matchedMethod['id'] as String; // Store the String ID
        loadedCarrierCode = matchedMethod['carrier_code'] as String;
        loadedMethodCode = matchedMethod['method_code'] as String;
        if (kDebugMode) print("Shipping method from prefs matched: $loadedShippingMethodName, ID: $loadedSelectedShippingId");
      } else {
        // This block runs if the saved method isn't found in the current list
        if (kDebugMode) print("Shipping method from prefs ('$shippingMethodNameFromPrefs') not found. Defaulting.");
        final defaultMethod = _displayableShippingMethods.first;
        loadedShippingCost = defaultMethod['price_val'] as double;
        loadedShippingMethodName = defaultMethod['title'] as String;
        loadedSelectedShippingId = defaultMethod['id'] as String; // Store the String ID
        loadedCarrierCode = defaultMethod['carrier_code'] as String;
        loadedMethodCode = defaultMethod['method_code'] as String;
      }
    } else if (_displayableShippingMethods.isNotEmpty) {
      // This block runs if there are no saved prefs at all
      final defaultMethod = _displayableShippingMethods.first;
      loadedShippingCost = defaultMethod['price_val'] as double;
      loadedShippingMethodName = defaultMethod['title'] as String;
      loadedSelectedShippingId = defaultMethod['id'] as String; // Store the String ID
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
      _selectedShippingMethodId = loadedSelectedShippingId; // Set the final state variable
      carrierCode = loadedCarrierCode;
      methodCode = loadedMethodCode;

      _isLoadingShippingPrefs = false;

      if (kDebugMode) {
        print("--- setState COMPLETE (Prefs Loading) ---");
        print("Final _selectedShippingMethodId: $_selectedShippingMethodId");
      }

      if (selectedCountryId.isNotEmpty) {
        // This call to estimate a single rate is now less critical since we
        // fetch the whole list, but we can leave it for now.
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
  // MODIFIED: This method now handles the UI updates synchronously
  // and then calls an async helper to fetch data.
  // ✅ REPLACE your _onCountryChanged method

  // ✅ REPLACE your _onCountryChanged method with this clean version

  void _onCountryChanged(String? newCountryName) {
    if (newCountryName == null || newCountryName == _selectedCountry) return;

    Country? newSelectedApiCountry;
    try {
      newSelectedApiCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == newCountryName);
    } catch (e) {
      if (kDebugMode) print("Error: Selected country '$newCountryName' not found in API list.");
      return;
    }

    // Set the loading state immediately for a responsive UI
    setState(() {
      _selectedApiCountryObject = newSelectedApiCountry;
      _selectedCountry = newSelectedApiCountry!.fullNameEnglish;
      selectedCountryName = newSelectedApiCountry.fullNameEnglish;
      selectedCountryId = newSelectedApiCountry.id;
      _currentStates = newSelectedApiCountry.regions.map((r) => r.name).toList();
      _selectedState = null;
      selectedRegionName = '';
      selectedRegionId = '';

      // Clear old data and turn on the loading flag
      _displayableShippingMethods = [];
      _selectedShippingMethodId = null;
      _isFetchingShippingMethods = true;
    });

    // Call the single coordinator function to handle both API calls in sequence.
    _fetchAndCombineShippingMethods(selectedCountryId);
  }

  // ✅ REPLACE your _fetchAvailableShippingMethodsOnCountryChange method

  Future<void> _fetchAvailableShippingMethodsOnCountryChange(String countryId) async {  if (countryId.isEmpty) {
    if (kDebugMode) print("Skipping shipping method fetch: Country ID is empty.");
    return;
  }

  // Optional: You could show a loading indicator here
  setState(() {
    // e.g., _isFetchingMethods = true;
  });

  if (kDebugMode) {
    print("--- Fetching available shipping methods on country change ---");
  }

  try {
    // --- 2. Get Auth Token ---
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in. Cannot fetch shipping methods.");
    }

    // --- 3. Build the Payload with Placeholders ---
    // NOTE: We are using placeholder data because most of these fields are
    // empty when only the country has been selected. This may lead to the
    // API returning no methods.
    final payload = {
      "address": {
        "country_id": countryId,
        // --- Placeholders for required fields ---
        "region_id": 0, // Sending 0 as we don't have a region yet
        "region": "",
        "region_code": "",
        "postcode": "00000",   // Placeholder postcode
        "city": "Placeholder", // Placeholder city
        "street": ["Placeholder Street"],
        "firstname": _firstNameController.text.isNotEmpty ? _firstNameController.text : "Guest",
        "lastname": _lastNameController.text.isNotEmpty ? _lastNameController.text : "User",
        "telephone": _phoneController.text.isNotEmpty ? _phoneController.text : "9999999999",
      }
    };

    if (kDebugMode) {
      print("Request Payload for methods: ${json.encode(payload)}");
    }

    // --- 4. Make the API Call ---
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.post(
      Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
      body: json.encode(payload),
    );


    if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // If the API returns one or more methods...
        if (responseData.isNotEmpty) {
          final newMethods = responseData.map((method) {
            return {
              'id': '${method['carrier_code']}_${method['method_code']}',
              'price_str': '₹${(method['amount'] as num).toStringAsFixed(2)}',
              'price_val': (method['amount'] as num).toDouble(),
              'title': method['method_title'],
              'carrier': method['carrier_title'],
              'carrier_code': method['carrier_code'],
              'method_code': method['method_code'],
              'is_api_updatable': false,
            };
          }).toList();

          // ✅ FIX: Update state with the new list from the API
          setState(() {
            _displayableShippingMethods = newMethods;
            // Select the first returned method by default
            final firstMethod = _displayableShippingMethods.first;
            _selectedShippingMethodId = firstMethod['id'] as String;
            currentShippingCost = firstMethod['price_val'] as double;
            selectedShippingMethodName = firstMethod['title'] as String;
            carrierCode = firstMethod['carrier_code'] as String;
            methodCode = firstMethod['method_code'] as String;
            _isFetchingShippingMethods = false; // Turn off loading
          });
        } else {
          // ✅ FIX: Handle the case where the API returns an empty list []
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No shipping methods available for this country. Please select a State/Region.")),
            );
          }
          setState(() {
            // You can leave the list empty or fall back to the template if you want
            _displayableShippingMethods = [];
            _selectedShippingMethodId = null;
            _isFetchingShippingMethods = false; // Turn off loading
          });
        }
      } else {
        // Handle API error
        throw Exception("Failed to fetch shipping methods.");
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching shipping methods: $e");
      // ✅ FIX: Handle exceptions by turning off loading
      setState(() {
        _displayableShippingMethods = [];
        _selectedShippingMethodId = null;
        _isFetchingShippingMethods = false;
      });
    }
  }





  Future<void> _fetchAndCombineShippingMethods(String countryId) async {
    List<Map<String, dynamic>> availableMethods = [];
    double currentWeight = 0.0; // Variable to hold the freshly fetched weight

    // --- NEW STEP: Fetch the latest cart weight FIRST ---
    try {
      if (kDebugMode) print("Step 0: Fetching up-to-date cart weight...");
      final prefs = await SharedPreferences.getInstance();
      final cust_id = prefs.getInt('user_customer_id');
      if (cust_id != null) {
        currentWeight = await fetchCartTotalWeight(cust_id);
        if(mounted) {
          setState(() {
            // Also update the state variable so the whole class is in sync
            _cartTotalWeight = currentWeight;
          });
        }
        if (kDebugMode) print("Successfully fetched weight: $currentWeight");
      } else {
        if (kDebugMode) print("Could not fetch weight: Customer ID not found.");
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching cart weight: $e. Using last known weight: $_cartTotalWeight");
      currentWeight = _cartTotalWeight; // Fallback to the existing weight on error
    }


    // --- Call 1: Get the list of all available methods ---
    try {
      if (kDebugMode) print("Step 1: Fetching list of all available methods...");
      availableMethods = await _fetchAvailableMethodsList(countryId);
    } catch (e) {
      if (kDebugMode) print("Error fetching methods list: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not fetch shipping options: $e"), backgroundColor: Colors.red),
        );
      }
      setState(() { /* ... stop loading and show empty list ... */ });
      return;
    }

    if (availableMethods.isEmpty) {
      if (kDebugMode) print("No methods returned from the list API. Finalizing state.");
      setState(() { /* ... stop loading and show empty list ... */ });
      return;
    }

    // --- Call 2: Get the specific DHL rate using the Repository with the NEW weight ---
    try {
      if (kDebugMode) print("Step 2: Fetching specific rate via Repository with weight: $currentWeight");
      // ✅ Use the freshly fetched `currentWeight` variable here
      _shippingBloc.add(EstimateShipping(countryId, currentWeight));
    } catch (e) {
      if (kDebugMode) print("Error triggering specific rate fetch: $e");
    }

    // --- Final Step: Update the UI with the initial list ---
    if (kDebugMode) print("Step 3: Setting initial state with the fetched list...");
    setState(() {
      _displayableShippingMethods = availableMethods;
      _selectedShippingMethodId = availableMethods.first['id'] as String;
      final firstMethod = availableMethods.first;
      currentShippingCost = firstMethod['price_val'] as double;
      selectedShippingMethodName = firstMethod['title'] as String;
      carrierCode = firstMethod['carrier_code'] as String;
      methodCode = firstMethod['method_code'] as String;
      _isFetchingShippingMethods = false;
    });
  }

  // ✅ RENAME AND MODIFY this method. It now RETURNS the list.

// ✅ REPLACE your existing _fetchAvailableMethodsList method with this corrected version

  Future<List<Map<String, dynamic>>> _fetchAvailableMethodsList(String countryId) async {
    // ... (setup code for token, payload, client is the same) ...
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in.");
    }

    // NOTE: You may need to provide more real data here if the API requires it
    // for certain countries.
    final payload = {
      "address": {
        "country_id": countryId,
        "region_id": 0,
        "region": "",
        "region_code": "",
        "postcode": "00000",
        "city": "Placeholder",
        "street": ["Placeholder Street"],
        "firstname": _firstNameController.text.isNotEmpty ? _firstNameController.text : "Guest",
        "lastname": _lastNameController.text.isNotEmpty ? _lastNameController.text : "User",
        "telephone": _phoneController.text.isNotEmpty ? _phoneController.text : "9999999999",
      }
    };

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    final response = await ioClient.post(
      Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods'),
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $customerToken' },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((method) {
        final carrierCode = method['carrier_code'] as String? ?? '';
        final methodTitle = method['method_title'] as String? ?? '';
        print("carr>>$carrierCode");

        // ✅ FIX: Make the check more flexible.
        // We will flag the method as updatable if its carrier code is 'dhl' OR
        // if its method title is 'DHL'. This handles the 'tablerate' case.
        final bool isUpdatable = (carrierCode == 'dhl' || methodTitle == 'DHL');

        if(kDebugMode && isUpdatable) {
          print("Flagging method '${methodTitle}' (${carrierCode}) as updatable.");
        }

        return {
          'id': '${carrierCode}_${method['method_code']}',
          'price_str': '₹${(method['amount'] as num).toStringAsFixed(2)}',
          'price_val': (method['amount'] as num).toDouble(),
          'title': methodTitle,
          'carrier': method['carrier_title'],
          'carrier_code': carrierCode,
          'method_code': method['method_code'],
          'is_api_updatable': isUpdatable, // Use the result of our flexible check
        };
      }).toList();
    } else {
      throw Exception("Failed to fetch methods list: ${response.body}");
    }
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
  @override
  // ✅ REPLACE your existing build method with this one

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _shippingBloc,
      child: BlocListener<ShippingBloc, ShippingState>(
        listener: (context, state) {
          if (!mounted) return;

          // --- All your existing state handling remains ---
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

          // This now handles errors from BOTH shipping and payment submissions
          else if (state is ShippingError) {
            // If you want to show specific messages for specific errors, you can check state.message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }

          else if (state is ShippingRateLoading) {
            if (kDebugMode) print("Shipping rate is loading (event from BLoC)...");
          }

          else if (state is ShippingRateLoaded) {
            if (kDebugMode) {
              print("Received specific rate from Repository: ${state.shippingPrice}");
            }
            setState(() {
              int updatableMethodIndex = _displayableShippingMethods
                  .indexWhere((m) => m['is_api_updatable'] == true);

              if (updatableMethodIndex != -1) {
                if (kDebugMode) {
                  print("Found updatable method at index $updatableMethodIndex. Updating its price.");
                }
                _displayableShippingMethods[updatableMethodIndex]['price_val'] = state.shippingPrice;
                _displayableShippingMethods[updatableMethodIndex]['price_str'] = '₹${state.shippingPrice.toStringAsFixed(2)}';

                final updatableMethodId = _displayableShippingMethods[updatableMethodIndex]['id'];
                if (_selectedShippingMethodId == updatableMethodId) {
                  if (kDebugMode) {
                    print("The updated method is currently selected. Updating currentShippingCost to ${state.shippingPrice}");
                  }
                  currentShippingCost = state.shippingPrice;
                }
              } else {
                if (kDebugMode) {
                  print("No method flagged as 'is_api_updatable' found in the list. Cannot update price.");
                }
              }
            });
          }

          // --- ✅ START: ADD THIS NEW NAVIGATION LOGIC ---
          // This case will be triggered when the shipping information is successfully submitted.
          else if (state is ShippingInfoSubmittedSuccessfully) {
            if (kDebugMode) {
              print("Shipping Info submitted successfully. Navigating to PaymentScreen...");
            }
            // Navigate to the new PaymentScreen, passing the data it needs.
            Navigator.push(
              context,
              MaterialPageRoute(
                // You must provide the ShippingBloc to the new screen
                // so it can listen for payment events.
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
          // --- ✅ END: ADD THIS NEW NAVIGATION LOGIC ---

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
              _selectedState = newRegionName;
              selectedRegionName = newRegionName;
              selectedRegionCode=newRegionName;
              Region? selectedRegionObject;
              if (_selectedApiCountryObject != null) {
                try {
                  selectedRegionObject = _selectedApiCountryObject!.regions.firstWhere((r) => r.name == newRegionName);
                  selectedRegionId = selectedRegionObject.id;
                  selectedRegionCode=selectedRegionObject.code;
                } catch (e) {
                  selectedRegionId = '';
                  if (kDebugMode) print("Error: Selected region name '$newRegionName' not found in regions of '${_selectedApiCountryObject!.fullNameEnglish}'.");
                  selectedRegionObject = null;
                }
              }


              setState(() {
                _selectedState = newRegionName; // For the dropdown UI

                if (selectedRegionObject != null) {
                  // ✅ Store all three required pieces of information
                  selectedRegionName = selectedRegionObject.name;
                  selectedRegionId = selectedRegionObject.id;
                  selectedRegionCode = selectedRegionObject.code; // The missing piece!
                } else {
                  // Reset if the region can't be found
                  selectedRegionName = '';
                  selectedRegionId = '';
                  selectedRegionCode = '';
                }

                if (kDebugMode) {
                  print("Region selected: $selectedRegionName (ID: $selectedRegionId, Code: $selectedRegionCode)");
                }
              });


              // else {
              //   selectedRegionId = '';
              //   if (kDebugMode) print("Error: _selectedApiCountryObject is null. Cannot set region ID.");
              // }
              if (kDebugMode) print("Region selected: $selectedRegionName (ID: $selectedRegionId),Code: $selectedRegionCode)");
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
  // ✅ REPLACE THIS ENTIRE METHOD

  Future<void> _showShippingMethodSelectionDialog(BuildContext context) async {
    // Use a temporary string variable to hold the selection within the dialog
    String? tempSelectedShippingId = _selectedShippingMethodId;

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
                    return RadioListTile<String>( // Works with String
                      title: Text("${method['title']} (${method['carrier']})"),
                      subtitle: Text(method['price_str'] as String),
                      value: method['id'] as String, // Value is the String ID
                      groupValue: tempSelectedShippingId,
                      onChanged: (String? value) { // Receives a String value
                        if (value != null) {
                          stfSetState(() { // Update dialog's state
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
                      // Update the main screen's state
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


  // ✅ Full, Corrected _buildShippingMethodsSection Method

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

        // --- Start of Corrected Logic ---

        // 1. Show a loading indicator while fetching new methods
        if (_isFetchingShippingMethods)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text("Estimating shipping costs...")),
          )
        // 2. Show a message if fetching is complete but no methods are available
        else if (_displayableShippingMethods.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text("No shipping methods available. Please select a State/Region.")),
          )
        // 3. Display the shipping method table if we have data
        else ...[
                () {
              // This logic now runs safely after loading is complete and the list is populated.
              Map<String, dynamic>? determinedShippingMethod;
              if (_selectedShippingMethodId != null) {
                try {
                  determinedShippingMethod = _displayableShippingMethods.firstWhere(
                        (m) => m['id'] == _selectedShippingMethodId,
                  );
                } catch (e) {
                  if (kDebugMode) print("Error finding selected shipping method ID '$_selectedShippingMethodId'. $e");
                  // Fallback if ID is somehow invalid, though this is less likely now.
                  determinedShippingMethod = null;
                }
              }

              // If for any reason a method couldn't be determined, show a message.
              if (determinedShippingMethod == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: Text("Please select a shipping method.")),
                );
              }

              // Build and return the table with the determined method
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
                            onChanged: null, // Non-interactive in the table
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      _buildTableCell(
                        // Use the price from the method data itself for consistency
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

            // "NEXT" Button
            Align(
              alignment: Alignment.centerRight,
              child: BlocBuilder<ShippingBloc, ShippingState>(
                builder: (context, state) {
                  final isSubmitting = state is ShippingInfoSubmitting;
                  final determinedShippingMethod = _displayableShippingMethods.firstWhere(
                        (m) => m['id'] == _selectedShippingMethodId,
                    orElse: () => <String, dynamic>{}, // Provide an empty map as a fallback
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