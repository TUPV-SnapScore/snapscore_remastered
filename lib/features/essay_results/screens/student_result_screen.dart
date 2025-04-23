import 'package:flutter/material.dart';
import 'package:snapscore/features/essay_results/services/essay_results_service.dart';
import 'package:snapscore/features/identification_results/screens/student_paper_screen.dart';
import '../../../core/themes/colors.dart';
import '../models/essay_results_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EssayStudentResultScreen extends StatefulWidget {
  final EssayResult result;

  const EssayStudentResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<EssayStudentResultScreen> createState() =>
      _EssayStudentResultScreenState();
}

class _EssayStudentResultScreenState extends State<EssayStudentResultScreen> {
  late EssayQuestionResult _selectedQuestion;
  final String baseUrl = dotenv.get('API_URL');
  bool _isUpdating = false;
  final _essayService = EssayResultsService();

  @override
  void initState() {
    super.initState();
    _selectedQuestion = widget.result.questionResults.first;
  }

  // Calculate total score across all questions
  int calculateTotalScore(List<EssayQuestionResult> questionResults) {
    return questionResults.fold(0, (sum, question) {
      return sum +
          question.essayCriteriaResults
              .fold(0, (criteriaSum, criteria) => criteriaSum + criteria.score);
    });
  }

  Future<void> _updateCriteriaScore(String criteriaId, double newScore) async {
    if (_isUpdating) return;

    // Store old values for rollback if needed
    final oldScore = widget.result.score;
    final oldCriteriaScores = widget.result.questionResults
        .map((q) => Map.fromEntries(
            q.essayCriteriaResults.map((c) => MapEntry(c.id, c.score))))
        .toList();

    setState(() => _isUpdating = true);

    try {
      // First update the criteria score on the backend
      await _essayService.updateCriteriaScore(criteriaId, newScore.toInt());

      // Create a new list of question results with the updated score
      final updatedQuestionResults =
          widget.result.questionResults.map((question) {
        final updatedCriteriaResults =
            question.essayCriteriaResults.map((criteria) {
          if (criteria.id == criteriaId) {
            return EssayCriteriaResult(
              id: criteria.id,
              score: newScore.toInt(),
              criteriaId: criteria.criteriaId,
              questionResultId: criteria.questionResultId,
              criteria: criteria.criteria,
              createdAt: criteria.createdAt,
            );
          }
          return criteria;
        }).toList();

        return EssayQuestionResult(
          id: question.id,
          answer: question.answer,
          resultId: question.resultId,
          questionId: question.questionId,
          score: question.score,
          question: question.question,
          essayCriteriaResults: updatedCriteriaResults,
          createdAt: question.createdAt,
        );
      }).toList();

      // Calculate new total score with updated criteria
      final newTotalScore = calculateTotalScore(updatedQuestionResults);

      // Update the total score on the backend
      await _essayService.updateResult(widget.result.id, newTotalScore, null);

      if (!mounted) return;

      // Update both the criteria score and total score locally
      setState(() {
        widget.result.questionResults = updatedQuestionResults;
        widget.result.score = newTotalScore;
        _selectedQuestion = updatedQuestionResults.firstWhere(
          (q) => q.id == _selectedQuestion.id,
        );
      });
    } catch (e) {
      if (!mounted) return;

      // Rollback to old values if there's an error
      setState(() {
        widget.result.score = oldScore;
        for (var i = 0; i < widget.result.questionResults.length; i++) {
          for (var criteria
              in widget.result.questionResults[i].essayCriteriaResults) {
            criteria = EssayCriteriaResult(
              id: criteria.id,
              score: oldCriteriaScores[i][criteria.id] ?? criteria.score,
              criteriaId: criteria.criteriaId,
              questionResultId: criteria.questionResultId,
              criteria: criteria.criteria,
              createdAt: criteria.createdAt,
            );
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating score: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isUpdating = false);
    }
  }

  Widget _buildCriteriaScoreField(EssayCriteriaResult criteria) {
    final textEditingController = TextEditingController(
      text: criteria.score.toString(),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  '${criteria.criteria?.criteria ?? "Unknown Criteria"} (${criteria.criteria?.maxScore ?? 0})',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Score:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.grey),
                  controller: textEditingController,
                  enabled: !_isUpdating,
                  onSubmitted: (value) {
                    final newScore = double.tryParse(value);
                    if (newScore != null &&
                        newScore >= 0 &&
                        newScore <=
                            (criteria.criteria?.maxScore ?? double.infinity)) {
                      _updateCriteriaScore(criteria.id, newScore);
                    } else {
                      // Reset to original value if invalid input
                      textEditingController.text = criteria.score.toString();
                    }
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteResult() async {
    try {
      final result = await _essayService.deleteEssayResult(widget.result.id);
      if (result) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting result: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total score from the actual score property
    int totalScore = widget.result.score;

    // Calculate max possible score by summing up max scores from criteria
    int maxPossibleScore = _selectedQuestion.essayCriteriaResults
        .fold(0, (sum, criteria) => sum + (criteria.criteria?.maxScore ?? 0));

    // Rest of the build method remains the same...

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Results',
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
              side: BorderSide(color: Colors.black),
            ),
            color: Colors.white,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: _deleteResult,
                child: ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Delete Result',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Section
                    _buildSectionHeader('Student', 'rubric_item'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: TextEditingController(
                            text: widget.result.studentName),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (value) async {
                          try {
                            await _essayService.updateResult(
                                widget.result.id, null, value);
                            setState(() {
                              widget.result.studentName = value;
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Error updating student name: $e')),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Question Section
                    _buildSectionHeader('Question', 'rubric_item'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<EssayQuestionResult>(
                        value: _selectedQuestion,
                        isExpanded: true,
                        underline: Container(),
                        items: widget.result.questionResults.map((question) {
                          return DropdownMenuItem(
                            value: question,
                            child: Text(
                              question.question.question,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedQuestion = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Answer Section
                    _buildSectionHeader('Answer', 'rubric_item'),
                    const SizedBox(height: 8),
                    _buildInfoContainer(_selectedQuestion.answer),
                    const SizedBox(height: 24),

                    // Results Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Results', 'rubric_item'),
                        Row(
                          children: [
                            Text(
                              'Total Score: ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$totalScore/$maxPossibleScore',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Criteria Scores
                    ...(_selectedQuestion.essayCriteriaResults.map((criteria) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildCriteriaScoreField(criteria),
                      );
                    })),
                  ],
                ),
              ),
            ),
          ),
          if (widget.result.paperImage.isNotEmpty &&
              widget.result.paperImage != 'notfound.jpg')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentPaperScreen(
                            imageUrl: widget.result.paperImage),
                      ),
                    );
                  },
                  child: const Text(
                    'View Paper',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String iconName) {
    return Row(
      children: [
        Image.asset("assets/icons/$iconName.png"),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoContainer(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
