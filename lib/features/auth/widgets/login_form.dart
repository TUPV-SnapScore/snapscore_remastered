import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapscore/core/router/auth_wrapper.dart';
import 'package:snapscore/features/assessments/screens/assessments_screen.dart';
import '../../../core/themes/colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../helpers/api_service_helper.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Check if widget is still mounted before using context
      if (!mounted) return;

      final userId =
          Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception('Failed to get user ID');
      }

      // Make the API call
      final userData = await apiService.getUserByFirebaseId(userId: userId);

      authProvider.setUserId(userData['id']);

      // Navigate to the AssessmentScreen (without having a back button or something)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AssessmentScreen()),
        (route) =>
            false, // This predicate returning false removes all previous routes
      );
      // Successfully registered - AuthWrapper will handle navigation
    } catch (e) {
      setState(() => _isLoading = false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getErrorMessage(e.toString()),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final googleUserCredential = await authProvider.signInWithGoogle();

      // Check if sign in was cancelled
      if (googleUserCredential == null) {
        setState(() => _isLoading = false);
        return; // Exit early if sign-in was cancelled
      }

      final googleUser = googleUserCredential.user;
      if (googleUser != null && googleUser.email != null) {
        final apiService = ApiService();
        final userData = await apiService.googleSignIn(
          email: googleUser.email!,
          userId: googleUser.uid,
          fullName: googleUser.displayName ?? 'Google User',
        );

        authProvider.setUserId(userData['id']);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AssessmentScreen()),
          (route) =>
              false, // This predicate returning false removes all previous routes
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getErrorMessage(e.toString()),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No user found with this email.';
    } else if (error.contains('wrong-password')) {
      return 'Wrong password provided.';
    } else if (error.contains('invalid-email')) {
      return 'The email address is badly formatted.';
    } else if (error.contains('user-disabled')) {
      return 'This user account has been disabled.';
    }
    return 'An error occurred. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: AppColors.textPrimary,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: AppColors.textPrimary,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: AppColors.textPrimary,
                  width: 2.0,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: AppColors.textPrimary,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: AppColors.textPrimary,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: AppColors.textPrimary,
                  width: 2.0,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 4),

          // Google Sign In Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: IconButton(
              icon: Image.asset(
                'assets/icons/google.png',
                width: 64,
                height: 64,
              ),
              onPressed: _isLoading ? null : _handleGoogleSignIn,
            ),
          ),

          // Login Button
          SizedBox(
            width: 240,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Log In',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
