import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snapscore/features/assessments/models/assessment_model.dart';

class AssessmentsService {
  final String baseUrl;

  AssessmentsService() : baseUrl = dotenv.get('API_URL');

  Future<List<EssayAssessment>> getEssayAssessments(String userId) async {
    try {
      print('Fetching essay assessments for userId: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/essay-assessment/user-essay/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final dynamic decodedData = json.decode(response.body);

        if (decodedData == null) {
          return [];
        }

        if (decodedData is List) {
          return decodedData
              .map((json) => EssayAssessment.fromJson(json))
              .toList();
        }

        if (decodedData is Map<String, dynamic>) {
          return [EssayAssessment.fromJson(decodedData)];
        }

        throw Exception('Unexpected response format: ${response.body}');
      } else {
        throw Exception(
            'Failed to load essay assessments. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in getEssayAssessments: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error fetching essay assessments: $e');
    }
  }

  Future<List<IdentificationAssessment>> getIdentificationAssessments(
      String userId) async {
    try {
      print('Fetching identification assessments for userId: $userId');
      final response = await http.get(
        Uri.parse(
            '$baseUrl/identification-assessment/user-identification/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final dynamic decodedData = json.decode(response.body);

        if (decodedData == null) {
          return [];
        }

        if (decodedData is List) {
          return decodedData
              .map((json) => IdentificationAssessment.fromJson(json))
              .toList();
        }

        if (decodedData is Map<String, dynamic>) {
          return [IdentificationAssessment.fromJson(decodedData)];
        }

        throw Exception('Unexpected response format: ${response.body}');
      } else {
        throw Exception(
            'Failed to load identification assessments. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in getIdentificationAssessments: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error fetching identification assessments: $e');
    }
  }
}
