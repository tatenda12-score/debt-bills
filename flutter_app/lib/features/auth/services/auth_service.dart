import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<String> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: FormData.fromMap({
          'username': email,
          'password': password,
        }),
      );
      return response.data['access_token'];
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }

  Future<User> register(String email, String password, String fullName) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }
}
