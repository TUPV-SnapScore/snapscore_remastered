import 'package:flutter/material.dart';
import 'package:snapscore/core/themes/colors.dart';
import 'package:snapscore/features/camera/widgets/essay_camera.dart';
import 'package:snapscore/features/essay_results/screens/essay_results_screen.dart';
import 'package:snapscore/features/essays/models/essay_model.dart';
import 'package:snapscore/features/essays/services/essay_submission_service.dart';
import 'package:snapscore/features/essays/widgets/new_essay_form.dart';

class EditEssayScreen extends StatefulWidget {
  final String essayId;

  const EditEssayScreen({
    super.key,
    required this.essayId,
  });

  @override
  State<EditEssayScreen> createState() => _EditEssayScreenState();
}

class _EditEssayScreenState extends State<EditEssayScreen> {
  final EssayService _essayService = EssayService();
  final EssayFormController _formController = EssayFormController();
  bool _isLoading = true;
  EssayData? _initialData;

  @override
  void initState() {
    super.initState();
    _loadEssayData();
  }

  Future<void> _loadEssayData() async {
    try {
      final response = await _essayService.getEssay(widget.essayId);

      if (mounted) {
        setState(() {
          _initialData = EssayData.fromJson(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load essay data')),
        );
      }
    }
  }

  Future<void> _handleSubmit(Map<String, dynamic> formData) async {
    try {
      final essayData = EssayData.fromJson(formData);

      // Update essay title
      if (_initialData!.essayTitle != essayData.essayTitle) {
        await _essayService.updateEssay(
          essayId: widget.essayId,
          essayTitle: essayData.essayTitle,
        );
      }

      // Update questions
      for (int i = 0; i < essayData.questions.length; i++) {
        if (i < _initialData!.questions.length) {
          final questionId = _initialData!.questions[i].id;
          if (questionId != null &&
              essayData.questions[i].question !=
                  _initialData!.questions[i].question) {
            await _essayService.updateQuestion(
              questionId: questionId,
              questionText: essayData.questions[i].question,
            );
          }
        }
      }

      // Update criteria and their rubrics
      for (int i = 0; i < essayData.criteria.length; i++) {
        if (i < _initialData!.criteria.length) {
          final criteriaId = _initialData!.criteria[i].id;
          if (criteriaId != null &&
              (essayData.criteria[i].criteria !=
                      _initialData!.criteria[i].criteria ||
                  essayData.criteria[i].maxScore !=
                      _initialData!.criteria[i].maxScore)) {
            await _essayService.updateCriteria(
              criteriaId: criteriaId,
              criteriaText: essayData.criteria[i].criteria,
              maxScore: essayData.criteria[i].maxScore.toDouble(),
            );
          }

          // Update rubrics
          for (int j = 0; j < essayData.criteria[i].rubrics.length; j++) {
            if (j < _initialData!.criteria[i].rubrics.length) {
              final rubricId = _initialData!.criteria[i].rubrics[j].id;
              final newRubric = essayData.criteria[i].rubrics[j];

              if (rubricId != null &&
                  (newRubric.description !=
                          _initialData!.criteria[i].rubrics[j].description ||
                      newRubric.score !=
                          _initialData!.criteria[i].rubrics[j].score)) {
                await _essayService.updateRubric(
                  rubricId: rubricId,
                  description: newRubric.description,
                  score: newRubric.score,
                );
              }
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Essay updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating essay: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update essay: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteAssessment() async {
    try {
      await _essayService.deleteEssay(widget.essayId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Essay deleted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete essay: ${e.toString()}')),
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
          'SnapScore',
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
                const Center(
                  child: Text(
                    'Essay',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: NewEssayForm(
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
                                  builder: (context) => EssayCamera(
                                        assessmentId: widget.essayId,
                                        assessmentName:
                                            _initialData!.essayTitle,
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
                              builder: (context) => EssayResultsScreen(
                                assessmentId: widget.essayId,
                                essayTitle: _initialData!.essayTitle,
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
