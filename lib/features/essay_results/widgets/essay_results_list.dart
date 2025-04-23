import 'package:flutter/material.dart';
import 'package:snapscore/core/themes/colors.dart';
import 'package:snapscore/features/essay_results/models/essay_results_model.dart';
import 'package:snapscore/features/essay_results/screens/student_result_screen.dart';

class StudentResultsList extends StatefulWidget {
  final List<EssayResult> results;
  final String searchQuery;
  final Function(String) onSearch;
  final Future<void> Function() onRefresh;

  const StudentResultsList({
    super.key,
    required this.results,
    required this.searchQuery,
    required this.onSearch,
    required this.onRefresh,
  });

  @override
  State<StudentResultsList> createState() => _StudentResultsListState();
}

class _StudentResultsListState extends State<StudentResultsList> {
  List<EssayResult> get filteredResults {
    if (widget.searchQuery.isEmpty) {
      return widget.results;
    }
    return widget.results
        .where((result) => result.studentName
            .toLowerCase()
            .contains(widget.searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _handleRefresh() async {
    await widget.onRefresh();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black),
            ),
            child: TextField(
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                hintText: 'Search students...',
                suffixIcon: const Icon(Icons.search),
                prefixIcon: Image.asset('assets/icons/student_icon.png',
                    width: 24, height: 24),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                final result = filteredResults[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                  child: ListTile(
                    leading: Image.asset('assets/icons/student_icon.png',
                        width: 24, height: 24),
                    title: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        result.studentName,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    trailing: SizedBox(
                      width: 50,
                      child: Text(
                        result.score.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    onTap: () async {
                      final pageResult = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EssayStudentResultScreen(result: result),
                        ),
                      );

                      if (pageResult == true) {
                        await _handleRefresh();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
