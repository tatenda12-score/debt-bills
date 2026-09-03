import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import '../errors/api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;

  Exception handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout || 
        e.type == DioExceptionType.connectionError) {
      return ApiException("Unable to connect to the server. Please check your internet connection.");
    }
    
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      
      String message = "An error occurred";
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        if (data['detail'] is String) {
           message = data['detail'];
        } else if (data['detail'] is List) {
           message = "Validation error. Please check your inputs.";
           return ValidationException(message, {'errors': data['detail']});
        }
      }
      
      if (statusCode == 401) {
        return AuthException("Your session has expired. Please log in again.");
      } else if (statusCode == 422) {
        return ValidationException(message, {});
      }
      return ApiException(message, statusCode);
    }
    
    return ApiException("An unexpected error occurred.");
  }
}
