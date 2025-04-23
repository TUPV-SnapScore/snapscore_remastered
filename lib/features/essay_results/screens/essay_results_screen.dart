import 'package:flutter/material.dart';
import 'package:snapscore/core/themes/colors.dart';
import 'package:snapscore/features/essay_results/models/essay_results_model.dart';
import 'package:snapscore/features/essay_results/services/essay_results_service.dart';
import 'package:snapscore/features/essay_results/widgets/essay_results_list.dart';

class EssayResultsScreen extends StatefulWidget {
  final String assessmentId;
  final String essayTitle;

  const EssayResultsScreen({
    super.key,
    required this.assessmentId,
    required this.essayTitle,
  });

  @override
  State<EssayResultsScreen> createState() => _EssayResultsScreenState();
}

class _EssayResultsScreenState extends State<EssayResultsScreen> {
  final EssayResultsService _resultsService = EssayResultsService();
  String _searchQuery = '';
  List<EssayResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      print("load called");
      final results = await _resultsService.getResultsByAssessmentId(
        widget.assessmentId,
      );
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print(e);
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
          widget.essayTitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 4.0),
            child: Center(
              child: Text(
                'SnapScore',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Results',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StudentResultsList(
                    onRefresh: _loadResults,
                    results: _results,
                    searchQuery: _searchQuery,
                    onSearch: (query) => setState(() => _searchQuery = query),
                  ),
          ),
        ],
      ),
    );
  }
}
