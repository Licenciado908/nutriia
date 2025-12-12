import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/indicators_api.dart';
import 'liquid_metal_card.dart';

class AddIndicatorSheet extends StatefulWidget {
  final int patientId;
  final Future<void> Function() onSaved;

  const AddIndicatorSheet({
    super.key,
    required this.patientId,
    required this.onSaved,
  });

  @override
  State<AddIndicatorSheet> createState() => _AddIndicatorSheetState();
}

class _AddIndicatorSheetState extends State<AddIndicatorSheet> {
  final _weight = TextEditingController();
  final _bmi = TextEditingController();
  final _fat = TextEditingController();
  final _note = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _weight.dispose();
    _bmi.dispose();
    _fat.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final w = double.tryParse(_weight.text.trim());
    final b = double.tryParse(_bmi.text.trim());
    final f = double.tryParse(_fat.text.trim());

    if (w == null || b == null || f == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa números válidos (peso, IMC y % grasa).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await IndicatorsApi().createIndicator(
        patientId: widget.patientId,
        weight: w,
        bmi: b,
        fatPercent: f,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      await widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: LiquidMetalCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NUEVO CONTROL',
              style: GoogleFonts.syne(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            _field(_weight, 'Peso (kg)', isNumber: true),
            const SizedBox(height: 10),
            _field(_bmi, 'IMC', isNumber: true),
            const SizedBox(height: 10),
            _field(_fat, '% Grasa', isNumber: true),
            const SizedBox(height: 10),
            _field(_note, 'Nota (opcional)', isNumber: false, maxLines: 2),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        'GUARDAR',
                        style: GoogleFonts.syne(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    required bool isNumber,
    int maxLines = 1,
  }) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: GoogleFonts.syne(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.syne(color: Colors.white38),
        filled: true,
        fillColor: Colors.black.withOpacity(0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
