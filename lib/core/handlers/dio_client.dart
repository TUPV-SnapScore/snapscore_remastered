import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snapscore/core/handlers/secure_storage.dart';

class DioClient {
  static final DioClient _singleton = DioClient._internal();
  static late Dio _dio;
  final SecureStorage _secureStorage = SecureStorage();

  factory DioClient() {
    return _singleton;
  }

  DioClient._internal() {
    _dio = Dio();

    final apiUrl = dotenv.env['API_URL'];
    if (apiUrl != null && apiUrl.isNotEmpty) {
      _dio.options.baseUrl = apiUrl;
    } else {
      print('Warning: API_URL not found in .env file');
    }

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            _secureStorage.deleteToken();
          }
          handler.next(e);
        },
      ),
    );
  }

  Dio get instance => _dio;
}
