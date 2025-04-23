import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/identification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IdentificationService {
  final String baseUrl;

  IdentificationService() : baseUrl = dotenv.get('API_URL');

  Future<bool> deleteAssessment(String assessmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/identification-assessment/$assessmentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete assessment');
      }

      return true;
    } catch (e) {
      throw Exception('Error deleting assessment: $e');
    }
  }

  Future<Map<String, dynamic>> _createIdentificationQuestion({
    required String assessmentId,
    required int number,
    required IdentificationAnswer answer,
  }) async {
    try {
      final body = {
        'assessmentId': assessmentId,
        'number': number,
        'correctAnswer': answer.answer,
      };

      print("added");

      final response = await http.post(
        Uri.parse('$baseUrl/identification-questions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = jsonDecode(response.body);
        throw Exception('Failed to create question: ${data['message']}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      return {'error': true, 'message': 'Failed to create question: $e'};
    }
  }

  Future<Map<String, dynamic>> createAssessment({
    required String assessmentName,
    required List<IdentificationAnswer> answers,
    required String userId,
  }) async {
    try {
      final body = {
        'name': assessmentName,
        'id': userId,
        'questions': [],
      };

      print(answers);

      final response = await http.post(
        Uri.parse('$baseUrl/identification-assessment/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = jsonDecode(response.body);
        throw Exception('Failed to create assessment: ${data['message']}');
      }

      final assessmentData = jsonDecode(response.body) as Map<String, dynamic>;
      print(assessmentData);
      final assessmentId = assessmentData['id'] as String?;

      if (assessmentId == null) {
        throw Exception('Assessment ID not found in response');
      }

      // Create questions one by one
      for (var answer in answers) {
        await _createIdentificationQuestion(
          number: answer.number,
          assessmentId: assessmentId,
          answer: answer,
        );
      }

      return assessmentData;
    } catch (e) {
      print('Error creating assessment: $e');
      return {
        'error': true,
        'message': 'Failed to create assessment: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getAssessment(String assessmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/identification-assessment/$assessmentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response received');
        }

        final Map<String, dynamic> decodedData = json.decode(response.body);

        // Ensure identificationQuestions is not null
        if (decodedData['identificationQuestions'] == null) {
          decodedData['identificationQuestions'] = [];
        }

        return decodedData;
      } else {
        throw Exception('Failed to load assessment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assessment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getQuestions(String assessmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/identification-questions/$assessmentId'),
        headers: {'Content-Type': 'application/json'},
      );
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateAssessment({
    required String assessmentId,
    required String assessmentName,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/identification-assessment/$assessmentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': assessmentName}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': true, 'message': 'Failed to update assessment: $e'};
    }
  }

  Future<Map<String, dynamic>> updateQuestion({
    required String questionId,
    required String answer,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/identification-questions/$questionId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correctAnswer': answer,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': true, 'message': 'Failed to update question: $e'};
    }
  }
}
