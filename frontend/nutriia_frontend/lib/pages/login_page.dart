import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_api.dart';
import '../widgets/liquid_metal_card.dart';
import '../widgets/liquid_background.dart';
import 'main_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authApi = AuthApi();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Llena los campos obligatorios')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _authApi.login(email: email, password: password);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
      } else {
        if (name.isEmpty) throw Exception("Nombre obligatorio");
        await _authApi.register(email: email, password: password, fullName: name);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Cuenta creada! Inicia sesión.'), backgroundColor: Colors.green));
        setState(() { _isLogin = true; _passwordController.clear(); });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception:", "").trim()), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LiquidChromeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. LOGO (Tamaño medio para no robar protagonismo al texto)
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFAFAFAF), Color(0xFF505050)],
                    stops: [0.1, 0.5, 0.9],
                  ).createShader(bounds),
                  child: const Icon(Icons.psychology, size: 70, color: Colors.white),
                ),

                const SizedBox(height: 10),

                // 2. TÍTULO DE LA APP (JERARQUÍA MÁXIMA)
                // Aumentado drásticamente para ser el elemento visual dominante
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                        'nutri',
                        style: GoogleFonts.syne(
                            fontSize: 65, // Aumentado de 50 a 65
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -2.0,
                            height: 0.9 // Compacta la línea
                        )
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xFFB0BEC5), Color(0xFF37474F)],
                      ).createShader(bounds),
                      child: Text(
                          'IA',
                          style: GoogleFonts.syne(
                              fontSize: 80, // Aumentado de 60 a 80 (GIGANTE)
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 0.9
                          )
                      ),
                    ),
                  ],
                ),

                // 3. SLOGAN (JERARQUÍA BAJA - Detalle sutil)
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
                  ),
                  child: Text(
                    'TU ACOMPAÑANTE NUTRICIONAL',
                    style: GoogleFonts.syne(
                      color: Colors.greenAccent,
                      fontSize: 11, // Reducido ligeramente para elegancia
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.0, // Muy espaciado para diferenciar del título
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // TARJETA DE FORMULARIO
                LiquidMetalCard(
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        _buildInput(_nameController, 'NOMBRE COMPLETO', Icons.person),
                        const SizedBox(height: 20),
                      ],
                      _buildInput(_emailController, 'EMAIL', Icons.alternate_email),
                      const SizedBox(height: 20),
                      _buildInput(_passwordController, 'CONTRASEÑA', Icons.lock, obscure: true),
                      const SizedBox(height: 40),

                      // 4. BOTÓN DE ACCIÓN (JERARQUÍA MEDIA)
                      // Texto reducido a 18px para que no compita con el título de 80px
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            gradient: LinearGradient(
                              colors: _isLogin
                                  ? [const Color(0xFF2E7D32), const Color(0xFF43A047)]
                                  : [const Color(0xFF00C853), const Color(0xFF69F0AE)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: _isLogin ? Colors.green.withOpacity(0.4) : Colors.greenAccent.withOpacity(0.6),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5)
                              )
                            ]
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                              _isLogin ? 'ACCEDER' : 'CREAR CUENTA',
                              style: GoogleFonts.syne(
                                  fontSize: 18, // Reducido para equilibrar (antes 22)
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 2
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // TEXTO DE CAMBIO (JERARQUÍA MÍNIMA)
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? '¿PRIMERA VEZ? CREA TU CUENTA' : 'YA TENGO CUENTA',
                    style: GoogleFonts.syne(
                        color: Colors.white60,
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // Pequeño y funcional
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.green
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String l, IconData i, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: c, obscureText: obscure,
        style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(i, color: Colors.white54, size: 20),
          labelText: l,
          labelStyle: GoogleFonts.syne(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}