class Indicator {
  final int id;
  final double weight;
  final double bmi;
  final double fatPercent;
  final DateTime createdAt;
  final String? note;

  Indicator({
    required this.id,
    required this.weight,
    required this.bmi,
    required this.fatPercent,
    required this.createdAt,
    this.note,
  });

  factory Indicator.fromJson(Map<String, dynamic> json) {
    return Indicator(
      id: (json['id'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      fatPercent: (json['fat_percent'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      note: json['note'],
    );
  }
}
