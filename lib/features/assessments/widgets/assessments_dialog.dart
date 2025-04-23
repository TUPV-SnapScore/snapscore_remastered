import 'package:flutter/material.dart';
import 'package:snapscore/features/essays/screens/new_essay_screen.dart';
import 'package:snapscore/features/identification/screens/identification_screen.dart';
import '../../../core/themes/colors.dart';

Future<bool> showAssessmentTypeDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.grey.withOpacity(0.2),
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Type of Assessment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Center(
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AssessmentTypeButton(
                        title: 'Identification',
                        iconPath: 'assets/images/assessment_test.png',
                        onTap: () async {
                          Navigator.pop(context); // Close dialog
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NewIdentificationScreen(),
                            ),
                          );
                          // Return true if a new assessment was created
                          if (result == true) {
                            Navigator.pop(context, true);
                          }
                        },
                      ),
                      const SizedBox(
                        width: 16,
                        height: 32,
                      ),
                      _AssessmentTypeButton(
                        title: 'Essay',
                        iconPath: 'assets/images/assessment_essay.png',
                        onTap: () async {
                          Navigator.pop(context); // Close dialog
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewEssayScreen(),
                            ),
                          );
                          // Return true if a new assessment was created
                          if (result == true) {
                            Navigator.pop(context, true);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return result ?? false;
}

class _AssessmentTypeButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const _AssessmentTypeButton({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150, // Increased width
        height: 160, // Fixed height for consistency
        padding: const EdgeInsets.all(20), // Increased padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            Image.asset(
              iconPath,
              height: 72, // Larger icon
              width: 72,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16), // More spacing
            Text(
              title,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14, // Larger text
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
