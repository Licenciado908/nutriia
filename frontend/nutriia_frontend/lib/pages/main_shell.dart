import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../widgets/liquid_background.dart'; // Tu fondo global
import '../services/ia_api.dart';
import '../services/meals_api.dart';
import '../widgets/liquid_metal_card.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Instancias de las APIs
  final _iaApi = IaApi();
  final _mealsApi = MealsApi();

  bool _isAnalyzing = false;

  final List<Widget> _pages = [
    const HomePage(),
    const SizedBox(), // Placeholder invisible (el botón central flota encima)
    const ProfilePage(),
  ];

  // --- LÓGICA DE CÁMARA E IA ---
  Future<void> _onCameraTap() async {
    final picker = ImagePicker();
    // Usa ImageSource.gallery si estás en simulador y no tienes cámara
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo == null) return; // Usuario canceló

    setState(() => _isAnalyzing = true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Analizando composición molecular...'),
          backgroundColor: Colors.black87,
        )
    );

    try {
      final File imageFile = File(photo.path);
      // 1. Enviar a Gemini
      final result = await _iaApi.analyzeImage(imageFile);

      if (!mounted) return;
      // 2. Mostrar resultados
      _showAnalysisResult(result, imageFile);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  // --- MODAL DE RESULTADOS (DISEÑO BIO-DIGITAL) ---
  void _showAnalysisResult(Map<String, dynamic> data, File imageFile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
            color: const Color(0xFF0A0E0C), // Fondo orgánico muy oscuro
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 50, spreadRadius: 0)
            ]
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle (Barrita)
            Center(
                child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))
                )
            ),
            const SizedBox(height: 30),

            Text(
                'ANÁLISIS COMPLETADO',
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                    color: const Color(0xFF00E676),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 2.0
                )
            ),
            const SizedBox(height: 30),

            // FOTO Y NOMBRE
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5))
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(imageFile, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          (data['name'] ?? 'Desconocido').toString().toLowerCase(), // Estilo minúsculas
                          style: GoogleFonts.syne(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      Text(
                          'DETECTADO POR IA',
                          style: GoogleFonts.syne(color: Colors.white38, fontSize: 10, letterSpacing: 2)
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // TARJETA DE MACROS
            LiquidMetalCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _macroItem('KCAL', '${data['calories']}', Colors.white),
                  _buildDivider(),
                  _macroItem('PROT', '${data['protein']}g', const Color(0xFF69F0AE)),
                  _buildDivider(),
                  _macroItem('CARBS', '${data['carbs']}g', const Color(0xFFFFD740)),
                ],
              ),
            ),

            const Spacer(),

            // BOTÓN GUARDAR
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('💾 Guardando en tu diario bio-digital...')),
                    );

                    // Guardar en Backend
                    await _mealsApi.registerMeal(
                      name: data['name'] ?? 'Comida',
                      calories: (data['calories'] as num).toInt(),
                      protein: (data['protein'] as num).toDouble(),
                      carbs: (data['carbs'] as num).toDouble(),
                      fats: (data['fats'] as num).toDouble(),
                    );

                    if (!mounted) return;
                    Navigator.pop(context); // Cerrar modal

                    // Ir al Home para ver el nuevo item
                    setState(() { _currentIndex = 0; });

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: Colors.greenAccent.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                    'REGISTRAR COMIDA',
                    style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1)
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _macroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.syne(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(label, style: GoogleFonts.syne(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.white10);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidChromeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // PÁGINAS PRINCIPALES
            IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),

            // BARRA DE NAVEGACIÓN FLOTANTE (ESTILO CÁPSULA)
            Positioned(
              bottom: 30, left: 25, right: 25,
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: const Color(0xFF0F1412).withOpacity(0.9), // Casi negro
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Botón Home
                    _navItem(Icons.grid_view_rounded, 0),

                    // BOTÓN CÁMARA (FLOTANTE Y RESPLANDECIENTE)
                    Transform.translate(
                      offset: const Offset(0, -25),
                      child: GestureDetector(
                        onTap: () => _onCameraTap(),
                        child: Container(
                          height: 70, width: 70,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Gradiente "Bio-Luminiscente"
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00E676), Color(0xFF00C853)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF00E676).withOpacity(0.6),
                                    blurRadius: 25,
                                    spreadRadius: 2
                                )
                              ],
                              border: Border.all(color: Colors.white, width: 2)
                          ),
                          child: _isAnalyzing
                              ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white))
                              : const Icon(Icons.qr_code_scanner, color: Colors.black, size: 30),
                        ),
                      ),
                    ),

                    // Botón Perfil
                    _navItem(Icons.person_rounded, 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white24,
          size: 28
      ),
      onPressed: () => setState(() => _currentIndex = index),
    );
  }
}