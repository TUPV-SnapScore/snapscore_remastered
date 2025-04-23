import 'package:flutter/material.dart';
import 'package:snapscore/core/themes/colors.dart';
import 'package:snapscore/features/camera/widgets/camera.dart';
import 'package:snapscore/features/identification/models/identification_model.dart';
import 'package:snapscore/features/identification/services/identification_submission.dart';
import 'package:snapscore/features/identification/widgets/identification_form.dart';
import 'package:snapscore/features/identification_results/screens/identification_results_screen.dart';

class EditIdentificationScreen extends StatefulWidget {
  final String assessmentId;

  const EditIdentificationScreen({
    super.key,
    required this.assessmentId,
  });

  @override
  State<EditIdentificationScreen> createState() =>
      _EditIdentificationScreenState();
}

class _EditIdentificationScreenState extends State<EditIdentificationScreen> {
  final IdentificationService _identificationService = IdentificationService();
  final IdentificationFormController _formController =
      IdentificationFormController();
  bool _isLoading = true;
  IdentificationFormDataModel? _initialData;

  @override
  void initState() {
    super.initState();
    _loadAssessmentData();
  }

  Future<void> _loadAssessmentData() async {
    try {
      // Fetch assessment details
      final assessmentData =
          await _identificationService.getAssessment(widget.assessmentId);
      print('Assessment data: $assessmentData');

      if (mounted) {
        // Extract questions from the assessment data with null safety
        final questionsList =
            assessmentData['identificationQuestions'] as List<dynamic>? ?? [];

        final questions = questionsList.map((q) {
          // Add null checks and default values
          return IdentificationAnswerWithId(
            id: q['id'] ?? '',
            number: int.tryParse(q['question'] ?? '0') ?? 0,
            answer: q['correctAnswer'] ?? '',
          );
        }).toList();

        // Sort questions by number to ensure correct order
        questions.sort((a, b) => a.number.compareTo(b.number));

        setState(() {
          _initialData = IdentificationFormDataModel(
            assessmentId: widget.assessmentId,
            name: assessmentData['name'] ?? '',
            answers: questions,
          );
          _isLoading = false;
        });

        // For debugging
        print('Initial Data: ${_initialData?.name}');
        print('Number of answers: ${_initialData?.answers.length}');
        for (var answer in _initialData?.answers ?? []) {
          print('Question ${answer.number}: ${answer.answer}');
        }
      }
    } catch (e) {
      print('Error loading assessment data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load assessment data: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteAssessment() async {
    try {
      await _identificationService.deleteAssessment(widget.assessmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment deleted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error deleting assessment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete assessment')),
        );
      }
    }
  }

  Future<void> _handleSubmit(Map<String, dynamic> formData) async {
    try {
      // Update assessment name if changed
      if (_initialData!.name != formData['assessmentName']) {
        await _identificationService.updateAssessment(
          assessmentId: widget.assessmentId,
          assessmentName: formData['assessmentName'],
        );
      }

      // Update questions
      final answers = (formData['answers'] as List<IdentificationAnswer>);
      final initialAnswers = _initialData!.answers;

      for (int i = 0; i < answers.length; i++) {
        if (i < initialAnswers.length) {
          // Update existing question if answer changed
          if (answers[i].answer != initialAnswers[i].answer) {
            await _identificationService.updateQuestion(
              questionId: initialAnswers[i].id,
              answer: answers[i].answer,
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error updating assessment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update assessment')),
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
        title: const Text(
          'Edit Assessment',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.black, width: 1),
            ),
            color: Colors.white,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: _deleteAssessment,
                child: ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Delete Assessment',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: IdentificationForm(
                    controller: _formController,
                    onSubmit: _handleSubmit,
                    initialData: _initialData,
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
                        onPressed: () => _formController.submitForm?.call(),
                      ),
                      _BottomButton(
                        imagePath: "assets/icons/assessment_scan.png",
                        label: 'Scan',
                        onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Camera(
                                        assessmentId: widget.assessmentId,
                                        assessmentName: _initialData!.name,
                                      ))),
                        },
                      ),
                      _BottomButton(
                        imagePath: "assets/icons/assessment_results.png",
                        label: 'Results',
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IdentificationResultsScreen(
                                assessmentId: widget.assessmentId,
                                assessmentName: _initialData?.name ?? '',
                              ),
                            ),
                          )
                        },
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
