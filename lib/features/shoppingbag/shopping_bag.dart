import 'package:aashni_app/bloc/login/login_screen_bloc.dart';
import 'package:aashni_app/features/auth/view/auth_screen.dart';
import 'package:aashni_app/features/auth/view/login_screen.dart';
import 'package:aashni_app/features/checkout/checkout_screen.dart';
import 'package:aashni_app/features/shoppingbag/repository/cart_repository.dart';
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
import 'package:http/io_client.dart';
import ' shipping_bloc/shipping_bloc.dart';
import ' shipping_bloc/shipping_event.dart';
import ' shipping_bloc/shipping_state.dart';
import '../../constants/user_preferences_helper.dart';
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
  int customer_id = 0;
  double _cartTotalWeight = 0.0;



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
  String countryCode= '';












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
  double totalCartWeight = 0.0;






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


  // In _ShoppingBagScreenState

// This function should be correct as is, but please double-check your implementation.

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

    // This part correctly uses the state variables `selectedCountryId` and `selectedRegionId`
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

      // *** ADD THIS LINE ***
      // After updating the weight, immediately estimate the shipping cost.
      // await _estimateShipping();
      _getShippingOptions();

    } else {
      print("Customer ID not found in SharedPreferences");
      if (!mounted) return;
      // Handle the case where the user is not logged in but we still need to clear shipping
      setState(() {
        _cartTotalWeight = 0.0;
      });
      // await _estimateShipping();
    _getShippingOptions();
      // Call estimate shipping to show "Please log in..." message
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
      throw Exception("Failed to fetch cart total weight: ${response.body}");
    }
  }

  void _saveShippingPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_country_name', selectedCountryName);
    await prefs.setString('selected_country_id', selectedCountryId);
    await prefs.setString('selected_region_name', selectedRegionName);
    await prefs.setString('selected_region_id', selectedRegionId);

    // Save the details of the SELECTED method
    if (selectedShippingMethod != null) {
      await prefs.setDouble('shipping_price', selectedShippingMethod!.amount);
      await prefs.setString('shipping_method_name', selectedShippingMethod!.displayName);
      await prefs.setString('carrier_code', selectedShippingMethod!.carrierCode); // ✅ CRITICAL
      await prefs.setString('method_code', selectedShippingMethod!.methodCode);   // ✅ CRITICAL
    } else {
      // Clear prefs if no method is selected
      await prefs.remove('shipping_price');
      await prefs.remove('shipping_method_name');
      await prefs.remove('carrier_code');
      await prefs.remove('method_code');
    }
    print("✅ Preferences Saved: Country='${selectedCountryName}', Region='${selectedRegionName}'");
  }


  // void _saveShippingPreferences() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('selected_country_name', selectedCountryName);
  //   await prefs.setString('selected_country_id', selectedCountryId);
  //   await prefs.setDouble('shipping_price', currentShippingCost);
  //   await prefs.setString('shipping_method_name', selectedShippingMethodName);
  //   await prefs.setString('selected_region_name', selectedRegionName);
  //   await prefs.setString('selected_region_id', selectedRegionId);
  //
  //
  //   print("Saved Shipping Preferences: cost=$currentShippingCost, name='$selectedShippingMethodName', carrier='$carrierCode', method='$methodCode',country_id='$countryCode'");
  // }




  @override
  void initState() {
    super.initState();
    _shippingBloc = context.read<ShippingBloc>();
    Future.microtask(() {
      context.read<CartBloc>().add(FetchCartItems());
    });
    context.read<ShippingBloc>().add(FetchCountries());

    _loadCustomerIdAndFetchWeight();
    // _loadUserNames().then((fetchedId) {
    //   customer_id = fetchedId; // ✅ Save to class variable
    //   fetchCartTotalWeight(customer_id); // ✅ Use it after it's set
    // });
    _initializeShoppingBagData();


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

    _initializeScreen();
    _initializeAsyncDependencies();
    // _loadShippingPreferences();


    // dio = Dio();
    // dio.interceptors.add(CookieManager(cookieJar));
    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
    //   client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };


    // fetchCartItems();
  }




// ✅ NEW orchestrating function
  Future<void> _initializeScreen() async {
    // First, determine the login state
    await _checkLoginStatus(); // A simplified function to get isLoggedIn status

    // Second, load the user's saved address
    await _loadShippingPreferences();

    // Third, get the cart weight for the logged-in user
    await _loadCustomerIdAndFetchWeight();

    // Any other init logic can go here
  }

// Helper to check login status
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
    });
  }

  Future<int> _loadUserNames() async { // Changed to return Future<int>
    final id = await UserPreferences.getCustomerId();
    int fetchedCustomerId = id ?? 0; // Use 0 if null or handle as needed


    print("cust>> initial class member customer_id: ${customer_id}"); // See initial value


    if (mounted) { // Good practice to check if widget is still in the tree
      setState(() {
        this.customer_id = fetchedCustomerId; // Update the state member
      });
    }


    print("cust====S (updated class member) ${this.customer_id}");
    print("cust====S (fetched directly) $fetchedCustomerId");
    return fetchedCustomerId; // Return the ID you just fetched
  }
  Future<double> loadCartWeight({required int currentCustomerId}) async {
    print("loadCartWeight called with customer_id: $currentCustomerId");


    if (currentCustomerId == 0) {
      print("loadCartWeight: customerId is 0, cannot fetch weight.");
      if (mounted) {
        setState(() {
          totalCartWeight = 0.0;
        });
      }
      return 0.0;
    }


    try {
      final repository = CartRepository();
      final weight = await repository.fetchCartTotalWeight(currentCustomerId);
      print('Total Weight: $weight for customer ID: $currentCustomerId');


      if (mounted) {
        setState(() {
          totalCartWeight = weight;
        });
      }


      return weight;
    } catch (e) {
      print('Error fetching cart weight:>> $e');


      if (mounted) {
        setState(() {
          totalCartWeight = 0.0;
        });
      }


      return 0.0;
    }
  }






  // New orchestrating method
  Future<void> _initializeShoppingBagData() async {
    int fetchedId = await _loadUserNames();


    if (fetchedId != 0) {
      double weight = await loadCartWeight(currentCustomerId: fetchedId);
      print("Updated cart weight from _initializeShoppingBagData: $weight");
    } else {
      print("User is likely a guest or ID not found, skipping cart weight load or handling as guest.");
      if (mounted) {
        setState(() {
          totalCartWeight = 0.0;
          isLoading = false;
        });
      }
    }
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


  // Future<double> fetchCartTotalWeight(int customerId) async {
  //   print("init fetchCartTotalWeightcalled>>");
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //
  //
  //   if (customerToken == null || customerToken.isEmpty) {
  //     throw Exception("User not logged in");
  //   }
  //   HttpClient httpClient = HttpClient();
  //   httpClient.badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //   final response = await ioClient.get(
  //     Uri.parse('https://stage.aashniandco.com/rest/V1/cart/details/$customerId'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //   );
  //
  //
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body) as List<dynamic>;
  //     if (data.isEmpty) {
  //       return 0.0;
  //     }
  //     final firstItem = data[0] as Map<String, dynamic>;
  //     final weightStr = firstItem['total_cart_weight'];
  //     final totalWeight = double.tryParse(weightStr.toString()) ?? 0.0;
  //     print("init fetchCartTotalWeightcalled>>$totalWeight");
  //     return totalWeight;
  //   } else {
  //     throw Exception("Failed to fetch cart total weight: ${response.body}");
  //   }
  // }


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


  // In _ShoppingBagScreenState


  // In _ShoppingBagScreenState

/////17 June
  // Future<void> _estimateShipping() async {
  //   if (!mounted) return;
  //   print("Before reset: currentShippingCost = $currentShippingCost, selectedShippingMethodName = '$selectedShippingMethodName'");
  //   setState(() {
  //     isShippingLoading = true;
  //     // Reset previous shipping info
  //     shippingPrice = 0.0;
  //     currentShippingCost = 0.0;
  //     selectedShippingMethodName = '';
  //     carrierCode = '';
  //     methodCode = '';
  //
  //
  //     print("After reset in setState: currentShippingCost = $currentShippingCost"); // Will print 0.0
  //     print("After reset in setState: selectedShippingMethodName = '$selectedShippingMethodName'"); // Will print ''
  //     print("After reset in setState: carrierCode = '$carrierCode'"); // Will print ''
  //     print("After reset in setState: methodCode = '$methodCode'");
  //   });
  //
  //
  //   final countryId = selectedCountryId;
  //   final String effectiveRegionId = selectedRegionId.isNotEmpty ? selectedRegionId : "0";
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //
  //
  //   // --- Login Check ---
  //   if (customerToken == null || customerToken.isEmpty) {
  //     if (mounted) {
  //       setState(() {
  //         isLoggedIn = false;
  //         isShippingLoading = false;
  //         selectedShippingMethodName = "Please log in to estimate shipping.";
  //       });
  //       _saveShippingPreferences();
  //     }
  //     return;
  //   }
  //   if (mounted) setState(() => isLoggedIn = true);
  //
  //
  //   // --- Cart Weight Check ---
  //   if (_cartTotalWeight <= 0) {
  //     if (mounted) {
  //       setState(() {
  //         isShippingLoading = false;
  //         selectedShippingMethodName = _cartTotalWeight == 0
  //             ? "Your cart is empty. Add items to estimate shipping."
  //             : "Cart weight unavailable. Cannot estimate shipping.";
  //       });
  //       _saveShippingPreferences();
  //     }
  //     return;
  //   }
  //
  //
  //   // --- Country Selection Check ---
  //   if (countryId.isEmpty) {
  //     if (mounted) {
  //       setState(() {
  //         isShippingLoading = false;
  //         selectedShippingMethodName = "Please select a country to estimate shipping.";
  //       });
  //       _saveShippingPreferences();
  //     }
  //     return;
  //   }
  //
  //
  //   // --- HTTP Client Setup ---
  //   HttpClient httpClient = HttpClient();
  //   httpClient.badCertificateCallback = (cert, host, port) => true; // For STAGING/DEV ONLY
  //   IOClient ioClient = IOClient(httpClient);
  //
  //
  //   // --- URI Construction ---
  //   // final String weightQueryParam = totalCartWeight.toStringAsFixed(2);
  //   final String weightQueryParam = _cartTotalWeight.toStringAsFixed(2);
  //   final uri = Uri.https(
  //     'stage.aashniandco.com',
  //     '/rest/V1/aashni/shipping-rate/$countryId/$effectiveRegionId',
  //     {'weight': weightQueryParam},
  //   );
  //   print("Requesting Shipping URL: $uri");
  //
  //
  //   // --- API Call and Response Handling ---
  //   try {
  //     final response = await ioClient.get(
  //       uri,
  //       headers: {
  //         'Authorization': 'Bearer $customerToken',
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //       },
  //     );
  //
  //
  //     if (!mounted) return;
  //
  //
  //     final dynamic rawData = jsonDecode(response.body);
  //     print("Shipping API Response Status: ${response.statusCode}");
  //     print("Shipping API Response Body: $rawData");
  //
  //
  //     if (response.statusCode == 200) {
  //       // **MODIFIED: PARSING AN ARRAY BASED ON YOUR LOGS**
  //       if (rawData is List && rawData.isNotEmpty) {
  //         bool success = false;
  //         // Safely check type and existence for success flag (index 0)
  //         if (rawData[0] is bool) {
  //           success = rawData[0];
  //         } else {
  //           // If first element isn't a bool, consider it an unexpected format
  //           print('Unexpected array format: First element not a boolean. Body: $rawData');
  //           setState(() {
  //             selectedShippingMethodName = "Error: Unexpected server response (S1).";
  //           });
  //           // Fall through to finally block
  //           return; // Exit early from try if format is critically wrong
  //         }
  //
  //
  //         if (success) {
  //           // Expecting price at index 1
  //           if (rawData.length >= 2) {
  //             final priceValue = rawData[1];
  //             // Expecting message at index 2 (optional)
  //             String apiMessage = (rawData.length >= 3 && rawData[2] is String)
  //                 ? rawData[2]
  //                 : "Shipping rate processed.";
  //
  //
  //             double parsedPrice = 0.0;
  //             if (priceValue != null) { // Price value from API could be null if no rate found
  //               if (priceValue is num) {
  //                 parsedPrice = priceValue.toDouble();
  //               } else if (priceValue is String) {
  //                 parsedPrice = double.tryParse(priceValue) ?? 0.0;
  //               } else {
  //                 print('Unexpected type for price value: ${priceValue.runtimeType}');
  //                 // Handle this case, maybe set price to 0 or show error
  //               }
  //             }
  //
  //
  //             setState(() {
  //               shippingPrice = parsedPrice;
  //               currentShippingCost = shippingPrice;
  //
  //
  //               if (currentShippingCost > 0) {
  //                 carrierCode = "tablerate"; // Default
  //                 methodCode = "bestway";   // Default
  //                 // Since we don't have a named method from the array, format it like this
  //                 selectedShippingMethodName = "Shipping Cost: ₹${currentShippingCost.toStringAsFixed(2)}";
  //                 // You could check apiMessage here if it contains "successfully" to be more confident
  //               } else { // Price is 0 or was null (no rate found)
  //                 carrierCode = "freeshipping"; // Default
  //                 methodCode = "freeshipping";  // Default
  //                 // Use the message from the API if available and seems relevant
  //                 if (priceValue == null && apiMessage.toLowerCase().contains("no shipping rate")) {
  //                   selectedShippingMethodName = apiMessage;
  //                 } else if (parsedPrice == 0 && priceValue != null) { // Explicitly 0 price
  //                   selectedShippingMethodName = "Standard Shipping (Free)";
  //                 } else {
  //                   selectedShippingMethodName = apiMessage; // Fallback to whatever message is there
  //                 }
  //               }
  //             });
  //           } else {
  //             // Success was true, but array didn't have enough elements for price
  //             print('Unexpected array format: Success true, but not enough elements. Body: $rawData');
  //             setState(() {
  //               selectedShippingMethodName = "Error: Unexpected server response (S2).";
  //             });
  //           }
  //         } else {
  //           // Success flag (rawData[0]) was false
  //           // Try to get error message from rawData[1] if it exists
  //           String errorMessage = "Shipping estimation failed.";
  //           if (rawData.length >= 2 && rawData[1] is String) {
  //             errorMessage = rawData[1];
  //           }
  //           print('API reported failure (from array): $errorMessage Body: $rawData');
  //           setState(() {
  //             shippingPrice = 0.0;
  //             currentShippingCost = 0.0;
  //             selectedShippingMethodName = errorMessage;
  //           });
  //         }
  //       } else {
  //         // API returned 200, but the body was not a List or was empty
  //         print('Failed to get shipping rate: Response was not a list or was empty. Body: $rawData');
  //         setState(() {
  //           shippingPrice = 0.0;
  //           currentShippingCost = 0.0;
  //           selectedShippingMethodName = "Error: Unexpected server response (S3).";
  //         });
  //       }
  //     } else {
  //       // HTTP error (e.g., 400, 401, 404, 500)
  //       String errorMessage = "Error (Status: ${response.statusCode}).";
  //       try {
  //         final errorData = jsonDecode(response.body);
  //         // Check if error response itself is an array like [false, "message"]
  //         if (errorData is List && errorData.length >= 2 && errorData[0] == false && errorData[1] is String) {
  //           errorMessage = errorData[1];
  //         } else if (errorData is Map && errorData.containsKey('message')) { // Keep for Magento's map-based errors
  //           errorMessage = errorData['message'];
  //         }
  //       } catch (_) { /* Ignore parsing error */ }
  //       print('HTTP Error fetching shipping rate: ${response.body}');
  //       setState(() {
  //         shippingPrice = 0.0;
  //         currentShippingCost = 0.0;
  //         selectedShippingMethodName = errorMessage;
  //       });
  //     }
  //   } catch (e, s) {
  //     if (!mounted) return;
  //     print('Exception during shipping estimation: $e');
  //     print('Stack trace: $s');
  //     setState(() {
  //       shippingPrice = 0.0;
  //       currentShippingCost = 0.0;
  //       selectedShippingMethodName = "An error occurred. Please try again.";
  //     });
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isShippingLoading = false;
  //       });
  //       _saveShippingPreferences();
  //     }
  //   }
  // }


// In _ShoppingBagScreenState

// ✅ ADD THIS NEW FUNCTION
  Future<void> _loadShippingPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load the saved country and region names/IDs
    final savedCountryName = prefs.getString('selected_country_name');
    final savedCountryId = prefs.getString('selected_country_id');
    final savedRegionName = prefs.getString('selected_region_name');
    final savedRegionId = prefs.getString('selected_region_id');

    // We only update the state if we found saved data.
    if (savedCountryName != null && savedCountryId != null) {
      print("✅ Preferences Loaded: Country='${savedCountryName}', Region='${savedRegionName ?? ''}'");

      // Use setState to update the UI with the loaded values
      setState(() {
        selectedCountryName = savedCountryName;
        selectedCountryId = savedCountryId;

        // Also load the region if it was saved
        selectedRegionName = savedRegionName ?? '';
        selectedRegionId = savedRegionId ?? '';
      });

      // IMPORTANT: After loading the preferences, we need to fetch the
      // corresponding shipping options for that saved address.
      _getShippingOptions();
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


  Widget _buildShippingMethodsList() {
    if (isShippingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Your backend logic only returns one method, so this will build one Radio button.
    // This UI is now flexible if you ever add more methods in the future.
    return Column(
      children: availableShippingMethods.map((method) {
        return RadioListTile<ShippingMethod>(
          title: Text(method.displayName), // e.g., "Shipping - DHL"
          subtitle: Text('₹${method.amount.toStringAsFixed(2)}'), // The price from the subtotal logic
          value: method,
          groupValue: selectedShippingMethod,
          onChanged: (ShippingMethod? value) {
            setState(() {
              selectedShippingMethod = value;
              currentShippingCost = value?.amount ?? 0.0;
            });
            _saveShippingPreferences(); // Save the user's choice
          },
        );
      }).toList(),
    );
  }

  @override
// 🔄 REPLACE YOUR ENTIRE build METHOD WITH THIS

  @override
  Widget build(BuildContext context) {
    // We wrap the screen in a BlocListener to handle state changes from the
    // ShippingBloc without cluttering the UI building logic.
    return BlocListener<ShippingBloc, ShippingState>(
      listener: (context, state) {
        // 🛑 REMOVE THE 'ShippingRateLoading' LISTENER.
        // We will handle the loading indicator manually.

        if (state is ShippingMethodsLoaded) {
          // ✅ This is correct. Update the list when data arrives.
          setState(() {
            isShippingLoading = false; // Turn off the manual loading indicator
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
          // ✅ This is also correct. Handle the error.
          setState(() {
            isShippingLoading = false; // Turn off the manual loading indicator
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
                  } else if (state is CartLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _cartTotalWeight != state.totalCartWeight) {
                        setState(() => _cartTotalWeight = state.totalCartWeight);
                        // Re-fetch shipping options when the cart weight changes
                        _getShippingOptions();
                      }
                    });
                    if (state.items.isEmpty) {
                      return const Center(child: Text("Your cart is empty."));
                    }
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
                  } else if (state is CartError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }
                  return const Center(child: Text("Welcome! Your cart is loading."));
                },
              ),
            ),
            // This is the bottom summary section
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
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
                            _buildShippingContainer(), // ✅ CLEAN: Call the helper method for the shipping UI
                            const SizedBox(height: 20),
                            _buildOrderSummary(cartState), // ✅ CLEAN: Call the helper method for the totals
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
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🔄 REPLACE your entire _buildShippingContainer method with this one.

  Widget _buildShippingContainer() {
    return BlocBuilder<ShippingBloc, ShippingState>(
      // We only need to build this UI when we have the list of countries.
      // The BLoC will keep the CountriesLoaded state even when other states are emitted.
      // A better approach would be to have states like ShippingState(countries: [], methods: [], isLoading: true)
      // but this will work with your current setup.
      buildWhen: (previous, current) => current is CountriesLoaded || current is ShippingInitial,
      builder: (context, shippingState) {

        // Get the list of countries from the state. If it's not ready, use an empty list.
        final List<Country> countries = (shippingState is CountriesLoaded) ? shippingState.countries : [];
        final List<String> countryNames = countries.map((c) => c.fullNameEnglish).toList();

        // Find the currently selected country object to get its regions
        Country? selectedCountryData;
        if (selectedCountryName.isNotEmpty) {
          try {
            selectedCountryData = countries.firstWhere((c) => c.fullNameEnglish == selectedCountryName);
          } catch (e) {
            // This can happen if the countries list reloads and the old selection is gone.
            // In a real app, you might want to reset selectedCountryName here.
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
                    // --- Country Dropdown ---
                    buildDropdown(
                      label: 'Select Country',
                      // If the selected name is empty, pass null to show the hint.
                      value: selectedCountryName.isEmpty ? null : selectedCountryName,
                      items: countryNames,
                      onChanged: (value) {
                        if (value != null) {
                          final Country country = countries.firstWhere((c) => c.fullNameEnglish == value);
                          setState(() {
                            // This is the correct way to update state.
                            selectedCountryName = country.fullNameEnglish;
                            selectedCountryId = country.id;

                            // Reset dependent fields
                            selectedRegionName = '';
                            selectedRegionId = '';
                            selectedShippingMethod = null;
                            availableShippingMethods = [];
                            currentShippingCost = 0.0;
                          });
                          // Fetch new options based on the new selection.
                          _getShippingOptions();
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- State/Region Dropdown ---
                    // It will only appear if a country is selected AND that country has regions.
                    if (selectedCountryData != null && selectedCountryData.regions.isNotEmpty)
                      buildDropdown(
                        label: 'Select State / Province',
                        // If the selected region is empty, pass null to show the hint.
                        value: selectedRegionName.isEmpty ? null : selectedRegionName,
                        items: selectedCountryData.regions.map((r) => r.name).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            // Find the region object within the already selected country data
                            final Region region = selectedCountryData!.regions.firstWhere((r) => r.name == value);
                            setState(() {
                              selectedRegionName = region.name;
                              selectedRegionId = region.id;

                              // Reset shipping when region changes
                              selectedShippingMethod = null;
                              availableShippingMethods = [];
                              currentShippingCost = 0.0;
                            });
                            _getShippingOptions();
                          }
                        },
                      ),
                    const SizedBox(height: 20),

                    // --- Shipping Methods List ---
                    // This is where the radio buttons will be displayed.
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

// THIS IS THE WIDGET YOU PROVIDED. IT'S PERFECT.


// These are just your existing UI widgets extracted for cleanliness
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
        // Inside your "PROCEED TO CHECKOUT" button's onPressed callback

          onPressed: () {
            _saveShippingPreferences(); // This is correct

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value( // ✅ USE BlocProvider.value
                  // Provide the existing bloc instance to the new screen
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

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shopping Bag'),
//         leading: IconButton(
//           icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => AuthScreen()),
//                   (Route<dynamic> route) => false,
//             );
//
//
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           // ... inside your build method ...
//
//           Expanded(
//
//             child: BlocBuilder<CartBloc, CartState>( // <-- Change to BlocBuilder
//               // The builder is for creating UI. Your existing code goes here.
//               builder: (context, state) {
//                 if (state is CartLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (state is CartLoaded) {
//                   // ✅ The state now contains the most up-to-date items AND weight.
//                   // You can now pass state.totalCartWeight to your shipping logic.
//                   final cartItems = state.items;
//
//                   // When you update cart items, the BLoC will emit a new CartLoaded state,
//                   // which will trigger this builder, automatically updating the shipping estimate.
//                   // You may need to update the _cartTotalWeight variable from this state.
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     if (mounted && _cartTotalWeight != state.totalCartWeight) {
//                       setState(() {
//                         _cartTotalWeight = state.totalCartWeight;
//                       });
//                       // Re-estimate shipping whenever the weight from the BLoC changes.
//                       // _estimateShipping();
//                       _getShippingOptions();
//                     }
//                   });
//
//
//                   if (cartItems.isEmpty) {
//                     return const Center(child: Text("Your cart is empty."));
//                   }
//
//                   return ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(12),
//                     itemCount: cartItems.length,
//                     itemBuilder: (context, index) {
//                       final item = cartItems[index];
//                       // The item['qty'] here will now be correctly updated on rebuild
//                       return CartItemWidget(
//                         key: ValueKey(item['item_id']),
//                         item: item,
//                         onAdd: () {
//                           context.read<CartBloc>().add(
//                             UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) + 1),
//                           );
//                         },
//                         onRemove: () {
//                           if ((item['qty'] ?? 1) > 1) {
//                             context.read<CartBloc>().add(
//                               UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) - 1),
//                             );
//                           }
//                         },
//                         onDelete: () {
//                           context.read<CartBloc>().add(RemoveCartItem(item['item_id']));
//                         },
//                       );
//                     },
//                   );
//                 } else if (state is CartError) {
//                   return Center(child: Text("Error: ${state.message}"));
//                 }
//                 return const Center(child: Text("Welcome! Your cart is loading.")); // Default case
//               },
//             ),
//           ),
//
// // ... rest of your UI,
//
//
//           // Wrap bottom container inside BlocBuilder and Flexible to make height dynamic
//           BlocBuilder<CartBloc, CartState>(
//             builder: (context, cartState) {
//               if (cartState is CartLoaded && cartState.items.isNotEmpty) {
//                 return Flexible(
//                   fit: FlexFit.loose,
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, -2),
//                         ),
//                       ],
//                     ),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Shipping estimate section
//                           BlocBuilder<ShippingBloc, ShippingState>(
//                             builder: (context, shippingState) {
//                               List<Country> countries = [];
//                               List<String> countryNames = [];
//
//
//                               if (shippingState is CountriesLoading) {
//                                 return const Center(child: CircularProgressIndicator());
//                               } else if (shippingState is ShippingError) {
//                                 return Text('Error loading countries: ${shippingState.message}');
//                               } else if (shippingState is CountriesLoaded) {
//                                 countries = shippingState.countries;
//                                 countryNames = countries.map((c) => c.fullNameEnglish).toList();
//
//
//                                 if (selectedCountryName.isEmpty && countries.isNotEmpty) {
//                                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                                     setState(() {
//                                       selectedCountryName = countries.first.fullNameEnglish;
//                                       selectedCountryId = countries.first.id;
//                                       print("selectedCountryId>>>>$selectedCountryId ");
//                                       if (selectedCountryId != null && selectedCountryId!.isNotEmpty && isLoggedIn && totalCartWeight > 0) { // Condition for weight > 0
//                                         print("BlocBuilder (CountriesLoaded): Dispatching EstimateShipping with countryId: $selectedCountryId, weight: $totalCartWeight");
//                                         _shippingBloc.add(
//                                           EstimateShipping(selectedCountryId!, totalCartWeight), // NEW: Positional arguments
//                                         );
//                                       } else {
//                                         // Handle cases where you can't dispatch
//                                         if (!isLoggedIn) {
//                                           print("BlocBuilder (CountriesLoaded): User not logged in. Not dispatching initial shipping estimate.");
//                                           if (mounted) setState(() => selectedShippingMethodName = "Please log in to estimate shipping.");
//                                         } else if (totalCartWeight <= 0) {
//                                           print("BlocBuilder (CountriesLoaded): Cart weight is 0 or less. Not dispatching initial shipping estimate.");
//                                           if (mounted) setState(() => selectedShippingMethodName = "Cart is empty or weight unavailable.");
//                                         } else {
//                                           print("BlocBuilder (CountriesLoaded): selectedCountryId is empty. Not dispatching.");
//                                         }
//                                       }
//
//                                     });
//                                     _shippingBloc.add(EstimateShipping(selectedCountryId!,totalCartWeight));
//                                   });
//                                 }
//                               }
//
//
//                               return Container(
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(16),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.1),
//                                       spreadRadius: 1,
//                                       blurRadius: 5,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // Fixed header
//                                     Container(
//                                       padding: const EdgeInsets.all(16),
//                                       decoration: const BoxDecoration(
//                                         color: Colors.black,
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(16),
//                                           topRight: Radius.circular(16),
//                                         ),
//                                       ),
//                                       child: const Text(
//                                         'Estimate Shipping',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//
//
//                                     // Scrollable content below header
//                                     SizedBox(
//                                       height: 300, // increased to accommodate state dropdown
//                                       child: SingleChildScrollView(
//                                         padding: const EdgeInsets.all(16),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             const Text(
//                                               'Enter your destination to get a shipping estimate.',
//                                               style: TextStyle(fontSize: 16, color: Colors.black87),
//                                             ),
//                                             const SizedBox(height: 20),
//                                             buildDropdown(
//                                               label: 'Select Country',
//                                               value: selectedCountryName,
//                                               items: countryNames, // Assuming this is populated correctly from ShippingBloc
//                                               onChanged: (value) {
//                                                 if (value != null && value != selectedCountryName) {
//                                                   Country? selected; // Use nullable type
//                                                   try {
//                                                     selected = countries.firstWhere( // Ensure 'countries' list is accessible and populated
//                                                           (c) => c.fullNameEnglish == value,
//                                                     );
//                                                   } catch (e) {
//                                                     print("Error finding country: $value. Error: $e");
//                                                     // Handle case where country might not be found, though orElse should prevent this if countries is not empty
//                                                     if (countries.isNotEmpty) {
//                                                       selected = countries.first; // Fallback, or handle error appropriately
//                                                     } else {
//                                                       // No countries loaded, cannot proceed
//                                                       return;
//                                                     }
//                                                   }
//
//
//
//
//                                                   setState(() {
//                                                     selectedCountryName = selected!.fullNameEnglish;
//                                                     selectedCountryId = selected.id;
//                                                     selectedRegionName = '';
//                                                     selectedRegionId = '';
//                                                     // Reset shipping method when country changes
//                                                     selectedShippingMethod = null;
//                                                     availableShippingMethods = [];
//                                                     currentShippingCost = 0.0;
//                                                     // selectedCountryName = selected!.fullNameEnglish; // Use null-aware operator if selected can be null
//                                                     // selectedCountryId = selected.id;
//                                                     //
//                                                     //
//                                                     // // Reset region and previous shipping estimate when country changes
//                                                     // selectedRegionName = '';
//                                                     // selectedRegionId = '';
//                                                     // selectedRegionCode = ''; // If you use this
//                                                     //
//                                                     //
//                                                     // // These are reset here and will be updated by _estimateShipping
//                                                     // currentShippingCost = 0.0;
//                                                     // shippingPrice = 0.0; // Also reset the base shippingPrice
//                                                     // selectedShippingMethodName = '';
//                                                     // carrierCode = '';
//                                                     // methodCode = '';
//                                                     // availableShippingMethods.clear(); // If you use this list
//                                                     // selectedShippingMethod = null;  // If you use this
//                                                   });
//
//
//                                                   if (selectedCountryId.isNotEmpty) {
//                                                     // Check login status (isLoggedIn should be managed correctly)
//                                                     // You might have a central way to check this or it's set in initState/estimateShipping
//                                                     if (isLoggedIn) { // Ensure 'isLoggedIn' is accurately reflecting user status
//                                                       _getShippingOptions();
//                                                       // _estimateShipping(); // Directly call, no .then() needed for setting method names here
//                                                     } else {
//                                                       // Clear shipping info if user is not logged in and changes country
//                                                       setState(() {
//                                                         selectedShippingMethodName = "Please log in to estimate shipping.";
//                                                       });
//                                                       ScaffoldMessenger.of(context).showSnackBar(
//                                                         const SnackBar(
//                                                           content: Text("Please log in to estimate shipping for this country."),
//                                                         ),
//                                                       );
//                                                     }
//                                                   }
//                                                 }
//                                               },
//                                             ),
//
//
//                                             const SizedBox(height: 20),
//
//
//                                             // State Dropdown (only show if regions exist)
//                                             // Ensure 'countries' list is accessible and populated before this check
//                                             if (selectedCountryName.isNotEmpty &&
//                                                 countries.any((c) => c.fullNameEnglish == selectedCountryName && c.regions.isNotEmpty))
//                                               buildDropdown(
//                                                 label: 'Select State / Province',
//                                                 value: selectedRegionName.isEmpty ? "" : selectedRegionName, // Handle empty string for placeholder
//                                                 items: countries
//                                                     .firstWhere((c) => c.fullNameEnglish == selectedCountryName)
//                                                     .regions
//                                                     .map((r) => r.name)
//                                                     .toList(),
//                                                 onChanged: (value) {
//                                                   if (value != null && selectedCountryName.isNotEmpty) {
//                                                     Region? region;
//                                                     try {
//                                                       final selectedCountryData = countries.firstWhere(
//                                                             (c) => c.fullNameEnglish == selectedCountryName,
//                                                       );
//                                                       region = selectedCountryData.regions.firstWhere(
//                                                             (r) => r.name == value,
//                                                       );
//                                                     } catch (e) {
//                                                       print("Error finding region: $value for country $selectedCountryName. Error: $e");
//                                                       // Handle error, maybe region list was empty or name didn't match
//                                                       return;
//                                                     }
//
//
//
//
//                                                     setState(() {
//                                                       selectedRegionName = region!.name; // Use null-aware operator
//                                                       selectedRegionId = region.id;
//                                                       selectedRegionCode = region.code; // If you use this
//
//
//                                                       // Reset shipping cost when region changes, before new estimation
//                                                       currentShippingCost = 0.0;
//                                                       shippingPrice = 0.0;
//                                                       selectedShippingMethodName = '';
//                                                       carrierCode = '';
//                                                       methodCode = '';
//                                                       // availableShippingMethods.clear();
//                                                       // selectedShippingMethod = null;
//                                                     });
//
//
//                                                     if (isLoggedIn) { // Ensure 'isLoggedIn' is accurately reflecting user status
//                                                       _getShippingOptions();
//                                                       // Directly call, no .then() needed for setting method names here
//                                                     } else {
//                                                       setState(() {
//                                                         selectedShippingMethodName = "Please log in to estimate shipping.";
//                                                       });
//                                                       ScaffoldMessenger.of(context).showSnackBar(
//                                                         const SnackBar(content: Text("Please log in to estimate shipping.")),
//                                                       );
//                                                     }
//                                                   }
//                                                 },
//                                               ),
//
//
//                                             const SizedBox(height: 20),
//
//
//                                             // Loading / Result Display
//                                             if (isShippingLoading)
//                                               const Center(
//                                                 child: Padding(
//                                                   padding: EdgeInsets.symmetric(vertical: 16.0),
//                                                   child: CircularProgressIndicator(),
//                                                 ),
//                                               )
//                                             // Check selectedShippingMethodName which is now set by _estimateShipping
//                                             else if (!isShippingLoading && selectedShippingMethodName.isNotEmpty)
//                                               Padding(
//                                                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                                                 child: Text(
//                                                   // currentShippingCost > 0 doesn't make sense if selectedShippingMethodName
//                                                   // already contains the price or is a message like "No shipping..."
//                                                   // The logic inside _estimateShipping should format selectedShippingMethodName appropriately.
//                                                   // For example, if price > 0, selectedShippingMethodName = "DHL: ₹10.00"
//                                                   // If no price, selectedShippingMethodName = "No shipping methods available."
//                                                   selectedShippingMethodName, // Display the message directly
//                                                   style: TextStyle(
//                                                     fontSize: 16,
//                                                     fontWeight: currentShippingCost > 0 ? FontWeight.w500 : FontWeight.normal, // Adjust style based on cost
//                                                     color: currentShippingCost > 0 ? Colors.black87 : Colors.grey.shade700, // Adjust color
//                                                   ),
//                                                 ),
//                                               )
//                                             // This condition might become redundant if selectedShippingMethodName covers all cases
//                                             // else if (!isShippingLoading && selectedCountryId.isNotEmpty && selectedShippingMethodName.isEmpty)
//                                             //   Padding(
//                                             //     padding: const EdgeInsets.symmetric(vertical: 16.0),
//                                             //     child: Text(
//                                             //       "No shipping methods available for $selectedCountryName.",
//                                             //       style: TextStyle(color: Colors.grey.shade700),
//                                             //     ),
//                                             //   )
//                                             else if (!isShippingLoading && selectedCountryId.isEmpty) // Only show if no country is selected yet
//                                                 Padding(
//                                                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                                                   child: Text(
//                                                     "Select a country to see shipping options.",
//                                                     style: TextStyle(color: Colors.grey.shade700),
//                                                   ),
//                                                 )
//                                               else // Fallback for any other unhandled UI state during non-loading
//                                                 Container(), // Or a more specific message if needed
//
//
//                                           ],
//                                         ),
//                                       ),
//                                     )
//                                     // SizedBox(
//                                     //   height: 220, // Adjust height as needed
//                                     //   child: SingleChildScrollView(
//                                     //     padding: const EdgeInsets.all(16),
//                                     //     child: Column(
//                                     //       crossAxisAlignment: CrossAxisAlignment.start,
//                                     //       children: [
//                                     //         const Text(
//                                     //           'Enter your destination to get a shipping estimate.',
//                                     //           style: TextStyle(fontSize: 16, color: Colors.black87),
//                                     //         ),
//                                     //         const SizedBox(height: 20),
//                                     //
//                                     //         buildDropdown(
//                                     //           label: 'Select Country',
//                                     //           value: selectedCountryName,
//                                     //           items: countryNames,
//                                     //           onChanged: (value) {
//                                     //             print("Dropdown changed: $value"); // Log when dropdown changes
//                                     //
//                                     //             if (value != null && value != selectedCountryName) {
//                                     //               print("It's working!"); // Log when value is different
//                                     //
//                                     //               setState(() {
//                                     //                 final selected = countries.firstWhere(
//                                     //                       (c) => c.fullNameEnglish == value,
//                                     //                   orElse: () => countries.first,
//                                     //                 );
//                                     //
//                                     //                 selectedCountryName = selected.fullNameEnglish;
//                                     //                 selectedCountryId = selected.id;
//                                     //                 currentShippingCost = 0.0;
//                                     //                 selectedShippingMethodName = "";
//                                     //               });
//                                     //
//                                     //
//                                     //               if (isLoggedIn) {
//                                     //                 _estimateShipping().then((_) {
//                                     //                   if (currentShippingCost > 0) {
//                                     //                     carrierCode = "tablerate";  // DHL
//                                     //                     methodCode = "bestway";
//                                     //                     selectedShippingMethodName = "DHL";
//                                     //                     print("Shipping Method: $selectedShippingMethodName");
//                                     //                   } else {
//                                     //                     carrierCode = "freeshipping";
//                                     //                     methodCode = "freeshipping";
//                                     //                     selectedShippingMethodName = "Standard Shipping (Free)";
//                                     //                     print("Shipping Method: $selectedShippingMethodName");
//                                     //                   }
//                                     //
//                                     //                   setState(() {}); // Rebuild UI to reflect shipping method name
//                                     //                 });
//                                     //               } else {
//                                     //                 ScaffoldMessenger.of(context).showSnackBar(
//                                     //                   const SnackBar(
//                                     //                     content: Text("Please log in to estimate shipping for this country."),
//                                     //                   ),
//                                     //                 );
//                                     //               }
//                                     //             }
//                                     //           },
//                                     //         ),
//                                     //
//                                     //         const SizedBox(height: 20),
//                                     //
//                                     //         if (isShippingLoading)
//                                     //           const Center(
//                                     //             child: Padding(
//                                     //               padding: EdgeInsets.symmetric(vertical: 16.0),
//                                     //               child: CircularProgressIndicator(),
//                                     //             ),
//                                     //           )
//                                     //         else if (!isShippingLoading && selectedShippingMethodName.isNotEmpty)
//                                     //           Padding(
//                                     //             padding: const EdgeInsets.symmetric(vertical: 16.0),
//                                     //             child: Text(
//                                     //               currentShippingCost > 0
//                                     //                   ? "$selectedShippingMethodName: ₹${currentShippingCost.toStringAsFixed(2)}"
//                                     //                   : selectedShippingMethodName,
//                                     //               style: const TextStyle(
//                                     //                 fontSize: 16,
//                                     //                 fontWeight: FontWeight.w500,
//                                     //                 color: Colors.black87,
//                                     //               ),
//                                     //             ),
//                                     //           )
//                                     //         else if (!isShippingLoading && selectedCountryId.isNotEmpty)
//                                     //             Padding(
//                                     //               padding: const EdgeInsets.symmetric(vertical: 16.0),
//                                     //               child: Text(
//                                     //                 "No shipping methods available for $selectedCountryName.",
//                                     //                 style: TextStyle(color: Colors.grey.shade700),
//                                     //               ),
//                                     //             )
//                                     //           else if (!isShippingLoading && selectedCountryId.isEmpty)
//                                     //               Padding(
//                                     //                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                                     //                 child: Text(
//                                     //                   "Select a country to see shipping options.",
//                                     //                   style: TextStyle(color: Colors.grey.shade700),
//                                     //                 ),
//                                     //               ),
//                                     //       ],
//                                     //     ),
//                                     //   ),
//                                     // )
//                                     ,
//                                   ],
//                                 ),
//                               );
//
//
//                             },
//                           ),
//
//
//                           const SizedBox(height: 20),
//
//
//                           // Order Summary Section
//                           BlocBuilder<CartBloc, CartState>(
//                             builder: (context, cartState) {
//                               if (cartState is CartLoaded) {
//                                 final cartItems = cartState.items;
//
//
//                                 double subtotal = 0.0;
//                                 for (var item in cartItems) {
//                                   final qty = item['qty'] ?? 1;
//                                   final price = double.tryParse(item['price'].toString()) ?? 0.0;
//                                   subtotal += price * qty;
//                                 }
//                                 final total = subtotal + currentShippingCost;
//
//
//                                 return Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.1),
//                                         blurRadius: 5,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           const Text('Subtotal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//                                           Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 12),
//                                       const Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text('Duties and Taxes', style: TextStyle(fontSize: 16, color: Colors.black87)),
//                                           Text('Incl.', style: TextStyle(fontSize: 16, color: Colors.black87)),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 12),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           const Text('Shipping (Shipping - DHL)', style: TextStyle(fontSize: 16)),
//                                           Text("₹${currentShippingCost.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 20),
//                                       const Divider(thickness: 1),
//                                       const SizedBox(height: 12),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           const Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                                           Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               } else {
//                                 return const SizedBox.shrink();
//                               }
//                             },
//                           ),
//
//
//                           const SizedBox(height: 20),
//
//
//                           // Coupon code section
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   decoration: InputDecoration(
//                                     hintText: 'Enter coupon code',
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: BorderSide(color: Colors.grey.shade300),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   // handle coupon apply
//                                 },
//                                 child: const Text("Apply"),
//                               ),
//                             ],
//                           ),
//
//
//                           const SizedBox(height: 20),
//
//
//                           // Checkout button
//                           Center(
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => CheckoutScreen()),
//
//
//                                 );
//
//
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.black,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.zero,
//                                 ),
//                                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                               ),
//                               child: const Text(
//                                 "PROCEED TO CHECKOUT",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               } else {
//                 return const SizedBox.shrink();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }






  // 🔄 REPLACE your entire buildDropdown method with this one

  Widget buildDropdown({
    required String label,
    required String? value, // ✅ FIX: Allow the value to be null
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
            // The value parameter here correctly handles a null value.
            value: value,
            // A hint is shown when the value is null.
            hint: Text('Please select an option'),
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
            isExpanded: true, // Ensures the dropdown fills the width
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

