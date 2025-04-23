import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/identification_results_model.dart';

class IdentificationResultsService {
  final String baseUrl;

  IdentificationResultsService() : baseUrl = dotenv.get('API_URL');

  Future<List<IdentificationResultModel>> getResultsByAssessmentId(
      String assessmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/identification-results/assessment/$assessmentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch results');
      }

      final List<dynamic> data = json.decode(response.body);
      print(data);
      List<IdentificationResultModel> results =
          data.map((json) => IdentificationResultModel.fromJson(json)).toList();

      results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return results;
    } catch (e) {
      print("error here $e");
      throw Exception('Error fetching results: $e');
    }
  }
}
