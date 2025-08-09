import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class TaskService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, dynamic>> createTask(String title, String description) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found. Please log in.");

    final res = await http.post(
      Uri.parse("$apiBaseUrl/tasks"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"title": title, "description": description}),
    );

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      final errorData = jsonDecode(res.body);
      final errorMessage = errorData['message'] is List 
          ? errorData['message'].join(', ') 
          : errorData['message'] as String;
      throw Exception(errorMessage);
    }
  }

  Future<List<dynamic>> getTasks() async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found. Please log in.");

    final res = await http.get(
      Uri.parse("$apiBaseUrl/tasks"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      final errorData = jsonDecode(res.body);
      final errorMessage = errorData['message'] as String;
      throw Exception(errorMessage);
    }
  }

  Future<void> updateTask(String id, String title, String description, String status) async {
  final token = await _getToken();
  if (token == null) throw Exception("Token not found. Please log in.");

  final res = await http.put(
    Uri.parse("$apiBaseUrl/tasks/$id"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({
      "title": title,
      "description": description,
      "status": status,
    }),
  );

  if (res.statusCode != 200) {
    final errorData = jsonDecode(res.body);
    final errorMessage = errorData['message'] is List
      ? (errorData['message'] as List).join(', ')
      : errorData['message'] as String;
    throw Exception(errorMessage);
  }
}

  Future<void> deleteTask(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token not found. Please log in.");

    final res = await http.delete(
      Uri.parse("$apiBaseUrl/tasks/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      final errorData = jsonDecode(res.body);
      final errorMessage = errorData['message'] as String;
      throw Exception(errorMessage);
    }
  }
}