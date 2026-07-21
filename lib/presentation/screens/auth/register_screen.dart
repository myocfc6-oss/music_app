import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../global_widgets/custom_textfield.dart';
import '../../global_widgets/custom_button.dart';
import '../dashboard/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _errorText = null);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      setState(() => _errorText = 'Name is required');
      return;
    }
    if (email.isEmpty) {
      setState(() => _errorText = 'Email is required');
      return;
    }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorText = 'Enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorText = 'Password is required');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorText = 'Password must be at least 6 characters');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorText = 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Join Sonus',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to start listening',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  hintText: 'Full Name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Password',
                  controller: _passwordController,
                  isObscure: true,
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  isObscure: true,
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 8),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _signUp,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primaryNeon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
