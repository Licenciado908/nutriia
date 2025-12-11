import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <--- Importante
import 'pages/login_page.dart';

void main() {
  runApp(const NutriIAApp());
}

class NutriIAApp extends StatelessWidget {
  const NutriIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriIA',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505), // Fondo de respaldo negro profundo
        // Configuración Global de la Fuente Syne
        textTheme: GoogleFonts.syneTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C853),
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}