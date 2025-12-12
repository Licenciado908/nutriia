import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nutriia_frontend/models/indicator_model.dart';
import 'package:nutriia_frontend/services/indicators_api.dart';
import 'package:nutriia_frontend/widgets/add_indicator_sheet.dart';

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
  children: [
    _IndicatorsTab(patientId: widget.patient.id),
    const _HabitsTab(),
    const _ProgressTab(),
    const _AlertsTab(),
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

class _IndicatorsTab extends StatefulWidget {
  final int patientId;
  const _IndicatorsTab({required this.patientId});

  @override
  State<_IndicatorsTab> createState() => _IndicatorsTabState();
  
}

class _IndicatorsTabState extends State<_IndicatorsTab> {
  final _api = IndicatorsApi();
  late Future<List<Indicator>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getIndicators(widget.patientId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.getIndicators(widget.patientId);
    });
    await _future;
  }

  // ✅ ESTE MÉTODO ESTÁ BIEN (solo asegúrate de tener el import)
  void _openAddIndicatorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddIndicatorSheet(
        patientId: widget.patientId,
        onSaved: _refresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Stack(
    children: [
      RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF00C853),
        backgroundColor: Colors.black,
        child: FutureBuilder<List<Indicator>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C853)),
              );
            }

            if (snap.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Error cargando indicadores\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.syne(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                ],
              );
            }

            final indicators = snap.data ?? [];

            if (indicators.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
                children: [
                  LiquidMetalCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.monitor_heart, color: Colors.white24, size: 46),
                        const SizedBox(height: 10),
                        Text(
                          'Aún no hay indicadores registrados',
                          style: GoogleFonts.syne(
                            color: Colors.white70,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Cuando registres controles (peso, IMC, % grasa)\naparecerán aquí.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.syne(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              itemCount: indicators.length,
              itemBuilder: (context, i) => _indicatorCard(indicators[i]),
            );
          },
        ),
      ),

      // ✅ BOTÓN FLOTANTE PARA AGREGAR INDICADOR
      Positioned(
        bottom: 30,
        right: 20,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF00C853),
          onPressed: _openAddIndicatorModal, // <- debes tener esta función
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    ],
  );
}


  Widget _indicatorCard(Indicator ind) {
    final dateStr = DateFormat('dd MMM yyyy • HH:mm').format(ind.createdAt.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LiquidMetalCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.syne(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF00C853).withOpacity(0.25)),
                    color: const Color(0xFF00C853).withOpacity(0.10),
                  ),
                  child: Text(
                    'CONTROL',
                    style: GoogleFonts.syne(
                      color: const Color(0xFF00C853),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Métricas
            Row(
              children: [
                Expanded(child: _metric('PESO', '${ind.weight.toStringAsFixed(1)} kg')),
                const SizedBox(width: 10),
                Expanded(child: _metric('IMC', ind.bmi.toStringAsFixed(1))),
                const SizedBox(width: 10),
                Expanded(child: _metric('% GRASA', '${ind.fatPercent.toStringAsFixed(1)}%')),
              ],
            ),

            if (ind.note != null && ind.note!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'NOTA',
                style: GoogleFonts.syne(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ind.note!,
                style: GoogleFonts.syne(color: Colors.white70, fontSize: 13, height: 1.3),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.syne(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.syne(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

  Widget _addButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          // siguiente paso: modal de registro
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          'REGISTRAR NUEVO INDICADOR',
          style: GoogleFonts.syne(fontWeight: FontWeight.w900),
        ),
      ),
    );
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
