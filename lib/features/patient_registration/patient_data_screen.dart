import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
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

  final List<String> patientCodes = const [
    'P-001',
    'P-002',
    'P-003',
    'P-004',
    'P-005',
  ];

  final List<int> ages = const [3, 4, 5, 6, 7];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void continueToOcularConfig() {
    context.read<AppState>().setPatient(
      code: selectedCode,
      name: nameController.text,
      age: selectedAge,
    );

    Navigator.of(context).pushNamed(AppRoutes.ocularConfig);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final codeBoxWidth = ((screenWidth - 48 - 24) / 3)
        .clamp(92.0, 150.0)
        .toDouble();

    final ageBoxWidth = ((screenWidth - 48 - 36) / 4)
        .clamp(72.0, 110.0)
        .toDouble();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            Text(
              'Registro de paciente',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Datos personales',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 36),
            const _SectionTitle(title: 'Código de paciente'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: patientCodes.map((code) {
                return _SelectableBox(
                  width: codeBoxWidth,
                  height: 64,
                  label: code,
                  selected: selectedCode == code,
                  onTap: () {
                    setState(() {
                      selectedCode = code;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 36),
            const _SectionTitle(title: 'Nombre completo'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Nombre del paciente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 22,
                ),
              ),
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 36),
            const _SectionTitle(title: 'Edad'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ages.map((age) {
                return _SelectableBox(
                  width: ageBoxWidth,
                  height: 64,
                  label: '$age',
                  selected: selectedAge == age,
                  onTap: () {
                    setState(() {
                      selectedAge = age;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            const Text(
              'Rango: 3 a 7 años',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: FilledButton(
            onPressed: continueToOcularConfig,
            child: const Text(
              'Continuar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 21,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SelectableBox extends StatelessWidget {
  const _SelectableBox({
    required this.width,
    required this.height,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final double height;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFDDF8FB) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.cyan : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
