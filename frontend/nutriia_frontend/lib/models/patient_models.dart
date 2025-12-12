class Patient {
  final int id; // puede ser patient_id o user_id según tu backend
  final String fullName;
  final String email;

  Patient({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: (json['id'] as num).toInt(),
      fullName: (json['full_name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
    );
  }
}
