import 'package:snapscore/features/essays/models/essay_model.dart';

// essay_result_model.dart

class EssayResult {
  final String id;
  String studentName;
  final String assessmentId;
  List<EssayQuestionResult> questionResults;
  final String paperImage;
  final DateTime createdAt;
  int score;

  EssayResult({
    required this.id,
    required this.studentName,
    required this.assessmentId,
    required this.questionResults,
    this.paperImage = 'notfound.jpg',
    required this.createdAt,
    required this.score,
  });

  factory EssayResult.fromJson(Map<String, dynamic> json) {
    return EssayResult(
      id: json['id']?.toString() ?? '',
      studentName: json['studentName']?.toString() ?? 'Unknown Student',
      assessmentId: json['assessmentId']?.toString() ?? '',
      questionResults: (json['questionResults'] as List?)
              ?.map((e) => EssayQuestionResult.fromJson(e))
              .toList() ??
          [],
      paperImage: json['paperImage']?.toString() ?? 'notfound.jpg',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      score: json['score'] != null ? (json['score'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'assessmentId': assessmentId,
      'questionResults': questionResults.map((qr) => qr.toJson()).toList(),
      'score': score,
      'paperImage': paperImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class EssayQuestionResult {
  final String id;
  final String answer;
  final String resultId;
  final String questionId;
  final int score;
  final EssayQuestion
      question; // Make this required since it's required in the schema
  final List<EssayCriteriaResult> essayCriteriaResults;
  final DateTime createdAt;

  EssayQuestionResult({
    required this.id,
    required this.answer,
    required this.resultId,
    required this.questionId,
    required this.score,
    required this.question, // Required
    required this.essayCriteriaResults,
    required this.createdAt,
  });

  factory EssayQuestionResult.fromJson(Map<String, dynamic> json) {
    // Throw an error if question is missing
    if (json['question'] == null) {
      throw FormatException('Question data is required but was null');
    }

    return EssayQuestionResult(
      id: json['id']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      resultId: json['resultId']?.toString() ?? '',
      questionId: json['questionId']?.toString() ?? '',
      score: json['score'] != null ? (json['score'] as num).toInt() : 0,
      question: EssayQuestion.fromJson(json['question']),
      essayCriteriaResults: (json['essayCriteriaResults'] as List?)
              ?.map((e) => EssayCriteriaResult.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer': answer,
      'resultId': resultId,
      'questionId': questionId,
      'score': score,
      'question': question.toJson(),
      'essayCriteriaResults':
          essayCriteriaResults.map((cr) => cr.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class EssayCriteriaResult {
  final String id;
  final int score;
  final String criteriaId;
  final String questionResultId;
  final EssayCriteria? criteria;
  final DateTime? createdAt;

  EssayCriteriaResult({
    required this.id,
    required this.score,
    required this.criteriaId,
    required this.questionResultId,
    this.criteria,
    this.createdAt,
  });

  factory EssayCriteriaResult.fromJson(Map<String, dynamic> json) {
    return EssayCriteriaResult(
      id: json['id']?.toString() ?? '',
      score: json['score'] != null ? (json['score'] as num).toInt() : 0,
      criteriaId: json['criteriaId']?.toString() ?? '',
      questionResultId: json['questionResultId']?.toString() ?? '',
      criteria: json['criteria'] != null
          ? EssayCriteria.fromJson(json['criteria'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'criteriaId': criteriaId,
      'questionResultId': questionResultId,
      'criteria': criteria?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
