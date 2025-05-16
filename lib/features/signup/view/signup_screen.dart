import 'package:flutter/material.dart';
import 'package:aashni_app/features/signup/repository/signup_repository.dart';
import '../model/signup_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _loading = false;

  // Create an instance of SignupRepository
  final SignupRepository _signupRepository = SignupRepository(baseUrl: 'https://stage.aashniandco.com');

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_password.text != _confirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      final request = MagentoSignupRequest(
        firstname: _firstName.text.trim(),
        lastname: _lastName.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      setState(() => _loading = true);
      try {
        // Call the signup method from the SignupRepository
        await _signupRepository.signup(request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e')),
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
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return '$label is required';
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          if ((label == "Password" || label == "Confirm Password") && value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(label: "First Name", controller: _firstName),
              _buildField(label: "Last Name", controller: _lastName),
              _buildField(label: "Email", controller: _email, isEmail: true),
              _buildField(label: "Password", controller: _password, obscureText: true),
              _buildField(label: "Confirm Password", controller: _confirmPassword, obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submitForm,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
