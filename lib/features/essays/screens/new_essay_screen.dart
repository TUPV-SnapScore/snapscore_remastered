import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapscore/core/providers/auth_provider.dart';
import 'package:snapscore/core/themes/colors.dart';
import 'package:snapscore/features/essays/models/essay_model.dart';
import 'package:snapscore/features/essays/screens/edit_essay_screen.dart';
import 'package:snapscore/features/essays/services/essay_submission_service.dart';
import 'package:snapscore/features/essays/widgets/new_essay_form.dart';

class NewEssayScreen extends StatefulWidget {
  const NewEssayScreen({super.key});

  @override
  State<NewEssayScreen> createState() => _NewEssayScreenState();
}

class _NewEssayScreenState extends State<NewEssayScreen> {
  final _formController = EssayFormController();
  final _essayService = EssayService();

  Future<void> _handleSave() async {
    try {
      _formController.submitForm?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Essay assessment saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving essay assessment: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleFormSubmit(Map<String, dynamic> data) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Extract data from the form submission
      final essayData = EssayData.fromJson(data);
      print(essayData.toJson());

      // Transform the data to match the new service structure
      final questions = essayData.questions
          .map((question) => EssayQuestion(
                question: question.question,
                essayCriteria: essayData.criteria
                    .map((criteria) => EssayCriteria(
                          criteria: criteria.criteria,
                          maxScore: criteria.maxScore,
                          rubrics: criteria.rubrics,
                        ))
                    .toList(),
              ))
          .toList();

      final result = await _essayService.createEssay(
        essayTitle: essayData.essayTitle,
        userId: userId,
        questions: questions,
      );

      print(questions);
      print(result);

      if (result['error'] == true) {
        throw Exception(result['message']);
      }

      if (result['id'] == null) {
        throw Exception('Essay ID not found in response');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Essay created successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EditEssayScreen(
              essayId: result['id'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating essay: ${e.toString()}')),
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
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textPrimary, weight: 700),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'SnapScore',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz,
                color: AppColors.textPrimary, weight: 700),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Essay',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: NewEssayForm(
              controller: _formController,
              onSubmit: _handleFormSubmit,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.textSecondary),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _BottomButton(
                    imagePath: "assets/icons/assessment_save.png",
                    label: 'Save',
                    onPressed: _handleSave,
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
            width: 100, // Fixed width for all buttons
            padding: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(height: 4), // Consistent spacing
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
