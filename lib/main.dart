// import 'package:aashni_app/bloc/text_change/state/text_bloc.dart';
// import 'package:aashni_app/constants/api_constants.dart';
// import 'package:aashni_app/constants/environment.dart';
// import 'package:aashni_app/features/designer/bloc/designers_bloc.dart';
// import 'package:aashni_app/features/newin/bloc/new_in_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'app/app.dart';
// import 'features/auth/bloc/home_screen_banner_bloc.dart';
// import 'features/newin/bloc/newin_products_bloc.dart';
// import 'features/shoppingbag/ shipping_bloc/shipping_bloc.dart';
// import 'features/shoppingbag/cart_bloc/cart_bloc.dart';
// import 'features/signup/bloc/signup_bloc.dart';
// import 'features/signup/repository/signup_repository.dart';
// import 'features/signup/view/signup_screen.dart';
//
// void main() {
//
//   ApiConstants.setEnvironment(Environment.stage);
//   runApp(
//     ProviderScope( // ✅ Wrap everything in ProviderScope for Riverpod
//       child: MultiBlocProvider(
//         providers: [
//           BlocProvider(create: (context) => TextBloc()),
//           BlocProvider(create: (context) => DesignersBloc()..add(FetchDesigners())),
//           BlocProvider(create: (context) => NewInBloc()),
//           BlocProvider(create: (context) => CartBloc()),
//           BlocProvider(create: (_) => ShippingBloc()),
//           BlocProvider(create: (_) => HomeScreenBannerBloc()),
//   BlocProvider(
//   create: (_) => SignupBloc(SignupRepository(baseUrl: 'https://stage.aashniandco.com')),
//   child: const SignupScreen(),
//   )
//
//
//   // BlocProvider(create: (context) => NewInProductsBloc(productRepository: productRepository, subcategory: subcategory)),
//           // BlocProvider(create: (_) => NewInBloc()),
//         ],
//         child: const MyApp(),
//       ),
//     ),
//   );
// }


import 'package:aashni_app/bloc/text_change/state/text_bloc.dart';
import 'package:aashni_app/constants/api_constants.dart';
import 'package:aashni_app/constants/environment.dart';
import 'package:aashni_app/features/designer/bloc/designers_bloc.dart';
import 'package:aashni_app/features/newin/bloc/new_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'app/app.dart';

// Import your repositories
import 'package:aashni_app/features/shoppingbag/repository/cart_repository.dart';
 // Make sure this path is correct

import 'features/auth/bloc/home_screen_banner_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/newin/bloc/newin_products_bloc.dart';
import 'features/shoppingbag/ shipping_bloc/shipping_bloc.dart';
import 'features/shoppingbag/cart_bloc/cart_bloc.dart';
import 'features/shoppingbag/cart_bloc/cart_event.dart'; // Import the event
import 'features/shoppingbag/repository/shipping_repository.dart';
import 'features/signup/bloc/signup_bloc.dart';
import 'features/signup/repository/signup_repository.dart';
import 'features/signup/view/signup_screen.dart';

void main() {
  ApiConstants.setEnvironment(Environment.stage);

  Stripe.publishableKey = 'pk_test_CjTXZoMy2Ax0gA2xZbf3F99u00fGR7Cnph';

  // --- 1. Create your repository instances here ---
  // These will be shared with any BLoC that needs them.
  final CartRepository cartRepository = CartRepository();
  final AuthRepository authRepository = AuthRepository();

  // final ShippingRepository shippingRepository = ShippingRepository(); // etc.

  runApp(
    ProviderScope( // For Riverpod
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => TextBloc()),
          BlocProvider(create: (context) => DesignersBloc()..add(FetchDesigners())),
          BlocProvider(create: (context) => NewInBloc()),

          // --- 2. Provide the repositories to the CartBloc ---
          BlocProvider(
            create: (context) => CartBloc(
              cartRepository: cartRepository, // Pass the instance
              authRepository: authRepository,
          // Pass the instance
            )..add(FetchCartItems()), // 3. (Recommended) Load initial cart data
          ),

          BlocProvider(create: (_) => ShippingBloc()),
          BlocProvider(create: (_) => HomeScreenBannerBloc()),
          BlocProvider(
            create: (_) => SignupBloc(SignupRepository(baseUrl: 'https://stage.aashniandco.com')),
            // 'child' inside BlocProvider is generally not recommended.
            // It's better to have the child widget be part of the main widget tree.
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}