import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapscore/core/providers/auth_provider.dart';
import 'package:snapscore/features/assessments/models/assessment_model.dart';
import 'package:snapscore/features/assessments/services/assessments_service.dart';
import 'package:snapscore/features/essays/screens/edit_essay_screen.dart';
import 'package:snapscore/features/identification/screens/edit_identification_screen.dart';
import '../../../core/themes/colors.dart';

class AssessmentSearchWidget extends StatefulWidget {
  const AssessmentSearchWidget({super.key});

  @override
  State<AssessmentSearchWidget> createState() => AssessmentSearchWidgetState();
}

class AssessmentSearchWidgetState extends State<AssessmentSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final AssessmentsService _assessmentsService = AssessmentsService();

  List<Map<String, dynamic>> _assessments = [];
  List<Map<String, dynamic>> _filteredAssessments = [];
  bool _isLoading = true;

  void refreshAssessments() {
    _loadAssessments();
  }

  @override
  void initState() {
    super.initState();
    // Delay the loading to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssessments();
    });
  }

  Future<void> _loadAssessments() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for auth to be initialized
    while (authProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    final mongoDbUserId = authProvider.userId;

    if (mongoDbUserId != null) {
      try {
        final essayAssessments =
            await _assessmentsService.getEssayAssessments(mongoDbUserId);
        print('Essay assessments: $essayAssessments');
        final identificationAssessments = await _assessmentsService
            .getIdentificationAssessments(mongoDbUserId);
        print('Identification assessments: $identificationAssessments');

        if (!mounted) return;

        print("assessments $identificationAssessments");

        setState(() {
          _assessments = [
            ...essayAssessments.map((e) => {
                  'title': e.name,
                  'type': 'essay',
                  'data': e,
                }),
            ...identificationAssessments.map((i) => {
                  'title': i.name,
                  'type': 'identification',
                  'data': i,
                }),
          ];
          _filteredAssessments = _assessments;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _assessments = [];
          _filteredAssessments = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to load assessments. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error loading assessments: $e');
      }
    } else {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _assessments = [];
        _filteredAssessments = [];
      });
      print('User ID is null');
    }
  }

  void _filterAssessments(String query) {
    setState(() {
      _filteredAssessments = _assessments
          .where((assessment) => assessment['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: _filterAssessments,
              decoration: InputDecoration(
                hintText: 'Search',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon:
                    const Icon(Icons.search, color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Assessment List or Empty State
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_assessments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAssessments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: const _EmptyState(
              message: "No assessments available yet",
              icon: Icons.assignment_outlined,
            ),
          ),
        ),
      );
    }

    if (_filteredAssessments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAssessments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _EmptyState(
              message: "No assessments found for '${_searchController.text}'",
              icon: Icons.search_off_outlined,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssessments,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: _filteredAssessments.map((assessment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _AssessmentListItem(
                    title: assessment['title'],
                    iconPath: assessment['type'] == 'essay'
                        ? 'Essay'
                        : 'Identification',
                    onTap: () async {
                      if (assessment['type'] == 'essay') {
                        final essayAssessment =
                            assessment['data'] as EssayAssessment;
                        final pageResult =
                            await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => EditEssayScreen(
                              essayId: essayAssessment.id,
                            ),
                          ),
                        );

                        if (pageResult == true) {
                          await _loadAssessments();
                        }
                      } else {
                        final identificationAssessment =
                            assessment['data'] as IdentificationAssessment;
                        final pageResult =
                            await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => EditIdentificationScreen(
                              assessmentId: identificationAssessment.id,
                            ),
                          ),
                        );

                        if (pageResult == true) {
                          await _loadAssessments();
                        }
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AssessmentListItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const _AssessmentListItem({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  iconPath,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
