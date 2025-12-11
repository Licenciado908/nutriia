import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthApi {
  // Ajusta esta IP según tu entorno:
  // - Emulador Android: 'http://10.0.2.2:8002'
  // - Dispositivo Físico: 'http://192.168.x.x:8002' (Tu IP local)
  // - iOS Simulador: 'http://localhost:8002'
  static const String baseUrl = 'http://10.224.85.135:8002';

  // --- LOGIN ---
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': email, // OAuth2PasswordRequestForm espera 'username', no 'email'
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final auth = AuthResponse.fromJson(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', auth.accessToken);
      await prefs.setString('user_email', auth.user.email);
      await prefs.setString('user_name', auth.user.fullName);
      await prefs.setString('user_role', auth.user.role);

      return auth;
    } else {
      String message = 'Error desconocido';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        message = data['detail']?.toString() ?? message;
      } catch (_) {}
      throw Exception('Error al iniciar sesión: $message');
    }
  }

  // --- REGISTRO ---
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName, // Coincide con UserRegister en Python
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String message = 'Error al registrarse';
      try {
        final data = jsonDecode(response.body);
        message = data['detail']?.toString() ?? message;
      } catch (_) {
        message = 'Error ${response.statusCode}: ${response.body}';
      }
      throw Exception(message);
    }
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
  }
}