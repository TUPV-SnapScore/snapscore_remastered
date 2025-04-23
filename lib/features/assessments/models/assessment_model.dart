class EssayAssessment {
  final String id;
  final String name;
  final List<EssayQuestion> essayQuestions;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<EssayResult> essayResults;

  EssayAssessment({
    required this.id,
    required this.name,
    required this.essayQuestions,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.essayResults,
  });

  factory EssayAssessment.fromJson(Map<String, dynamic> json) {
    return EssayAssessment(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      essayQuestions: (json['essayQuestions'] as List?)
              ?.map((q) => EssayQuestion.fromJson(q))
              .toList() ??
          [],
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      essayResults: (json['essayResults'] as List?)
              ?.map((r) => EssayResult.fromJson(r))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'essayQuestions': essayQuestions.map((q) => q.toJson()).toList(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'essayResults': essayResults.map((r) => r.toJson()).toList(),
    };
  }
}

class EssayQuestion {
  final String id;
  final String question;
  final List<EssayCriteria> essayCriteria;
  final String assessmentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  EssayQuestion({
    required this.id,
    required this.question,
    required this.essayCriteria,
    required this.assessmentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EssayQuestion.fromJson(Map<String, dynamic> json) {
    return EssayQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      essayCriteria: (json['essayCriteria'] as List?)
              ?.map((c) => EssayCriteria.fromJson(c))
              .toList() ??
          [],
      assessmentId: json['assessmentId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'essayCriteria': essayCriteria.map((c) => c.toJson()).toList(),
      'assessmentId': assessmentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class EssayCriteria {
  final String id;
  final String criteria;
  final int maxScore;
  final List<Rubric> rubrics;
  final String essayQuestionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  EssayCriteria({
    required this.id,
    required this.criteria,
    required this.maxScore,
    required this.rubrics,
    required this.essayQuestionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EssayCriteria.fromJson(Map<String, dynamic> json) {
    return EssayCriteria(
      id: json['id'] ?? '',
      criteria: json['criteria'] ?? '',
      maxScore: json['maxScore'] ?? 0,
      rubrics:
          (json['rubrics'] as List?)?.map((r) => Rubric.fromJson(r)).toList() ??
              [],
      essayQuestionId: json['essayQuestionId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'criteria': criteria,
      'maxScore': maxScore,
      'rubrics': rubrics.map((r) => r.toJson()).toList(),
      'essayQuestionId': essayQuestionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Rubric {
  final String id;
  final String score;
  final String description;
  final String criteriaId;

  Rubric({
    required this.id,
    required this.score,
    required this.description,
    required this.criteriaId,
  });

  factory Rubric.fromJson(Map<String, dynamic> json) {
    return Rubric(
      id: json['id'] ?? '',
      score: json['score'] ?? '',
      description: json['description'] ?? '',
      criteriaId: json['criteriaId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'description': description,
      'criteriaId': criteriaId,
    };
  }
}

class EssayResult {
  final String id;
  final String studentName;
  final int score;
  final String paperImage;
  final String assessmentId;
  final DateTime createdAt;
  final List<EssayQuestionResult> questionResults;

  EssayResult({
    required this.id,
    required this.studentName,
    required this.score,
    required this.paperImage,
    required this.assessmentId,
    required this.createdAt,
    required this.questionResults,
  });

  factory EssayResult.fromJson(Map<String, dynamic> json) {
    return EssayResult(
      id: json['id'] ?? '',
      studentName: json['studentName'] ?? '',
      score: json['score'] ?? 0,
      paperImage: json['paperImage'] ?? '',
      assessmentId: json['assessmentId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      questionResults: (json['questionResults'] as List?)
              ?.map((qr) => EssayQuestionResult.fromJson(qr))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'score': score,
      'paperImage': paperImage,
      'assessmentId': assessmentId,
      'createdAt': createdAt.toIso8601String(),
      'questionResults': questionResults.map((qr) => qr.toJson()).toList(),
    };
  }
}

class EssayQuestionResult {
  final String id;
  final String answer;
  final int score;
  final String resultId;
  final String questionId;
  final DateTime createdAt;
  final List<EssayCriteriaResult> essayCriteriaResults;

  EssayQuestionResult({
    required this.id,
    required this.answer,
    required this.score,
    required this.resultId,
    required this.questionId,
    required this.createdAt,
    required this.essayCriteriaResults,
  });

  factory EssayQuestionResult.fromJson(Map<String, dynamic> json) {
    return EssayQuestionResult(
      id: json['id'],
      answer: json['answer'],
      score: json['score'],
      resultId: json['resultId'],
      questionId: json['questionId'],
      createdAt: DateTime.parse(json['createdAt']),
      essayCriteriaResults: (json['essayCriteriaResults'] as List)
          .map((cr) => EssayCriteriaResult.fromJson(cr))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer': answer,
      'score': score,
      'resultId': resultId,
      'questionId': questionId,
      'createdAt': createdAt.toIso8601String(),
      'essayCriteriaResults':
          essayCriteriaResults.map((cr) => cr.toJson()).toList(),
    };
  }
}

class EssayCriteriaResult {
  final String id;
  final int score;
  final String questionResultId;
  final String criteriaId;
  final DateTime createdAt;

  EssayCriteriaResult({
    required this.id,
    required this.score,
    required this.questionResultId,
    required this.criteriaId,
    required this.createdAt,
  });

  factory EssayCriteriaResult.fromJson(Map<String, dynamic> json) {
    return EssayCriteriaResult(
      id: json['id'],
      score: json['score'],
      questionResultId: json['questionResultId'],
      criteriaId: json['criteriaId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'questionResultId': questionResultId,
      'criteriaId': criteriaId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class IdentificationAssessment {
  final String id;
  final String name;
  final List<IdentificationQuestion> identificationQuestions;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  IdentificationAssessment({
    required this.id,
    required this.name,
    required this.identificationQuestions,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IdentificationAssessment.fromJson(Map<String, dynamic> json) {
    return IdentificationAssessment(
      id: json['id'],
      name: json['name'],
      identificationQuestions: (json['identificationQuestions'] as List)
          .map((q) => IdentificationQuestion.fromJson(q))
          .toList(),
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'identificationQuestions':
          identificationQuestions.map((q) => q.toJson()).toList(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class IdentificationQuestion {
  final String id;
  final String correctAnswer;
  final String assessmentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  IdentificationQuestion({
    required this.id,
    required this.correctAnswer,
    required this.assessmentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IdentificationQuestion.fromJson(Map<String, dynamic> json) {
    return IdentificationQuestion(
      id: json['id'],
      correctAnswer: json['correctAnswer'],
      assessmentId: json['assessmentId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correctAnswer': correctAnswer,
      'assessmentId': assessmentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class IdentificationResult {
  final String id;
  final String studentName;
  final String paperImage;
  final String assessmentId;
  final DateTime createdAt;
  final List<IdentificationQuestionResult> questionResults;

  IdentificationResult({
    required this.id,
    required this.studentName,
    required this.paperImage,
    required this.assessmentId,
    required this.createdAt,
    required this.questionResults,
  });

  factory IdentificationResult.fromJson(Map<String, dynamic> json) {
    return IdentificationResult(
      id: json['id'],
      studentName: json['studentName'],
      paperImage: json['paperImage'],
      assessmentId: json['assessmentId'],
      createdAt: DateTime.parse(json['createdAt']),
      questionResults: (json['questionResults'] as List)
          .map((qr) => IdentificationQuestionResult.fromJson(qr))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'paperImage': paperImage,
      'assessmentId': assessmentId,
      'createdAt': createdAt.toIso8601String(),
      'questionResults': questionResults.map((qr) => qr.toJson()).toList(),
    };
  }
}

class IdentificationQuestionResult {
  final String id;
  final bool isCorrect;
  final String answer;
  final String resultId;
  final String questionId;
  final DateTime createdAt;

  IdentificationQuestionResult({
    required this.id,
    required this.isCorrect,
    required this.answer,
    required this.resultId,
    required this.questionId,
    required this.createdAt,
  });

  factory IdentificationQuestionResult.fromJson(Map<String, dynamic> json) {
    return IdentificationQuestionResult(
      id: json['id'],
      isCorrect: json['isCorrect'],
      answer: json['answer'],
      resultId: json['resultId'],
      questionId: json['questionId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isCorrect': isCorrect,
      'answer': answer,
      'resultId': resultId,
      'questionId': questionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
