import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapscore/core/providers/auth_provider.dart';
import 'package:snapscore/features/identification/models/identification_model.dart';
import 'package:snapscore/features/identification/screens/edit_identification_screen.dart';
import 'package:snapscore/features/identification/services/identification_submission.dart';
import '../../../core/themes/colors.dart';
import '../widgets/identification_form.dart';

class IdentificationFormData {
  final String assessmentName;
  final List<Map<String, dynamic>> answers;

  IdentificationFormData({
    required this.assessmentName,
    required this.answers,
  });
}

class NewIdentificationScreen extends StatefulWidget {
  const NewIdentificationScreen({super.key});

  @override
  State<NewIdentificationScreen> createState() =>
      _NewIdentificationScreenState();
}

class _NewIdentificationScreenState extends State<NewIdentificationScreen> {
  final _formController = IdentificationFormController();

  Future<void> _handleSave() async {
    try {
      _formController.submitForm?.call();
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment saved successfully!')),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assessment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleFormSubmit(Map<String, dynamic> data) async {
    try {
      final service = IdentificationService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final mongoDbUserId = authProvider.userId;

      // Debug print to see the structure
      print('Raw form data: $data');
      print('Raw answers type: ${data['answers'].runtimeType}');

      List<IdentificationAnswer> identificationAnswers;

      if (data['answers'] is List<Map<String, dynamic>>) {
        // If the answers are maps, convert them to IdentificationAnswer objects
        identificationAnswers = (data['answers'] as List<Map<String, dynamic>>)
            .map((answer) => IdentificationAnswer(
                  number: answer['number'] as int,
                  answer: answer['answer'] as String,
                ))
            .toList();
      } else if (data['answers'] is List<IdentificationAnswer>) {
        // If they're already IdentificationAnswer objects, use them directly
        identificationAnswers = data['answers'] as List<IdentificationAnswer>;
      } else {
        throw Exception(
            'Unexpected answers format: ${data['answers'].runtimeType}');
      }

      final result = await service.createAssessment(
        assessmentName: data['assessmentName'] as String,
        answers: identificationAnswers,
        userId: mongoDbUserId!,
      );

      if (result['error'] == true) {
        throw Exception(result['message']);
      }

      if (result['id'] == null) {
        throw Exception('Assessment ID not found');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment created successfully!')),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EditIdentificationScreen(
            assessmentId: result['id'],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assessment: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, true),
        ),
        centerTitle: true,
        title: const Text(
          'SnapScore',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Identification',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: IdentificationForm(
              controller: _formController,
              onSubmit: _handleFormSubmit,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BottomButton(
                  imagePath: "assets/icons/assessment_save.png",
                  label: 'Save',
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  const _BottomButton({
    required this.imagePath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
