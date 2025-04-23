import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';

class CameraService {
  final String baseUrl;

  CameraService() : baseUrl = dotenv.get('API_URL');

  Future<Map<String, dynamic>> uploadIdentificationImage(
    File photoFile,
    String assessmentId,
  ) async {
    try {
      // Create the URI for the identification endpoint
      final uri = Uri.parse('$baseUrl/identification/$assessmentId');
      print('Uploading to: $uri');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add file to the request with the field name 'image'
      final fileStream = http.ByteStream(photoFile.openRead());
      final fileLength = await photoFile.length();

      final multipartFile = http.MultipartFile(
        'image', // This must match 'image' in the FileInterceptor on the server
        fileStream,
        fileLength,
        filename: photoFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'), // Specify content type
      );

      request.files.add(multipartFile);

      // Add headers if needed (e.g., authentication)
      // request.headers['Authorization'] = 'Bearer $token';

      print('Sending identification request...');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw HttpException(
          'Server returned status code: ${response.statusCode} with body: ${response.body}',
        );
      }

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      print('Error in uploadIdentificationImage: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadEssayImage(
    File photoFile,
    String assessmentId,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/essay/$assessmentId');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Validate file size before upload (5MB limit)
      final fileLength = await photoFile.length();
      if (fileLength > 5 * 1024 * 1024) {
        throw Exception('File size exceeds 5MB limit');
      }

      // Add file to request
      final fileStream = http.ByteStream(photoFile.openRead());
      final multipartFile = http.MultipartFile(
        'image',
        fileStream,
        fileLength,
        filename: photoFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw HttpException(
          'Server returned status code: ${response.statusCode} with body: ${response.body}',
        );
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print('Error uploading essay: $e');
      rethrow;
    }
  }

  // Keep the original uploadPicture method for general file uploads
  Future<Map<String, dynamic>> uploadPicture(
      File photoFile, String filePath) async {
    try {
      final uri = Uri.parse('$baseUrl/upload');
      print('Uploading to: $uri');

      final request = http.MultipartRequest('POST', uri);
      request.fields['path'] = filePath;

      final fileStream = http.ByteStream(photoFile.openRead());
      final fileLength = await photoFile.length();

      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: photoFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'), // Specify content type
      );

      request.files.add(multipartFile);

      print('Sending request...');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        throw HttpException(
          'Server returned status code: ${response.statusCode} with body: ${response.body}',
        );
      }

      return jsonDecode(response.body);
    } catch (e) {
      print('Error in uploadPicture: $e');
      rethrow;
    }
  }
}
