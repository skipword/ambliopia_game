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

  void continueToCalibration() {
    final appState = context.read<AppState>();

    appState.setAmblyopicEye(selectedEye);
    appState.setCalibrationReturnRoute(AppRoutes.home);

    Navigator.of(context).pushNamed(AppRoutes.calibrationStep1);
  }

  @override
  Widget build(BuildContext context) {
    final dominantEye = selectedEye.opposite;

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
              'Configuración ocular',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona cuál es el ojo con ambliopía.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 17,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.visibility, color: AppColors.cyan, size: 56),
                  SizedBox(height: 14),
                  Text(
                    'Uso de gafas rojo-verde',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'El lente rojo se usará para el ojo con ambliopía y el lente verde para el ojo dominante.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Ojo con ambliopía',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _EyeOption(
              title: 'Ojo izquierdo',
              subtitle: 'Asignar lente rojo al ojo izquierdo',
              selected: selectedEye == Eye.left,
              onTap: () {
                setState(() {
                  selectedEye = Eye.left;
                });
              },
            ),
            const SizedBox(height: 14),
            _EyeOption(
              title: 'Ojo derecho',
              subtitle: 'Asignar lente rojo al ojo derecho',
              selected: selectedEye == Eye.right,
              onTap: () {
                setState(() {
                  selectedEye = Eye.right;
                });
              },
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de configuración',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LensRow(
                    color: AppColors.red,
                    label: 'Lente rojo',
                    value: selectedEye.label,
                  ),
                  const SizedBox(height: 12),
                  _LensRow(
                    color: AppColors.green,
                    label: 'Lente verde',
                    value: dominantEye.label,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Esta configuración puede modificarse después desde el perfil o desde la sección de calibración.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
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
            onPressed: continueToCalibration,
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

class _EyeOption extends StatelessWidget {
  const _EyeOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFDDF8FB) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.cyan : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.cyan : AppColors.textMuted,
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LensRow extends StatelessWidget {
  const _LensRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label → $value',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
