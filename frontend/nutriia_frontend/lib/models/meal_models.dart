class Meal {
  final int id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final String? imageUrl;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.imageUrl,
    required this.createdAt,
  });

  // Factory constructor para crear una instancia de Meal desde un mapa (JSON)
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as int,
      name: json['name'] as String,
      calories: json['calories'] as int,
      // Aseguramos que los macros se lean como double, incluso si vienen como int
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Método para convertir el objeto a mapa (útil si necesitas enviar datos de vuelta)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}