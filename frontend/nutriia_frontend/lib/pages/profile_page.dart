import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../widgets/liquid_metal_card.dart';
import '../services/auth_api.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = 'Cargando...';
  String _userEmail = '';
  String _userRole = '';
  final _authApi = AuthApi();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Usuario';
      _userEmail = prefs.getString('user_email') ?? 'sin email';
      _userRole = prefs.getString('user_role') ?? 'paciente';
    });
  }

  Future<void> _logout() async {
    await _authApi.logout();
    if (!mounted) return;
    // Navegar al Login y borrar historial de navegación
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // No necesitamos Scaffold ni LiquidBackground aquí porque MainShell ya los tiene.
    // Usamos Container transparente para mostrar el contenido sobre el fondo del Shell.
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- AVATAR CROMADO CON ANILLO DE ENERGÍA ---
              Stack(
                alignment: Alignment.center,
                children: [
                  // Resplandor verde trasero
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10
                          )
                        ]
                    ),
                  ),
                  // Borde metálico
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      gradient: const LinearGradient(
                          colors: [Color(0xFF424242), Color(0xFF212121)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight
                      ),
                    ),
                    child: const Icon(Icons.person, size: 60, color: Colors.white70),
                  ),
                  // Indicador "Online"
                  Positioned(
                    bottom: 5, right: 5,
                    child: Container(
                      width: 25, height: 25,
                      decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.8), blurRadius: 10)]
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.black),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 25),

              // NOMBRE DE USUARIO (Fuente Syne)
              Text(
                _userName.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                    shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2,2))]
                ),
              ),

              // ROL (Etiqueta Tech)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.3))
                ),
                child: Text(
                  _userRole.toUpperCase(),
                  style: GoogleFonts.syne(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- GRID DE ESTADÍSTICAS ---
              Row(
                children: [
                  Expanded(child: _buildStatCard('DIAS', '12', Icons.calendar_today)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStatCard('STATUS', 'ACTIVO', Icons.local_activity, isHighlited: true)),
                ],
              ),

              const SizedBox(height: 20),

              // --- LISTA DE OPCIONES (METAL CARD) ---
              LiquidMetalCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  children: [
                    _buildListTile(Icons.email_outlined, 'EMAIL', _userEmail),
                    _buildDivider(),
                    _buildListTile(Icons.settings_outlined, 'CONFIGURACIÓN', 'Ajustes de cuenta'),
                    _buildDivider(),
                    _buildListTile(Icons.notifications_outlined, 'NOTIFICACIONES', 'Activadas'),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- BOTÓN CERRAR SESIÓN ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.redAccent.withOpacity(0.3))
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                      'CERRAR SESIÓN',
                      style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {bool isHighlited = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlited ? const Color(0xFF00C853).withOpacity(0.15) : Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
            color: isHighlited ? Colors.greenAccent.withOpacity(0.3) : Colors.white10
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isHighlited ? Colors.white : Colors.white38, size: 24),
          const SizedBox(height: 10),
          Text(
              value,
              style: GoogleFonts.syne(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white
              )
          ),
          Text(
              label,
              style: GoogleFonts.syne(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isHighlited ? Colors.greenAccent : Colors.white38,
                  letterSpacing: 1.5
              )
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: GoogleFonts.syne(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 14),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 1,
      color: Colors.white.withOpacity(0.05),
    );
  }
}