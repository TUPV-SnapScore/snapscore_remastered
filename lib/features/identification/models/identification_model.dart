// identification_models.dart
class IdentificationAnswer {
  final int number;
  final String answer;

  IdentificationAnswer({
    required this.number,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'answer': answer,
    };
  }

  factory IdentificationAnswer.fromJson(Map<String, dynamic> json) {
    return IdentificationAnswer(
      number: json['number'] as int,
      answer: json['answer'] as String,
    );
  }
}

class IdentificationFormDataModel {
  final String assessmentId;
  final String name;
  final List<IdentificationAnswerWithId> answers;

  IdentificationFormDataModel({
    required this.assessmentId,
    required this.name,
    required this.answers,
  });
}

class IdentificationAnswerWithId extends IdentificationAnswer {
  final String id;

  IdentificationAnswerWithId({
    required this.id,
    required super.number,
    required super.answer,
  });
}

class IdentificationData {
  final String assessmentName;
  final int numberOfQuestions;
  final List<IdentificationAnswer> answers;

  IdentificationData({
    required this.assessmentName,
    required this.numberOfQuestions,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'assessmentName': assessmentName,
      'numberOfQuestions': numberOfQuestions,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}
