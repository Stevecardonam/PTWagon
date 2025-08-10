import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

// Clase de excepción personalizada para manejar errores de la API.
class ApiException implements Exception {
  final String message;
  final int statusCode; // Contiene un [message] para el usuario y el [statusCode] de la respuesta HTTP.

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: [Status Code $statusCode] $message';
}

class TaskService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  void _handleError(http.Response res) {
    // Si la respuesta no es exitosa, decodificamos el cuerpo del error.
    if (res.statusCode >= 400) {
      String errorMessage = "Ocurrió un error inesperado.";
      try {
        final errorData = jsonDecode(res.body);
        if (errorData.containsKey('message')) {
          // El backend de NestJS puede devolver el mensaje como un String o una lista.
          if (errorData['message'] is List) {
            errorMessage = (errorData['message'] as List).join(', ');
          } else {
            errorMessage = errorData['message'] as String;
          }
        }
      } catch (e) {
        // En caso de que el cuerpo de la respuesta no sea JSON.
        errorMessage = "Error al decodificar la respuesta del servidor: ${res.body}";
      }
      throw ApiException(errorMessage, res.statusCode);
    }
  }

// Crea una nueva tarea en el servidor.
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

    _handleError(res);

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw ApiException("Failed to create task", res.statusCode);
    }
  }

// Obtiene todas las tareas del usuario desde el servidor.
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

    _handleError(res);

    return jsonDecode(res.body);
  }

// Actualiza una tarea existente.
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

  _handleError(res);
  }

// Elimina una tarea del servidor.
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

      _handleError(res);
  }
}