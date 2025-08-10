import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Traducciones centralizadas de mensajes de error del backend.
const Map<String, String> _errorTranslations = {
  "User already exists": "Ya existe un usuario registrado con este email.",
  "password must include upper/lowercase letters, a number, a special character (!@#\$%^&*), and be 8-15 characters long":
      "La contraseña debe tener entre 8 y 15 caracteres, incluyendo al menos una mayúscula, una minúscula, un número y un carácter especial (!@#\$%^&*).",
  "name must be longer than or equal to 3 characters": "El nombre debe tener al menos 3 caracteres.",
  "name must be shorter than or equal to 80 characters": "El nombre no puede exceder los 80 caracteres.",
  "lastName must be longer than or equal to 3 characters": "El apellido debe tener al menos 3 caracteres.",
  "lastName must be shorter than or equal to 80 characters": "El apellido no puede exceder los 80 caracteres.",
  "email must be an email": "Por favor, ingresa un email válido.",
};

/// Excepción personalizada para manejar errores del servidor.
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class AuthService {
  final String _authBaseUrl = "$apiBaseUrl/auth";

  /// Método centralizado para procesar respuestas del servidor.
  dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    try {
      final errorData = jsonDecode(res.body);
      final message = errorData['message'];

      // Manejo específico para listas de errores
      if (message is List) {
        final translated = message
            .map((msg) => _errorTranslations[msg.toString()] ?? msg.toString())
            .join('\n');
        throw ServerException(translated);
      }

      // Manejo específico para mensajes individuales
      if (message is String) {
        final translated = _errorTranslations[message] ?? message;
        throw ServerException(translated);
      }

      // Fallback para respuestas desconocidas
      throw ServerException("Error del servidor: ${res.statusCode}");
    } catch (_) {
      // Manejo de errores no JSON o problemas de conexión
      if (res.statusCode == 409) {
        throw ServerException("Ya existe un usuario con este email.");
      } else if (res.statusCode == 401 || res.statusCode == 400){
        throw ServerException("Usuario o contraseña invalidas.");
      }
      throw ServerException("Error de conexión: ${res.statusCode}");
    }
  }

  /// Guarda el token de forma segura.
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  /// Login de usuario.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$_authBaseUrl/signin"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = _handleResponse(res);
    await _saveToken(data["access_token"]);
    return data;
  }

  /// Registro de usuario.
  Future<Map<String, dynamic>> register(
      String name, String lastName, String email, String password) async {
    final res = await http.post(
      Uri.parse("$_authBaseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "lastName": lastName,
        "email": email,
        "password": password,
      }),
    );

    return _handleResponse(res);
  }

  /// Obtiene el token almacenado.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /// Elimina el token (logout).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
