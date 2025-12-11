import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_api.dart'; // Para obtener la baseUrl

class IaApi {
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // Endpoint que creamos en el backend
    final uri = Uri.parse('${AuthApi.baseUrl}/meals/analyze');

    // Preparamos la petición Multipart (Subida de archivo)
    final request = http.MultipartRequest('POST', uri);

    // Adjuntamos el token de seguridad
    request.headers['Authorization'] = 'Bearer $token';

    // Adjuntamos la imagen
    // 'file' es el nombre del parámetro que definimos en Python (file: UploadFile)
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    // Enviamos
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // Gemini nos devolvió el JSON con calorías!
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al analizar: ${response.body}');
    }
  }
}