import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$apiBaseUrl/auth/signin"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["access_token"]);

      return data;
    } else {
      throw Exception("Error al iniciar sesión: ${res.body}");
    }
  }

  Future<Map<String, dynamic>> register(String name, String lastName,String email, String password) async {
    final res = await http.post(
      Uri.parse("$apiBaseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "lastName": lastName,
        "email": email,
        "password": password,
        }),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["access_token"]);

      return data;
    } else {
      throw Exception("Error al registrarse: ${res.body}");
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
