import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../core/state/app_state.dart';

class PatientDataScreen extends StatefulWidget {
  const PatientDataScreen({super.key});

  @override
  State<PatientDataScreen> createState() => _PatientDataScreenState();
}

class _PatientDataScreenState extends State<PatientDataScreen> {
  final TextEditingController nameController = TextEditingController(
    text: 'fer',
  );

  String selectedCode = 'P-002';
  int selectedAge = 5;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void continueToOcularConfiguration() {
    context.read<AppState>().setPatient(
      code: selectedCode,
      name: nameController.text,
      age: selectedAge,
    );

    Navigator.of(context).pushNamed(AppRoutes.ocularConfig);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registro de paciente',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Datos personales',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              const Text(
                'Código de paciente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final code in [
                    'P-001',
                    'P-002',
                    'P-003',
                    'P-004',
                    'P-005',
                  ])
                    _SelectableChip(
                      label: code,
                      selected: selectedCode == code,
                      onTap: () {
                        setState(() {
                          selectedCode = code;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Nombre completo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Ej: Sofía Martínez',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Edad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final age in [3, 4, 5, 6, 7])
                    _AgeChip(
                      age: age,
                      selected: selectedAge == age,
                      onTap: () {
                        setState(() {
                          selectedAge = age;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Rango: 3 a 7 años',
                style: TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: continueToOcularConfiguration,
                  child: const Text(
                    'Continuar →',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE0F7FA) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF14B8D4) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _AgeChip extends StatelessWidget {
  const _AgeChip({
    required this.age,
    required this.selected,
    required this.onTap,
  });

  final int age;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE0F7FA) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 70,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? const Color(0xFF14B8D4) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$age',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}
