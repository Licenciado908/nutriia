import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/indicator_model.dart';
import 'auth_api.dart';

class IndicatorsApi {
  // ✅ GET /patients/{id}/indicators
  Future<List<Indicator>> getIndicators(int patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final uri = Uri.parse('${AuthApi.baseUrl}/patients/$patientId/indicators');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => Indicator.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  // ✅ POST /patients/{id}/indicators
  Future<void> createIndicator({
    required int patientId,
    required double weight,
    required double bmi,
    required double fatPercent,
    String? note,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final uri = Uri.parse('${AuthApi.baseUrl}/patients/$patientId/indicators');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'weight': weight,
        'bmi': bmi,
        'fat_percent': fatPercent,
        'note': note,
      }),
    );

    // tu backend devuelve 201
    if (response.statusCode != 201) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
