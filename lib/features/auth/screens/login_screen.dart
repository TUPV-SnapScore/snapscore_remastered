import 'package:flutter/material.dart';
import 'package:snapscore/features/auth/screens/forgot_password_screen.dart';
import '../../../core/themes/colors.dart';
import '../widgets/login_form.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      weight: 700,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(0),
                  ),
                ),

                const SizedBox(height: 16),

                // Welcome Text
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 36,
                      ),
                ),

                const SizedBox(height: 16),

                // Welcome Image
                Image.asset(
                  'assets/images/login_welcome.png',
                  height: 200,
                ),

                const SizedBox(height: 24),

                // Login Form
                const LoginForm(),

                const SizedBox(height: 16),

                // Don't have an account text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),

                // Forgot Password
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot password',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue, fontWeight: FontWeight.w700),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
