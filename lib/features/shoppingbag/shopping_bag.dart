import 'package:aashni_app/bloc/login/login_screen_bloc.dart';
import 'package:aashni_app/features/auth/view/login_screen.dart';
import 'package:flutter/material.dart';





class ShoppingBagScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping Bag"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "SIGN IN TO YOUR ACCOUNT TO ENABLE SYNC",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality for Sign In
                print("Sign In clicked");

                Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountScreen()));
              },
              child: Text("Sign In"),
            ),
            SizedBox(height: 10),
            // TextButton(
            //   onPressed: () {
            //     // Add functionality for checking out new items
            //     print("Check out New In clicked");
            //   },
            //   child: Text("Or check out New In"),
            // ),
          ],
        ),
      ),
    );
  }
}
