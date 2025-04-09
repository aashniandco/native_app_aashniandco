import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>(); // Key to manage form state
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // If all fields are valid
      print("Form is valid");
      print("First Name: ${_firstNameController.text}");
      print("Last Name: ${_lastNameController.text}");
      print("Email: ${_emailController.text}");
      print("Password: ${_passwordController.text}");
    } else {
      print("Form is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black), // Back button icon
    onPressed: () {
      Navigator.pop(context); // Navigates to the previous screen
    },
  ),
  title: const Text(
    'Signup', // Title text
    style: TextStyle(
      color: Colors.black, // Text color
      fontWeight: FontWeight.bold, // Bold font
    ),
  ),
  elevation: 0, // No shadow
  backgroundColor: Colors.white, // White background
  foregroundColor: Colors.black, 
     
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    print("Sign UP with Google clicked");
                  },
                  icon: Image.asset(
                    'assets/google_logo.png', // Replace with your Google logo asset
                    height: 24,
                    width: 24,
                  ),
                  label: const Text("Sign Up with Google",style: TextStyle(fontSize: 12),),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("or", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("First Name *", style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 70,
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      hintText: "First Name",hintStyle: TextStyle(fontSize: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "First name is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Last Name *", style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 70,
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      hintText: "Last Name" ,hintStyle: TextStyle(fontSize: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Last name is required";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email *", style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 70,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      hintText: "Enter Email",hintStyle: TextStyle(fontSize: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is required";
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Password *", style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                    height: 70,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      hintText: "Enter Password",hintStyle: TextStyle(fontSize: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters long";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Create Account", style: TextStyle(color: Colors.white,fontSize: 12)),
                ),

                  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have a account? ",style: TextStyle(fontSize: 12),),
                  GestureDetector(
                    onTap: () {
                      print("Sign Up clicked");

                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen ()));
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.redAccent,fontSize: 12),
                    ),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
