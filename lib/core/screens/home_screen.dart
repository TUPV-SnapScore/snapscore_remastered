import 'package:flutter/material.dart';
import '../themes/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // App Title
              const Text(
                'SnapScore',
                style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),

              const SizedBox(height: 64),

              // Menu Items
              _MenuTile(
                title: 'Class',
                imagePath: 'assets/images/home_class.png',
                onTap: () {
                  // TODO: Add navigation
                },
              ),

              const SizedBox(height: 16),

              _MenuTile(
                title: 'Settings',
                imagePath: 'assets/images/home_settings.png',
                onTap: () {
                  // Handle settings tap
                },
              ),

              const SizedBox(height: 16),

              _MenuTile(
                title: 'Help',
                imagePath: 'assets/images/home_help.png',
                onTap: () {
                  // Handle help tap
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _MenuTile({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textPrimary,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 96,
              width: 128,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
