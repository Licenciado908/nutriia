import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient_models.dart';
import 'auth_api.dart';

class PatientsApi {
  Future<List<Patient>> getMyPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final uri = Uri.parse('${AuthApi.baseUrl}/patients');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
    }

    throw Exception('Error cargando pacientes: ${response.body}');
  }
}
