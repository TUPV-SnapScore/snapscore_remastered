import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../models/identification_results_model.dart';

class StudentResultsList extends StatefulWidget {
  final List<IdentificationResultModel> results;
  final Function(String) onStudentSelected;
  final Future<void> Function() onRefresh; // Add this line

  const StudentResultsList({
    super.key,
    required this.results,
    required this.onStudentSelected,
    required this.onRefresh, // Add this line
  });

  @override
  State<StudentResultsList> createState() => _StudentResultsListState();
}

class _StudentResultsListState extends State<StudentResultsList> {
  List<IdentificationResultModel> filteredResults = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredResults = widget.results;
    searchController.addListener(_filterResults);
  }

  void _filterResults() {
    setState(() {
      filteredResults = widget.results
          .where((result) => result.studentName
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _handleRefresh() async {
    await widget.onRefresh(); // Call the parent's refresh function
    setState(() {
      filteredResults = widget.results;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Results',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                suffixIcon: const Icon(Icons.search),
                prefixIcon: Image.asset('assets/icons/student_icon.png',
                    width: 24, height: 24),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'No students found',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _handleRefresh, // Use the new handler
                  child: ListView.builder(
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final result = filteredResults[index];
                      return InkWell(
                        onTap: () => widget.onStudentSelected(result.id),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset('assets/icons/student_icon.png',
                                      width: 24, height: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    result.studentName,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                result.scoreText,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
