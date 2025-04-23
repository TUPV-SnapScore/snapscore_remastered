import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/essay_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EssayService {
  final String baseUrl;

  EssayService() : baseUrl = dotenv.get('API_URL');

  Future<Map<String, dynamic>> createEssay({
    required String essayTitle,
    required String userId,
    required List<EssayQuestion> questions,
  }) async {
    try {
      // Create essay
      final response = await http.post(
        Uri.parse('$baseUrl/essay-assessment/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': essayTitle,
          'id': userId,
          'questions': questions
              .map((question) => {
                    'question': question.question,
                    'essayCriteria': question.essayCriteria
                        .map((criteria) => {
                              'criteria': criteria.criteria,
                              'maxScore': criteria.maxScore,
                              'rubrics': criteria.rubrics
                                  .map((rubric) => {
                                        'score': rubric.score,
                                        'description': rubric.description,
                                      })
                                  .toList(),
                            })
                        .toList(),
                  })
              .toList(),
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = jsonDecode(response.body);
        throw Exception('Failed to create essay: ${data['message']}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to create essay: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateEssay({
    required String essayId,
    required String essayTitle,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/essay-assessment/$essayId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': essayTitle,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to update essay: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getEssay(String essayId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/essay-assessment/$essayId'),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to fetch essay: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateQuestion({
    required String questionId,
    required String questionText,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/essay-questions/$questionId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': questionText,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to update question: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateCriteria({
    required String criteriaId,
    required String criteriaText,
    required double maxScore,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/essay-criteria/$criteriaId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'criteria': criteriaText,
          'maxScore': maxScore,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to update criteria: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateRubric({
    required String rubricId,
    required String description,
    required String score,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/rubrics/$rubricId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'description': description,
          'score': score,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to update rubric: $e',
      };
    }
  }

  Future<bool> deleteEssay(String essayId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/essay-assessment/$essayId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete essay');
      }

      return true;
    } catch (e) {
      throw Exception('Error deleting essay: $e');
    }
  }
}
