import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StudentIdentificationResultService {
  final String baseUrl;

  StudentIdentificationResultService() : baseUrl = dotenv.get('API_URL');

  Future<bool> updateQuestionResult(
      String questionResultId, bool isCorrect) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/identification-results/question/$questionResultId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isCorrect': isCorrect}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update question result');
      }

      return true;
    } catch (e) {
      print("Error updating question result: $e");
      throw Exception('Error updating question result: $e');
    }
  }

  Future<bool> deleteStudentResult(String resultId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/identification-results/$resultId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete result');
      }

      return true;
    } catch (e) {
      print("Error deleting result: $e");
      throw Exception('Error deleting result: $e');
    }
  }

  Future<bool> updateStudentName(String resultId, String name) async {
    try {
      final body = {'studentName': name};

      final response = await http.put(
          Uri.parse('$baseUrl/identification-results/$resultId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete result');
      }

      return true;
    } catch (e) {
      print("Error deleting result: $e");
      throw Exception('Error deleting result: $e');
    }
  }
}
