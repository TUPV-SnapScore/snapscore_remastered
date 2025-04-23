// forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../widgets/forgot_password_form.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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

                // Reset Password Text
                Text(
                  'Reset Password',
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

                // Forgot Password Form
                const ForgotPasswordForm(),

                const SizedBox(height: 16),

                // Remember your password text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
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
