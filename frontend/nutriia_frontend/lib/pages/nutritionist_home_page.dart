import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutriia_frontend/pages/login_page.dart';
import 'package:nutriia_frontend/services/auth_api.dart';

import '../models/patient_models.dart';
import '../services/patients_api.dart';
import '../widgets/liquid_background.dart';
import '../widgets/liquid_metal_card.dart';
import 'patient_monitor_page.dart';

class NutritionistHomePage extends StatefulWidget {
  const NutritionistHomePage({super.key});

  @override
  State<NutritionistHomePage> createState() => _NutritionistHomePageState();
}

class _NutritionistHomePageState extends State<NutritionistHomePage> {
  final _api = PatientsApi();
  late Future<List<Patient>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getMyPatients();
  }

  Future<void> _refresh() async {
    setState(() => _future = _api.getMyPatients());
  }

  @override
  Widget build(BuildContext context) {
    return LiquidChromeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
  title: Text(
    'Panel Nutricionista',
    style: GoogleFonts.syne(fontWeight: FontWeight.w800),
  ),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Cerrar sesión',
      onPressed: () async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Deseas cerrar sesión?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salir')),
      ],
    ),
  );

  if (confirm != true) return;

  await AuthApi().logout();
  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
},

    ),
  ],
),

        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Patient>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    'Error cargando pacientes.\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.syne(color: Colors.redAccent),
                  ),
                );
              }

              final patients = snap.data ?? [];
              if (patients.isEmpty) {
                return Center(
                  child: Text(
                    'Aún no tienes pacientes asignados.',
                    style: GoogleFonts.syne(color: Colors.white54),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                itemCount: patients.length,
                itemBuilder: (_, i) => _patientCard(patients[i]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _patientCard(Patient p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PatientMonitorPage(patient: p)),
          );
        },
        child: LiquidMetalCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(Icons.person, color: Colors.white70),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.fullName, style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(p.email, style: GoogleFonts.syne(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
