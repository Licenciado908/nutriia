import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidChromeBackground extends StatefulWidget {
  final Widget child;
  const LiquidChromeBackground({super.key, required this.child});

  @override
  State<LiquidChromeBackground> createState() => _LiquidChromeBackgroundState();
}

class _LiquidChromeBackgroundState extends State<LiquidChromeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          color: const Color(0xFF0A0E0C), // Negro verdoso muy profundo (Orgánico)
          child: Stack(
            children: [
              // GOTA 1: Aceite/Célula (Verde oscuro)
              Positioned(
                top: -100 + (_controller.value * 50),
                right: -50,
                child: _buildBlob(300, const Color(0xFF1B5E20).withOpacity(0.4)),
              ),

              // GOTA 2: Mercurio (Plateado)
              Positioned(
                bottom: 100 - (_controller.value * 30),
                left: -80,
                child: _buildBlob(350, const Color(0xFFB0BEC5).withOpacity(0.3)),
              ),

              // GOTA 3: Nutriente (Verde lima sutil)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                left: MediaQuery.of(context).size.width * 0.5 + (_controller.value * 40),
                child: _buildBlob(200, const Color(0xFFC6FF00).withOpacity(0.15)),
              ),

              // FILTRO DE FLUIDEZ (Metaballs effect simulation)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),

              // RUIDO GRÁFICO (Textura de papel/metal)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.02),
                      Colors.black.withOpacity(0.02),
                    ],
                  ),
                ),
              ),

              widget.child,
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}