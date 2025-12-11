import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/meal_models.dart';
import '../services/meals_api.dart';
import '../widgets/liquid_metal_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Meal>> _mealsFuture;
  final _mealsApi = MealsApi();

  @override
  void initState() {
    super.initState();
    _mealsFuture = _mealsApi.getMeals();
  }

  // Función para recargar la lista al volver de la cámara
  Future<void> _refreshMeals() async {
    setState(() {
      _mealsFuture = _mealsApi.getMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos RefreshIndicator para poder deslizar hacia abajo y actualizar
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TU DIARIO', style: GoogleFonts.syne(color: Colors.white54, fontSize: 14, letterSpacing: 2)),
                      Text('historial.', style: GoogleFonts.syne(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white10)
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.white),
                  )
                ],
              ),
            ),

            // LISTA
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshMeals,
                color: const Color(0xFF00C853),
                backgroundColor: Colors.black,
                child: FutureBuilder<List<Meal>>(
                  future: _mealsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error de conexión.\nVerifica tu backend.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.syne(color: Colors.redAccent),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.no_food, size: 50, color: Colors.white12),
                              const SizedBox(height: 10),
                              Text('Aún no tienes registros.', style: GoogleFonts.syne(color: Colors.white38)),
                            ],
                          )
                      );
                    }

                    final meals = snapshot.data!;
                    return ListView.builder(
                      // Dejamos espacio abajo para que la barra de navegación no tape el último item
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: meals.length,
                      itemBuilder: (context, index) => _buildMealCard(meals[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: LiquidMetalCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header de la tarjeta
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      DateFormat('hh:mm a').format(meal.createdAt),
                      style: GoogleFonts.syne(color: Colors.white54, fontWeight: FontWeight.bold)
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3))
                    ),
                    child: Text(
                        '${meal.calories} KCAL',
                        style: GoogleFonts.syne(color: const Color(0xFF00C853), fontWeight: FontWeight.w900, fontSize: 12)
                    ),
                  )
                ],
              ),
            ),
            // Cuerpo de la tarjeta
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Imagen o Placeholder
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xFF1E1E1E),
                        border: Border.all(color: Colors.white10),
                        image: meal.imageUrl != null
                            ? DecorationImage(image: NetworkImage(meal.imageUrl!), fit: BoxFit.cover)
                            : null
                    ),
                    child: meal.imageUrl == null
                        ? const Icon(Icons.restaurant_menu, color: Colors.white24)
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            meal.name,
                            style: GoogleFonts.syne(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 5),
                        Text(
                            'P: ${meal.protein.toInt()}g  •  C: ${meal.carbs.toInt()}g  •  G: ${meal.fats.toInt()}g',
                            style: GoogleFonts.syne(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}