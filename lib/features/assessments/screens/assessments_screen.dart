import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../widgets/assessments_list.dart';
import '../widgets/settings_popup.dart';
import '../widgets/assessments_dialog.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final GlobalKey<AssessmentSearchWidgetState> _searchWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final Offset offset = button.localToGlobal(Offset.zero);

              final RelativeRect position = RelativeRect.fromLTRB(
                MediaQuery.of(context).size.width - 200,
                offset.dy + AppBar().preferredSize.height + 25,
                8,
                0,
              );

              showSettingsPopup(context, position);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: const [
                    Text(
                      'SnapScore',
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Assessments',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AssessmentSearchWidget(key: _searchWidgetKey),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await showAssessmentTypeDialog(context);
                    if (result) {
                      _searchWidgetKey.currentState?.refreshAssessments();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text(
                        'New Assessment',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
