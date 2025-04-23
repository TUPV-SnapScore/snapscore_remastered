import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../../features/auth/screens/register_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // Main content with flexible spacing
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // DeGrader text
                    Text(
                      'SnapScore',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 46,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle text
                    Text(
                      'Snap it. Score it.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary, fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    // Get Started button
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Powered by section at bottom
              Column(
                children: [
                  Text(
                    'Powered by:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Image.asset(
                      'assets/icons/openai.png',
                      width: 100,
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
