import 'package:snapscore/features/assessments/models/assessment_model.dart';

class EssayQuestion {
  final int questionNumber;
  final String question;
  final String? id;
  final List<EssayCriteria> essayCriteria;
  final String? assessmentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EssayQuestion({
    this.questionNumber = 1,
    required this.question,
    this.id,
    List<EssayCriteria>? essayCriteria,
    this.assessmentId,
    this.createdAt,
    this.updatedAt,
  }) : essayCriteria = essayCriteria ?? [];

  factory EssayQuestion.fromJson(Map<String, dynamic> json) {
    return EssayQuestion(
      questionNumber: json['questionNumber'] as int? ??
          (json['question_number'] as int?) ??
          1,
      question: json['questionText'] as String? ?? json['question'] as String,
      id: json['id'] as String?,
      essayCriteria: (json['essayCriteria'] as List?)
              ?.map((c) => EssayCriteria.fromJson(c))
              .toList() ??
          [],
      assessmentId: json['assessmentId'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'questionNumber': questionNumber,
      'question': question,
      'essayCriteria': essayCriteria.map((c) => c.toJson()).toList(),
    };

    if (id != null) data['id'] = id;
    if (assessmentId != null) data['assessmentId'] = assessmentId;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();

    return data;
  }
}

class EssayCriteria {
  final int criteriaNumber;
  final String criteria;
  final int maxScore;
  final String? id;
  final List<Rubric> rubrics;
  final String? essayQuestionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EssayCriteria({
    this.criteriaNumber = 1,
    required this.criteria,
    required this.maxScore,
    this.id,
    List<Rubric>? rubrics,
    this.essayQuestionId,
    this.createdAt,
    this.updatedAt,
  }) : rubrics = rubrics ?? [];

  factory EssayCriteria.fromJson(Map<String, dynamic> json) {
    return EssayCriteria(
      criteriaNumber: json['criteriaNumber'] as int? ??
          (json['criteria_number'] as int?) ??
          1,
      criteria: json['criteriaText'] as String? ?? json['criteria'] as String,
      maxScore: (json['maxScore'] as num).toInt(),
      id: json['id'] as String?,
      rubrics:
          (json['rubrics'] as List?)?.map((r) => Rubric.fromJson(r)).toList() ??
              [],
      essayQuestionId: json['essayQuestionId'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'criteriaNumber': criteriaNumber,
      'criteria': criteria,
      'maxScore': maxScore,
      'rubrics': rubrics.map((r) => r.toJson()).toList(),
    };

    if (id != null) data['id'] = id;
    if (essayQuestionId != null) data['essayQuestionId'] = essayQuestionId;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();

    return data;
  }
}

class Rubric {
  final String? id;
  final String score;
  final String description;
  final String? criteriaId;

  Rubric({
    this.id,
    required this.score,
    required this.description,
    this.criteriaId,
  });

  factory Rubric.fromJson(Map<String, dynamic> json) {
    return Rubric(
      id: json['id'] as String?,
      score: json['score'] as String,
      description: json['description'] as String,
      criteriaId: json['criteriaId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'score': score,
      'description': description,
    };

    if (id != null) data['id'] = id;
    if (criteriaId != null) data['criteriaId'] = criteriaId;

    return data;
  }
}

class EssayData {
  final String essayTitle;
  final List<EssayQuestion> questions;
  final List<EssayCriteria> criteria;
  final double totalScore;
  final String? id;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<EssayResult>? essayResults;

  EssayData({
    required this.essayTitle,
    required this.questions,
    required this.criteria,
    this.totalScore = 0.0,
    this.id,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.essayResults,
  });

  factory EssayData.fromJson(Map<String, dynamic> json) {
    // Check if this is form data or API response
    final isFormData = json.containsKey('questions');

    if (isFormData) {
      return EssayData(
        essayTitle: json['essayTitle'] as String,
        questions: (json['questions'] as List)
            .map((q) => EssayQuestion.fromJson(q))
            .toList(),
        criteria: (json['criteria'] as List)
            .map((c) => EssayCriteria.fromJson(c))
            .toList(),
        totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      );
    }

    // Handle API response format
    return EssayData(
      id: json['id'] as String?,
      essayTitle: json['name'] as String? ?? json['essayTitle'] as String,
      questions: (json['essayQuestions'] as List?)
              ?.map((q) => EssayQuestion.fromJson({
                    ...q,
                    'questionNumber': q['questionNumber'] as int? ??
                        ((json['essayQuestions'] as List).indexOf(q) + 1),
                  }))
              .toList() ??
          [],
      criteria: (json['essayQuestions'] != null &&
              (json['essayQuestions'] as List).isNotEmpty &&
              json['essayQuestions'][0]['essayCriteria'] != null)
          ? (json['essayQuestions'][0]['essayCriteria'] as List)
              .map((c) => EssayCriteria.fromJson({
                    ...c,
                    'criteriaNumber': c['criteriaNumber'] as int? ??
                        ((json['essayQuestions'][0]['essayCriteria'] as List)
                                .indexOf(c) +
                            1),
                  }))
              .toList()
          : [],
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      userId: json['userId'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      essayResults: (json['essayResults'] as List?)
          ?.map((r) => EssayResult.fromJson(r))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'essayTitle': essayTitle,
      'questions': questions.map((q) => q.toJson()).toList(),
      'criteria': criteria.map((c) => c.toJson()).toList(),
      'totalScore': totalScore,
    };

    if (id != null) data['id'] = id;
    if (userId != null) data['userId'] = userId;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    if (essayResults != null) {
      data['essayResults'] = essayResults!.map((r) => r.toJson()).toList();
    }

    return data;
  }
}
