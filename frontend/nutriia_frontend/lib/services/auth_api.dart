import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';

class AuthApi {
  // AJUSTA ESTA URL SEGÚN TU ENTORNO
  // - Emulador Android (backend en tu PC): http://10.0.2.2:8002
  // - Dispositivo físico en la misma red que tu PC: http://TU_IP_LOCAL:8002
  // - iOS simulator (backend en tu Mac): http://localhost:8002
  static const String baseUrl = 'http://10.0.2.2:8002';
  // Si tú estabas usando otra (ej: 10.224.85.135), ponla aquí si sabes que funciona.

  // ============================
  // LOGIN
  // ============================
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    print('DEBUG login → POST $uri');
    print('DEBUG body → {"email": "$email", "password": "****"}');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,      // 👈 tu backend espera "email"
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 8));

      print('DEBUG statusCode → ${response.statusCode}');
      print('DEBUG response.body → ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final auth = AuthResponse.fromJson(data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', auth.accessToken);
        await prefs.setString('user_email', auth.user.email);
        await prefs.setString('user_name', auth.user.fullName);
        await prefs.setString('user_role', auth.user.role);
        await prefs.setInt('user_id', auth.user.id);

        print('DEBUG login OK → role=${auth.user.role}');
        return auth;
      } else {
        String message = 'Error desconocido';
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          message = data['detail']?.toString() ?? message;
        } catch (_) {
          if (response.body.isNotEmpty) {
            message = response.body;
          }
        }
        throw Exception('Error al iniciar sesión: $message');
      }
    } on TimeoutException {
      print('DEBUG login TIMEOUT');
      throw Exception(
        'No se pudo conectar al servidor (timeout). Revisa la IP/puerto del backend.',
      );
    } catch (e) {
      print('DEBUG login EXCEPTION → $e');
      rethrow;
    }
  }

  // ============================
  // REGISTRO NUTRICIONISTA (opcional)
  // ============================
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register-nutri');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String message = 'Error al registrarse como nutricionista';
      try {
        final data = jsonDecode(response.body);
        message = data['detail']?.toString() ?? message;
      } catch (_) {
        message = 'Error ${response.statusCode}: ${response.body}';
      }
      throw Exception(message);
    }
  }

  // ============================
  // REGISTRO PACIENTE
  // ============================
  Future<void> registerPatient({
    required String fullName,
    required String email,
    required String password,
    required String nutritionistEmail,
  }) async {
    final uri = Uri.parse('${AuthApi.baseUrl}/auth/register-patient');

    print('DEBUG registerPatient → POST $uri');
    print('DEBUG body → full_name=$fullName, email=$email, nutritionist_email=$nutritionistEmail');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'nutritionist_email': nutritionistEmail,
      }),
    );

    print('DEBUG registerPatient statusCode → ${response.statusCode}');
    print('DEBUG registerPatient body → ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      String message = 'Error al registrarse como paciente';
      try {
        final data = jsonDecode(response.body);
        message = data['detail']?.toString() ?? message;
      } catch (_) {
        message = 'Error ${response.statusCode}: ${response.body}';
      }
      throw Exception(message);
    }
  }

  // ============================
  // OBTENER TOKEN GUARDADO
  // ============================
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
  }
}
