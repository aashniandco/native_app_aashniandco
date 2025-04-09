
import 'package:aashni_app/app/theme.dart';
import 'package:aashni_app/features/auth/view/auth_screen.dart';
import 'package:flutter/material.dart';
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aashni + Co',
      theme: AppTheme.lightTheme,
      home: AuthScreen(),
    );
  }
}




// import 'package:aashni_app/bloc/login/login_screen_bloc.dart';
// import 'package:aashni_app/features/accessories/accessories.dart';
// import 'package:aashni_app/features/auth/view/auth_screen.dart';
// import 'package:aashni_app/features/auth/view/signup_screen.dart';
// import 'package:aashni_app/features/categories/view/categories_screen.dart';
// import 'package:aashni_app/features/categories/view/menu_categories_screen.dart';
// import 'package:aashni_app/features/auth/view/auth_screen.dart';
// import 'package:aashni_app/panaroma.dart';
// import 'package:aashni_app/prac/count.dart';
// import 'package:flutter/material.dart';
// import 'package:aashni_app/features/auth/view/auth_screen.dart';
// import 'theme.dart';
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Aashni + Co',
//       theme: AppTheme.lightTheme,
//       home: AuthScreen(),
//        // No need for ambiguity now
//         // home: Counter(),
//         // home:PanoramaScreen()
//     );
//   }
// }