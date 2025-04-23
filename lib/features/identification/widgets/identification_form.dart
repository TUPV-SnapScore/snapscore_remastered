import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';
import '../models/identification_model.dart';

typedef OnSubmitCallback = Future<void> Function(Map<String, dynamic> data);

// Create a form controller to expose public methods
class IdentificationFormController {
  void Function()? submitForm;
}

class IdentificationForm extends StatefulWidget {
  final OnSubmitCallback onSubmit;
  final IdentificationFormController controller;
  final IdentificationFormDataModel? initialData;

  const IdentificationForm({
    super.key,
    required this.onSubmit,
    required this.controller,
    this.initialData,
  });

  @override
  State<IdentificationForm> createState() => _IdentificationFormState();
}

class _IdentificationFormState extends State<IdentificationForm> {
  late int selectedQuestions;
  final List<int> questionOptions = [5, 10, 15, 20];
  final List<TextEditingController> answerControllers = [];
  final TextEditingController titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.submitForm = _submitForm;

    // Initialize with provided data if available, otherwise use default
    if (widget.initialData != null) {
      // Set the title
      titleController.text = widget.initialData!.name;

      selectedQuestions = widget.initialData!.answers.length;
      // Ensure selectedQuestions is one of the valid options
      if (!questionOptions.contains(selectedQuestions)) {
        selectedQuestions = questionOptions.firstWhere(
          (option) => option >= selectedQuestions,
          orElse: () => questionOptions.first,
        );
      }
      _initializeAnswerControllers(selectedQuestions);

      // Fill in answers
      for (int i = 0; i < widget.initialData!.answers.length; i++) {
        answerControllers[i].text = widget.initialData!.answers[i].answer;
      }
    } else {
      selectedQuestions = questionOptions.first; // Default to first option
      _initializeAnswerControllers(selectedQuestions);
    }
  }

  void _initializeAnswerControllers(int count) {
    // Clear existing controllers
    for (var controller in answerControllers) {
      controller.dispose();
    }
    answerControllers.clear();

    // Create new controllers
    for (int i = 0; i < count; i++) {
      answerControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var controller in answerControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validate form
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an assessment name')),
      );
      return;
    }

    // Check if all required answers are filled
    if (answerControllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all answers')),
      );
      return;
    }

    // Build and submit the data
    final formData = {
      'assessmentName': titleController.text,
      'answers': List.generate(
        answerControllers.length,
        (index) => IdentificationAnswer(
          number: index + 1,
          answer: answerControllers[index].text,
        ),
      ),
    };

    await widget.onSubmit(formData);
  }

  // JSON Request Builder Method
  Map<String, dynamic> buildJsonRequest() {
    List<IdentificationAnswer> answers = [];
    for (int i = 0; i < answerControllers.length; i++) {
      if (answerControllers[i].text.isNotEmpty) {
        answers.add(IdentificationAnswer(
          number: i + 1,
          answer: answerControllers[i].text,
        ));
      }
    }

    IdentificationData identificationData = IdentificationData(
      assessmentName: titleController.text,
      numberOfQuestions: selectedQuestions,
      answers: answers,
    );

    return identificationData.toJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormLabel('Assessment Name:'),
            _buildTextField(
              hintText: 'Input quiz name',
              prefixIcon: "assets/icons/rubric_item.png",
              controller: titleController,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ImageIcon(
                        const AssetImage("assets/icons/rubric_item.png"),
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Pick Number of Questions:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedQuestions,
                        isExpanded: true,
                        items: questionOptions.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value questions'),
                          );
                        }).toList(),
                        onChanged: widget.initialData != null
                            ? null // Disable dropdown if editing existing assessment
                            : (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedQuestions = newValue;
                                    _initializeAnswerControllers(newValue);
                                  });
                                }
                              },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFormLabel('Answer Key:'),
            ...List.generate(
                selectedQuestions,
                (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '${index + 1}.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildTextField(
                              hintText: 'Answer ${index + 1}',
                              prefixIcon: "assets/icons/rubric_item.png",
                              controller: answerControllers[index],
                            ),
                          ),
                        ],
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 40),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required String prefixIcon, // Changed to String for image asset
    IconData? suffixIcon,
    bool enabled = true,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          prefixIcon: ImageIcon(
            AssetImage(prefixIcon),
            color: AppColors.textSecondary,
          ),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: AppColors.textSecondary)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
