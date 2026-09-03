import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/reminder.dart';

class ReminderService {
  final ApiClient _apiClient;

  ReminderService(this._apiClient);

  Future<List<Reminder>> getReminders(String recordId) async {
    try {
      final response = await _apiClient.dio.get('/financial-records/$recordId/reminders');
      return (response.data as List)
          .map((json) => Reminder.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }

  Future<Reminder> createReminder(String recordId, Reminder reminder) async {
    try {
      final response = await _apiClient.dio.post(
        '/financial-records/$recordId/reminders',
        data: reminder.toJson(),
      );
      return Reminder.fromJson(response.data);
    } on DioException catch (e) {
      // The backend enforces unique (record_id, days_before)
      final error = _apiClient.handleDioError(e);
      // Translate SQLite/Postgres unique constraint errors to a friendly message if needed
      // Actually, standard error response will be handled nicely
      throw error;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _apiClient.dio.delete('/reminders/$id');
    } on DioException catch (e) {
      throw _apiClient.handleDioError(e);
    }
  }
}
