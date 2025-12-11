import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';

class LiquidMetalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const LiquidMetalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(30), // Más padding interno
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        // Gradiente oscuro "Ahumado"
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2C2C2C).withOpacity(0.9), // Gris oscuro arriba
            const Color(0xFF000000).withOpacity(0.95), // Casi negro abajo
          ],
        ),
        // Bordes metálicos afilados
        border: Border.all(
          color: Colors.white.withOpacity(0.1), // Borde fino claro
          width: 1,
        ),
        boxShadow: [
          // Sombra exterior profunda
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            offset: const Offset(10, 10),
            blurRadius: 20,
          ),
          // "Bisel" de luz superior (Efecto borde cromado)
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            offset: const Offset(-2, -2),
            blurRadius: 4,
            spreadRadius: 1,
            inset: true, // Sombra interna
          ),
          // "Bisel" de sombra inferior
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 4,
            spreadRadius: 1,
            inset: true,
          ),
        ],
      ),
      child: child,
    );
  }
}