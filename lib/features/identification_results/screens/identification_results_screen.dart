import 'package:flutter/material.dart';
import 'package:snapscore/features/identification_results/screens/student_results_screen.dart';
import 'package:snapscore/features/identification_results/services/identification_result_service.dart';
import 'package:snapscore/features/identification_results/widgets/identification_results_list.dart';
import '../../../core/themes/colors.dart';
import '../models/identification_results_model.dart';

class IdentificationResultsScreen extends StatefulWidget {
  final String assessmentId;
  final String assessmentName;

  const IdentificationResultsScreen({
    super.key,
    required this.assessmentId,
    required this.assessmentName,
  });

  @override
  State<IdentificationResultsScreen> createState() =>
      _IdentificationResultsScreenState();
}

class _IdentificationResultsScreenState
    extends State<IdentificationResultsScreen> {
  final IdentificationResultsService _service = IdentificationResultsService();
  bool _isLoading = true;
  List<IdentificationResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print("load called");

      final results =
          await _service.getResultsByAssessmentId(widget.assessmentId);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading results: $e')),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.assessmentName,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Text(
              'SnapScore',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 52,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StudentResultsList(
                    results: _results,
                    onStudentSelected: (String resultId) async {
                      final result =
                          _results.firstWhere((r) => r.id == resultId);
                      final pageResult = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentResultScreen(result: result),
                        ),
                      );

                      if (pageResult == true) {
                        _loadResults();
                      }
                    },
                    onRefresh: _loadResults, // Add this line
                  ),
          ),
        ],
      ),
    );
  }
}
