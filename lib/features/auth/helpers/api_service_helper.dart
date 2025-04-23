// api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl;

  ApiService() : baseUrl = dotenv.get('API_URL');

  Future<Map<String, dynamic>> register(
      {required String email,
      required String userId,
      required String fullName}) async {
    try {
      print("okay okay!");
      print(email);
      print(userId);
      print(fullName);
      print('Base URL: $baseUrl');
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'firebaseId': userId,
          'fullName': fullName,
        }),
      );

      print(response);
      print(response.statusCode);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getUserByFirebaseId({
    required String userId,
  }) async {
    try {
      print('Fetching user by Firebase ID: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/users/firebase/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> googleSignIn({
    required String email,
    required String fullName,
    required String userId,
  }) async {
    try {
      // First check if user exists
      final existingUserResponse = await http.get(
        Uri.parse('$baseUrl/users/firebase/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      // If user exists and response is valid JSON, return it
      if (existingUserResponse.statusCode == 200 &&
          existingUserResponse.body.isNotEmpty) {
        return jsonDecode(existingUserResponse.body);
      }

      // If user doesn't exist, create new user
      final createUserResponse = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'fullName': fullName,
          'firebaseId': userId, // Added this field
        }),
      );

      if (createUserResponse.statusCode == 201 ||
          createUserResponse.statusCode == 200) {
        if (createUserResponse.body.isEmpty) {
          throw Exception('Empty response received from server');
        }
        return jsonDecode(createUserResponse.body);
      } else {
        final errorBody = createUserResponse.body.isNotEmpty
            ? jsonDecode(createUserResponse.body)['message']
            : 'Google sign-in failed';
        throw Exception(errorBody);
      }
    } catch (e) {
      print('Google sign-in error: $e');
      throw Exception('Failed to register with Google: ${e.toString()}');
    }
  }
}
