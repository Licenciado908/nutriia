import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_models.dart';
import '../widgets/liquid_background.dart';
import '../widgets/liquid_metal_card.dart';

class PatientMonitorPage extends StatefulWidget {
  final Patient patient;
  const PatientMonitorPage({super.key, required this.patient});

  @override
  State<PatientMonitorPage> createState() => _PatientMonitorPageState();
}

class _PatientMonitorPageState extends State<PatientMonitorPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return LiquidChromeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.patient.fullName, style: GoogleFonts.syne(fontWeight: FontWeight.w800)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: _tabs(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: IndexedStack(
                    index: _tab,
                    children: const [
                      _IndicatorsTab(),
                      _HabitsTab(),
                      _ProgressTab(),
                      _AlertsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    Widget pill(String text, int index) {
      final selected = _tab == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: selected ? const Color(0xFF00C853).withOpacity(0.18) : Colors.black.withOpacity(0.35),
              border: Border.all(color: selected ? Colors.greenAccent : Colors.white10),
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.syne(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill('INDICADORES', 0),
        const SizedBox(width: 8),
        pill('HÁBITOS', 1),
        const SizedBox(width: 8),
        pill('PROGRESO', 2),
        const SizedBox(width: 8),
        pill('ALERTAS', 3),
      ],
    );
  }
}

class _IndicatorsTab extends StatelessWidget {
  const _IndicatorsTab();

  @override
  Widget build(BuildContext context) {
    // UI lista para “visualizar y registrar” indicadores.
    // Cuando tengas endpoints, aquí solo cambias el FutureBuilder.
    return ListView(
      children: [
        LiquidMetalCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Indicadores nutricionales', style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Peso, IMC, %grasa, cintura, etc.', style: GoogleFonts.syne(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 16),
              _row('Peso', '— kg'),
              _row('IMC', '—'),
              _row('% grasa', '— %'),
              _row('Cintura', '— cm'),
              const SizedBox(height: 16),
              _primaryButton('REGISTRAR NUEVO INDICADOR', () {
                // Aquí abrimos un modal/form.
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String a, String b) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(a, style: GoogleFonts.syne(color: Colors.white70, fontWeight: FontWeight.w700)),
          Text(b, style: GoogleFonts.syne(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _primaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(text, style: GoogleFonts.syne(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}

class _HabitsTab extends StatelessWidget {
  const _HabitsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        LiquidMetalCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hábitos', style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Agua, sueño, actividad, adherencia al plan.', style: GoogleFonts.syne(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 16),
              _item('Agua', '— L/día'),
              _item('Sueño', '— h'),
              _item('Actividad', '— min'),
              _item('Adherencia', '— %'),
              const SizedBox(height: 16),
              _hint('Cuando el backend tenga endpoints, esto será un historial por día/semana.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: GoogleFonts.syne(color: Colors.white70, fontWeight: FontWeight.w700)),
        Text(b, style: GoogleFonts.syne(color: Colors.white38)),
      ],
    ),
  );

  Widget _hint(String text) => Text(text, style: GoogleFonts.syne(color: Colors.white24, fontSize: 11));
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        LiquidMetalCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progreso', style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Evolución en el tiempo (peso, macros, adherencia).', style: GoogleFonts.syne(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 14),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Center(
                  child: Text(
                    'Aquí pondremos gráficas (line chart).\nCuando quieras, lo hacemos con fl_chart.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.syne(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        LiquidMetalCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alertas', style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Bandera roja si algo se sale de rango o no hay adherencia.', style: GoogleFonts.syne(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 14),
              _alert('Sin registro de agua en 3 días', 'MEDIA'),
              _alert('Peso subió +1.5kg en 1 semana', 'ALTA'),
              _alert('Adherencia < 60%', 'ALTA'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _alert(String text, String level) {
    final isHigh = level == 'ALTA';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHigh ? Colors.red.withOpacity(0.10) : Colors.orange.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isHigh ? Colors.redAccent.withOpacity(0.35) : Colors.orangeAccent.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Icon(isHigh ? Icons.warning_amber_rounded : Icons.info_outline, color: isHigh ? Colors.redAccent : Colors.orangeAccent),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: GoogleFonts.syne(color: Colors.white70, fontWeight: FontWeight.w700))),
            Text(level, style: GoogleFonts.syne(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
