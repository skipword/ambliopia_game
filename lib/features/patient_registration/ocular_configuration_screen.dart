import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';
import '../../core/models/eye.dart';
import '../../core/state/app_state.dart';

class OcularConfigurationScreen extends StatefulWidget {
  const OcularConfigurationScreen({super.key});

  @override
  State<OcularConfigurationScreen> createState() =>
      _OcularConfigurationScreenState();
}

class _OcularConfigurationScreenState extends State<OcularConfigurationScreen> {
  Eye selectedEye = Eye.left;

  void finishConfiguration() {
    final appState = context.read<AppState>();

    appState.setAmblyopicEye(selectedEye);

    // Como es la primera configuración, después de calibrar debe ir al Home.
    appState.setCalibrationReturnRoute(AppRoutes.home);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final dominantEye = selectedEye.opposite;

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
                'Configuración ocular',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF4FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Las gafas anaglíficas tienen lente rojo y lente verde. '
                  'El lente rojo se asignará al ojo configurado con ambliopía.',
                  style: TextStyle(height: 1.4),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '¿Cuál es el ojo con ambliopía?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Este ojo usará el lente rojo.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _EyeOption(
                      eye: Eye.left,
                      selected: selectedEye == Eye.left,
                      onTap: () {
                        setState(() {
                          selectedEye = Eye.left;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _EyeOption(
                      eye: Eye.right,
                      selected: selectedEye == Eye.right,
                      onTap: () {
                        setState(() {
                          selectedEye = Eye.right;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F8EF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '${dominantEye.label} → lente verde\n'
                  'Ojo dominante asignado automáticamente.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                  ),
                  onPressed: finishConfiguration,
                  child: const Text(
                    '¡Listo! 🎉',
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

class _EyeOption extends StatelessWidget {
  const _EyeOption({
    required this.eye,
    required this.selected,
    required this.onTap,
  });

  final Eye eye;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFEEF1) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 170,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.red : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.visibility,
                size: 42,
                color: selected ? AppColors.red : Colors.grey.shade300,
              ),
              const SizedBox(height: 14),
              Text(
                eye.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '🔴 Lente rojo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
