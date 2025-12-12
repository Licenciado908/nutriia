// lib/pages/nutritionist_home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NutritionistHomePage extends StatelessWidget {
  const NutritionistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Panel Nutricionista',
          style: GoogleFonts.syne(),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Aquí irá la lista de pacientes y sus planes 🧬',
          textAlign: TextAlign.center,
          style: GoogleFonts.syne(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
