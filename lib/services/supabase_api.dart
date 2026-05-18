import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:paru_kuat/models/user.dart';
import 'package:paru_kuat/models/exercise_type.dart';
import 'package:paru_kuat/models/exercise_log.dart';
import 'package:paru_kuat/models/game_stat.dart';
import 'package:paru_kuat/models/daily_journal.dart';
import 'package:paru_kuat/models/notification.dart';

class SupabaseApi {
  final String baseUrl = "https://vtpivcozhlfvixqdjtxf.supabase.co/rest/v1";
  final String apiKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0cGl2Y296aGxmdml4cWRqdHhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyOTk2MjksImV4cCI6MjA5Mjg3NTYyOX0.XbriEMe-3hXZWPQpincCWrWxqo6zPzWdBgmIb0ORzh8";

  // Helper untuk HTTP Headers
  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'apikey': apiKey,
    'Authorization': 'Bearer $apiKey',
  };

  Map<String, String> get _postHeaders => {
    ..._headers,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  // CRUD Function Reusable
  Future<List<dynamic>> _get(String table) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$table?select=*'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Gagal memuat data dari $table: ${response.body}');
    }
  }

  Future<dynamic> _post(String table, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$table'),
      headers: _postHeaders,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final List<dynamic> resData = jsonDecode(response.body);
      return resData.isNotEmpty ? resData[0] : null;
    } else {
      throw Exception('Gagal menambahkan data ke $table: ${response.body}');
    }
  }

  Future<dynamic> _patch(
    String table,
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$table?id=eq.$id'),
      headers: _postHeaders,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final List<dynamic> resData = jsonDecode(response.body);
      return resData.isNotEmpty ? resData[0] : null;
    } else {
      throw Exception('Gagal mengupdate data di $table: ${response.body}');
    }
  }

  Future<void> _delete(String table, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$table?id=eq.$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus data dari $table: ${response.body}');
    }
  }

  // Users CRUD
  Future<List<User>> getUsers() async {
    final data = await _get('users');
    return data.map((json) => User.fromJson(json)).toList();
  }

  Future<User> createUser(User user) async {
    final bodyData = user.toJson()..remove('id');
    final data = await _post('users', bodyData);
    log('Berhasil melakukan register.');
    return User.fromJson(data);
  }

  Future<User> updateUser(int id, User user) async {
    final bodyData = user.toJson()
      ..remove('id')
      ..remove('created_at');
    final data = await _patch('users', id, bodyData);
    return User.fromJson(data);
  }

  Future<void> deleteUser(int id) async {
    await _delete('users', id);
  }

  // Excercises CRUD
  Future<List<ExerciseType>> getExerciseTypes() async {
    final data = await _get('exercise_types');
    return data.map((json) => ExerciseType.fromJson(json)).toList();
  }

  Future<ExerciseType> createExerciseType(ExerciseType type) async {
    final bodyData = type.toJson()..remove('id');
    final data = await _post('exercise_types', bodyData);
    return ExerciseType.fromJson(data);
  }

  Future<ExerciseType> updateExerciseType(int id, ExerciseType type) async {
    final bodyData = type.toJson()..remove('id');
    final data = await _patch('exercise_types', id, bodyData);
    return ExerciseType.fromJson(data);
  }

  Future<void> deleteExerciseType(int id) async {
    await _delete('exercise_types', id);
  }

  // Excercise Logs CRUD
  Future<List<ExerciseLog>> getExerciseLogs() async {
    final data = await _get('exercise_logs');
    return data.map((json) => ExerciseLog.fromJson(json)).toList();
  }

  Future<ExerciseLog> createExerciseLog(ExerciseLog logEntry) async {
    final bodyData = logEntry.toJson()
      ..remove('id')
      ..remove('completed_at');
    final data = await _post('exercise_logs', bodyData);
    return ExerciseLog.fromJson(data);
  }

  Future<ExerciseLog> updateExerciseLog(int id, ExerciseLog logEntry) async {
    final bodyData = logEntry.toJson()
      ..remove('id')
      ..remove('completed_at');
    final data = await _patch('exercise_logs', id, bodyData);
    return ExerciseLog.fromJson(data);
  }

  Future<void> deleteExerciseLog(int id) async {
    await _delete('exercise_logs', id);
  }

  // Game Stats CRUD
  Future<List<GameStat>> getGameStats() async {
    final data = await _get('game_stats');
    return data.map((json) => GameStat.fromJson(json)).toList();
  }

  Future<GameStat> createGameStat(GameStat stat) async {
    final bodyData = stat.toJson()
      ..remove('id')
      ..remove('last_played_at');
    final data = await _post('game_stats', bodyData);
    return GameStat.fromJson(data);
  }

  Future<GameStat> updateGameStat(int id, GameStat stat) async {
    final bodyData = stat.toJson()
      ..remove('id')
      ..remove('last_played_at');
    final data = await _patch('game_stats', id, bodyData);
    return GameStat.fromJson(data);
  }

  Future<void> deleteGameStat(int id) async {
    await _delete('game_stats', id);
  }

  // Daily Journals CRUD
  Future<List<DailyJournal>> getDailyJournals() async {
    final data = await _get('daily_journals');
    return data.map((json) => DailyJournal.fromJson(json)).toList();
  }

  Future<DailyJournal> createDailyJournal(DailyJournal journal) async {
    final bodyData = journal.toJson()
      ..remove('id')
      ..remove('created_at');
    final data = await _post('daily_journals', bodyData);
    return DailyJournal.fromJson(data);
  }

  Future<DailyJournal> updateDailyJournal(int id, DailyJournal journal) async {
    final bodyData = journal.toJson()
      ..remove('id')
      ..remove('created_at');
    final data = await _patch('daily_journals', id, bodyData);
    return DailyJournal.fromJson(data);
  }

  Future<void> deleteDailyJournal(int id) async {
    await _delete('daily_journals', id);
  }

  // Notifications CRUD
  Future<List<NotificationModel>> getNotifications() async {
    final data = await _get('notifications');
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    final bodyData = notification.toJson()
      ..remove('id')
      ..remove('sent_at');
    final data = await _post('notifications', bodyData);
    return NotificationModel.fromJson(data);
  }

  Future<NotificationModel> updateNotification(
    int id,
    NotificationModel notification,
  ) async {
    final bodyData = notification.toJson()
      ..remove('id')
      ..remove('sent_at');
    final data = await _patch('notifications', id, bodyData);
    return NotificationModel.fromJson(data);
  }

  Future<void> deleteNotification(int id) async {
    await _delete('notifications', id);
  }
}
