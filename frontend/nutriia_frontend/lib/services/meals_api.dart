import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_models.dart';
import 'auth_api.dart'; // Usamos esto para obtener la baseUrl común

class MealsApi {

  // OBTENER HISTORIAL (GET)
  Future<List<Meal>> getMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final uri = Uri.parse('${AuthApi.baseUrl}/meals/');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar historial: ${response.body}');
    }
  }

  // REGISTRAR NUEVA COMIDA (POST)
  Future<void> registerMeal({
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fats,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final uri = Uri.parse('${AuthApi.baseUrl}/meals/');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'image_url': null, // Por ahora null, más adelante podrías subir la foto a S3/Firebase
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al guardar comida: ${response.body}');
    }
  }
}