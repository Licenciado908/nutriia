import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutriia_frontend/pages/nutritionist_home_page.dart';
import 'package:nutriia_frontend/services/auth_api.dart';
import '../widgets/liquid_metal_card.dart';
import '../widgets/liquid_background.dart';
import 'main_shell.dart';

enum UserType {
  paciente,
  nutricionista,
}

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
  final _nutriEmailController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;

  UserType _selectedType = UserType.paciente;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nutriEmailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final nutriEmail = _nutriEmailController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Llena los campos obligatorios')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // LOGIN NORMAL → por ahora todos van a MainShell
        final auth = await _authApi.login(
  email: email,
  password: password,
);

if (!mounted) return;

final role = auth.user.role.toLowerCase();

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => role == 'nutricionista'
        ? const NutritionistHomePage()
        : const MainShell(),
  ),
);

      } else {
        // REGISTRO
        if (name.isEmpty) {
          throw Exception("Nombre obligatorio");
        }

        if (_selectedType == UserType.paciente) {
          // REGISTRO PACIENTE
          if (nutriEmail.isEmpty) {
            throw Exception("Debes ingresar el email de tu nutricionista.");
          }

          await _authApi.registerPatient(
            fullName: name,
            email: email,
            password: password,
            nutritionistEmail: nutriEmail,
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Paciente registrado! Ahora inicia sesión.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isLogin = true;
            _passwordController.clear();
            _nutriEmailController.clear();
          });
        } else {
          // REGISTRO NUTRICIONISTA → SOLO MENSAJE
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'El registro de nutricionistas lo gestiona Recursos Humanos.\n'
                'Por favor, ponte en contacto con el departamento de RRHH.',
              ),
              backgroundColor: Colors.orangeAccent,
            ),
          );
          // No llamamos a ningún endpoint aquí.
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll("Exception:", "").trim(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
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
                // LOGO
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFAFAFAF), Color(0xFF505050)],
                    stops: [0.1, 0.5, 0.9],
                  ).createShader(bounds),
                  child: const Icon(Icons.psychology, size: 70, color: Colors.white),
                ),

                const SizedBox(height: 10),

                // TÍTULO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'nutri',
                      style: GoogleFonts.syne(
                        fontSize: 65,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -2.0,
                        height: 0.9,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xFFB0BEC5), Color(0xFF37474F)],
                      ).createShader(bounds),
                      child: Text(
                        'IA',
                        style: GoogleFonts.syne(
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 0.9,
                        ),
                      ),
                    ),
                  ],
                ),

                // SLOGAN
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
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // TARJETA DE FORMULARIO
                LiquidMetalCard(
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        _buildInput(
                          _nameController,
                          'NOMBRE COMPLETO',
                          Icons.person,
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildInput(
                        _emailController,
                        'EMAIL',
                        Icons.alternate_email,
                      ),
                      const SizedBox(height: 20),
                      _buildInput(
                        _passwordController,
                        'CONTRASEÑA',
                        Icons.lock,
                        obscure: true,
                      ),
                      const SizedBox(height: 20),

                      if (!_isLogin) ...[
                        _buildUserTypeSelector(),
                        const SizedBox(height: 20),

                        if (_selectedType == UserType.paciente) ...[
                          _buildInput(
                            _nutriEmailController,
                            'EMAIL DE TU NUTRICIONISTA',
                            Icons.medical_information,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],

                      const SizedBox(height: 20),

                      // BOTÓN PRINCIPAL
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
                              color: _isLogin
                                  ? Colors.green.withOpacity(0.4)
                                  : Colors.greenAccent.withOpacity(0.6),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _isLogin ? 'ACCEDER' : 'CREAR CUENTA',
                                  style: GoogleFonts.syne(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // SWITCH LOGIN / REGISTRO
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? '¿PRIMERA VEZ? CREA TU CUENTA'
                        : 'YA TENGO CUENTA',
                    style: GoogleFonts.syne(
                      color: Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.green,
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

  Widget _buildInput(
    TextEditingController c,
    String l,
    IconData i, {
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: c,
        obscureText: obscure,
        style: GoogleFonts.syne(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(i, color: Colors.white54, size: 20),
          labelText: l,
          labelStyle: GoogleFonts.syne(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = UserType.paciente;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _selectedType == UserType.paciente
                    ? const Color(0xFF00C853).withOpacity(0.2)
                    : Colors.black.withOpacity(0.4),
                border: Border.all(
                  color: _selectedType == UserType.paciente
                      ? Colors.greenAccent
                      : Colors.white10,
                ),
              ),
              child: Center(
                child: Text(
                  'SOY PACIENTE',
                  style: GoogleFonts.syne(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = UserType.nutricionista;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _selectedType == UserType.nutricionista
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.4),
                border: Border.all(
                  color: _selectedType == UserType.nutricionista
                      ? Colors.white70
                      : Colors.white10,
                ),
              ),
              child: Center(
                child: Text(
                  'SOY NUTRICIONISTA',
                  style: GoogleFonts.syne(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
