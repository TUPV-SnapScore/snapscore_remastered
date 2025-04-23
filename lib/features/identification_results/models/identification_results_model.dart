class IdentificationResultModel {
  final String id;
  final String studentName;
  final String assessmentId; // Added this
  final DateTime createdAt; // Added this
  final String paperImage;
  final List<QuestionResultModel>? questionResults; // Made optional

  IdentificationResultModel({
    required this.id,
    required this.studentName,
    required this.assessmentId,
    required this.createdAt,
    required this.paperImage,
    this.questionResults, // Made optional
  });

  // Update score calculations to handle null questionResults
  int get correctAnswers =>
      questionResults?.where((result) => result.isCorrect).length ?? 0;
  int get totalQuestions => questionResults?.length ?? 0;

  String get scoreText => '$correctAnswers/$totalQuestions';

  factory IdentificationResultModel.fromJson(Map<String, dynamic> json) {
    try {
      return IdentificationResultModel(
        id: json['id']?.toString() ?? '',
        studentName: json['studentName']?.toString() ?? 'Unknown Student',
        assessmentId: json['assessmentId']?.toString() ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        paperImage: json['paperImage']?.toString() ?? '',
        questionResults: json['questionResults'] != null
            ? (json['questionResults'] as List)
                .map((result) => QuestionResultModel.fromJson(result))
                .toList()
            : null,
      );
    } catch (e) {
      print('Error parsing IdentificationResultModel: $json');
      print('Error details: $e');
      rethrow;
    }
  }
}

class QuestionResultModel {
  final String id;
  final int number;
  final String answer;
  final bool isCorrect;
  final QuestionModel question;

  QuestionResultModel({
    required this.id,
    required this.number,
    required this.answer,
    required this.isCorrect,
    required this.question,
  });

  factory QuestionResultModel.fromJson(Map<String, dynamic> json) {
    try {
      return QuestionResultModel(
        id: json['id']?.toString() ?? '',
        number: json['number'] as int? ?? 0, // Default to 0 if null
        answer: json['answer']?.toString() ?? '',
        isCorrect:
            json['isCorrect'] as bool? ?? false, // Default to false if null
        question: QuestionModel.fromJson(
            json['question'] ?? {}), // Pass empty map if null
      );
    } catch (e) {
      print('Error parsing QuestionResultModel: $json');
      print('Error details: $e');
      rethrow;
    }
  }
}

class QuestionModel {
  final String id;
  final int number; // Added this
  final String question;
  final String correctAnswer;

  QuestionModel({
    required this.id,
    required this.number, // Added this
    required this.question,
    required this.correctAnswer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    try {
      return QuestionModel(
        id: json['id']?.toString() ?? '',
        number: json['number'] as int? ?? 0, // Default to 0 if null
        question: json['question']?.toString() ?? '',
        correctAnswer: json['correctAnswer']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing QuestionModel: $json');
      print('Error details: $e');
      rethrow;
    }
  }
}
