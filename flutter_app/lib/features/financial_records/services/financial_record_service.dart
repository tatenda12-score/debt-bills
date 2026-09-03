import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/financial_record.dart';

class FinancialRecordService {
  final ApiClient _apiClient;

  FinancialRecordService(this._apiClient);

  Future<List<FinancialRecord>> getRecords({
    int skip = 0,
    int limit = 100,
    Direction? direction,
    Status? status,
    Category? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      if (direction != null) queryParams['direction'] = direction.value;
      if (status != null) queryParams['status'] = status.value;
      if (category != null) queryParams['category'] = category.value;

      final response = await _apiClient.dio.get(
        '/financial-records/',
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((json) => FinancialRecord.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }

  Future<FinancialRecord> getRecord(String id) async {
    try {
      final response = await _apiClient.dio.get('/financial-records/$id');
      return FinancialRecord.fromJson(response.data);
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }

  Future<FinancialRecord> createRecord(FinancialRecord record) async {
    try {
      final response = await _apiClient.dio.post(
        '/financial-records/',
        data: record.toJson(),
      );
      return FinancialRecord.fromJson(response.data);
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }

  Future<FinancialRecord> updateRecord(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.dio.patch(
        '/financial-records/$id',
        data: updates,
      );
      return FinancialRecord.fromJson(response.data);
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _apiClient.dio.delete('/financial-records/$id');
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }
}
