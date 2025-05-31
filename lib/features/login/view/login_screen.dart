import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/view/auth_screen.dart';
import '../repository/login_repository.dart';
import '../model/login_model.dart';

class LoginScreen1 extends StatefulWidget {
  const LoginScreen1({super.key});

  @override
  State<LoginScreen1> createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool isLoggedIn = false;

  final LoginRepository _loginRepository =
  LoginRepository(baseUrl: 'https://stage.aashniandco.com');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> userLoggedInSuccessfully() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', true);
    if (mounted) {
      setState(() {
        isLoggedIn = true;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final request = MagentoLoginRequest(
        username: _email.text.trim(),
        password: _password.text.trim(),
      );

      try {
        await _loginRepository.login(request);
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('user_token');
        if (token != null && token.isNotEmpty) {
          userLoggedInSuccessfully();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => AuthScreen()),
                (Route<dynamic> route) => false,
          );
        } else {
          throw Exception('Failed to save token');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return '$label is required';
          if (isEmail &&
              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          if (label == "Password" && value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
      ),
    );
  }

  void _navigateToForgotPassword() {
    // TODO: Replace with your actual ForgotPasswordScreen navigation
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Forgot Password'),
        content: Text('This should navigate to ForgotPasswordScreen.'),
      ),
    );
  }

  void _navigateToCreateAccount() {
    // TODO: Replace with your actual CreateAccountScreen navigation
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Create Account'),
        content: Text('This should navigate to CreateAccountScreen.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              _buildField(label: "Email", controller: _email, isEmail: true),
              _buildField(label: "Password", controller: _password, obscureText: true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _navigateToForgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _loading ? null : _submitForm,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: _navigateToCreateAccount,
                    child: const Text(
                      "Create an Account",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
